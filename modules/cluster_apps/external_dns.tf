locals {
  external_dns_service_account_name = "external-dns"
}

module "external_dns_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.16.0"

  role_name_prefix = "external-dns"
  role_description = "IRSA role for external dns"

  attach_external_dns_policy = true

  oidc_providers = {
    main = {
      provider_arn               = data.aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["${kubernetes_namespace.cluster_apps.metadata[0].name}:${local.external_dns_service_account_name}"]
    }
  }
}

resource "helm_release" "external_dns" {
  name      = "external-dns"
  namespace = kubernetes_namespace.cluster_apps.metadata[0].name

  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.12.1"

  values = [<<YAML
domainFilters:
  ${indent(2, yamlencode(var.external_domain_names))}
txtOwnerId: ${var.cluster_name}
txtPrefix: 'external-dns.'
policy: sync
aws:
  region: ${data.aws_region.current.name}
serviceAccount:
  name: ${local.external_dns_service_account_name}
  annotations:
    eks.amazonaws.com/role-arn: ${module.external_dns_irsa.iam_role_arn}
priorityClassName: system-cluster-critical
YAML
  ]
}
