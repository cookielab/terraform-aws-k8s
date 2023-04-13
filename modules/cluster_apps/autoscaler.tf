locals {
  cluster_autoscaler_service_account_name = "cluster-autoscaler-aws"
  cluster_autoscaler_image_versions = {
    "1.23" = "v1.23.0"
    "1.24" = "v1.24.0"
    "1.25" = "v1.25.0"
    "1.26" = "v1.26.1"
  }
}

module "cluster_autoscaler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.16.0"

  role_name_prefix = "cluster-autoscaler"
  role_description = "IRSA role for cluster autoscaler"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [data.aws_eks_cluster.this.name]

  oidc_providers = {
    main = {
      provider_arn               = data.aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["${kubernetes_namespace.cluster_apps.metadata[0].name}:${local.cluster_autoscaler_service_account_name}"]
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  name      = "cluster-autoscaler"
  namespace = kubernetes_namespace.cluster_apps.metadata[0].name

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.27.0"

  values = [<<YAML
image:
  tag: ${lookup(local.cluster_autoscaler_image_versions, substr(data.aws_eks_cluster.this.version, 0, 4), "v1.21.2")}
awsRegion: ${data.aws_region.current.name}
autoDiscovery:
  enabled: true
  clusterName: ${data.aws_eks_cluster.this.name}
rbac:
  create: true
  serviceAccount:
    name: ${local.cluster_autoscaler_service_account_name}
    annotations:
      eks.amazonaws.com/role-arn: ${module.cluster_autoscaler_irsa.iam_role_arn}
priorityClassName: system-cluster-critical
extraArgs:
  v: 2
  stderrthreshold: info
  balance-similar-node-groups: true
  skip-nodes-with-system-pods: false
  expander: priority
  scale-down-delay-after-add: ${var.autoscaler_scale_down_delay_after_add}
  scale-down-delay-after-delete: ${var.autoscaler_scale_down_delay_after_delete}
  scale-down-unneeded-time: ${var.autoscaler_scale_down_unneeded_time}
  scale-down-utilization-threshold: ${var.autoscaler_scale_down_utilization_threshold}
expanderPriorities: |-
  10:
    - '.*on-demand.*'
    - '.*on_demand.*'
    - '.*ondemand.*'
    - 'pod_.*'
  20:
    - '.*spot.*'
    - 'ps_.*'
resources:
  limits:
    cpu: 100m
    memory: 300Mi
  requests:
    cpu: 100m
    memory: 300Mi
securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  runAsGroup: 1001
YAML
  ]
}
