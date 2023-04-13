locals {
  lb_controller_service_account_name = "lb-controller-aws"
}

module "lb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.16.0"

  role_name_prefix = "lb-controller"
  role_description = "IRSA role for LB controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = data.aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["${kubernetes_namespace.cluster_apps.metadata[0].name}:${local.lb_controller_service_account_name}"]
    }
  }
}

resource "helm_release" "aws_lb_controller" {
  name      = "aws-lb-controller"
  namespace = kubernetes_namespace.cluster_apps.metadata[0].name

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.8"

  values = [<<YAML
clusterName: ${data.aws_eks_cluster.this.name}
region: ${data.aws_region.current.name}
serviceAccount:
  name: ${local.lb_controller_service_account_name}
  annotations:
    eks.amazonaws.com/role-arn: ${module.lb_controller_irsa.iam_role_arn}
priorityClassName: system-cluster-critical
enablePodReadinessGateInject: true
defaultTags:
  project: ${var.project}
clusterSecretsPermissions:
  allowAllSecrets: true
YAML
  ]
}
