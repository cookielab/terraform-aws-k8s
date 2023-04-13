data "aws_vpc" "this" {
  id = var.vpc_id
}

#
# Prepare data for EKS provisioning
#
locals {
  k8s_infra_prefix = format("infra.k8s.%s", var.project)
  k8s_cluster_name = format("k8s-%s-%s", data.aws_vpc.this.tags["Name"], var.cluster_name)

  # Per-AZ node-groups
  k8s_node_groups_per_az = merge([
    for group, cfg in var.node_groups_per_az : {
      for i, az in var.availability_zones :
      "${group}_${az}" => merge(cfg, {
        subnet_ids = [var.private_subnet_ids[i]]
        labels = merge(cfg["labels"], {
          "${local.k8s_infra_prefix}/cluster"    = var.cluster_name,
          "${local.k8s_infra_prefix}/node-group" = format("%s_%s-%s", group, az, replace(lower(cfg["capacity_type"]), "_", "-")),
        })
      })
    }
  ]...)

  # All-AZ node-groups
  k8s_node_groups_all_az = {
    for group, cfg in var.node_groups_all_az : "${group}_${var.region}" => merge(cfg, {
      subnet_ids = var.private_subnet_ids
      labels = merge(cfg["labels"], {
        "${local.k8s_infra_prefix}/cluster"    = var.cluster_name,
        "${local.k8s_infra_prefix}/node-group" = format("%s_%s-%s", group, var.region, replace(lower(cfg["capacity_type"]), "_", "-")),
      })
    })
  }

  # Nodes additional security-groups
  k8s_sg_rules_nodes = merge(var.sg_rules_nodes, {
    ingress_self_all = {
      description = format("Intra-cluster communication (%s)", var.cluster_name)
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = format("Cluster egress (%s)", var.cluster_name)
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  })

  # Cluster additional security-groups
  k8s_sg_rules_cluster = merge(var.sg_rules_cluster, {
    egress_aws_lb_controller_webhook = {
      description                = format("AWS LB Controller webhook (%s)", var.cluster_name)
      protocol                   = "tcp"
      from_port                  = 9443
      to_port                    = 9443
      type                       = "egress"
      source_node_security_group = true
    }
  })

  # Node-group defaults
  k8s_node_group_defaults = merge(var.node_group_defaults, {
    ami_type                   = "BOTTLEROCKET_x86_64"
    platform                   = "bottlerocket"
    use_custom_launch_template = false
  })
}

#
# Encryption key
#
resource "aws_kms_key" "k8s" {
  description         = format("Encryption key for EKS cluster (%s)", var.cluster_name)
  key_usage           = "ENCRYPT_DECRYPT"
  enable_key_rotation = true
}

#
# EKS cluster
#
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.12.0"

  aws_auth_roles                          = var.aws_auth_roles
  cluster_endpoint_private_access         = var.k8s_control_private
  cluster_endpoint_public_access          = var.k8s_control_public
  cluster_name                            = local.k8s_cluster_name
  cluster_security_group_additional_rules = local.k8s_sg_rules_cluster
  cluster_version                         = var.k8s_version
  create_kms_key                          = false
  eks_managed_node_group_defaults         = local.k8s_node_group_defaults
  eks_managed_node_groups                 = merge(local.k8s_node_groups_per_az, local.k8s_node_groups_all_az)
  manage_aws_auth_configmap               = true
  node_security_group_additional_rules    = local.k8s_sg_rules_nodes
  subnet_ids                              = var.private_subnet_ids
  vpc_id                                  = var.vpc_id

  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.k8s.arn
    resources        = ["secrets"]
  }

  cluster_addons = {
    coredns = {
      addon_version     = var.k8s_coredns_version
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      addon_version     = var.k8s_kube_proxy_version
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      addon_version            = var.k8s_vpc_cni_version
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
    aws-ebs-csi-driver = {
      addon_version            = var.k8s_ebs_csi_driver_version
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }

}

#
# IAM
#
resource "aws_iam_role_policy_attachment" "k8s_ecr" {
  for_each   = module.eks.eks_managed_node_groups
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = each.value.iam_role_name
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.16.0"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.16.0"

  role_name_prefix      = "EBS-CNI-IRSA"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

#
# Autoscaler
#

# module "eks_autoscaler_asg_tags" {
#   source  = "cookielab/eks-autoscaler-asg-tagging/aws"
#   version = "1.2.2"
#
#   cluster_id = module.eks_main.cluster_name
# }
#
# module "eks_asg_tags" {
#   source = "./modules/eks-tags"
#
#   cluster_id = module.eks_main.cluster_name
# }






