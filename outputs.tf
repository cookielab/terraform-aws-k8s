output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_addons" {
  value = module.eks.cluster_addons
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_iam_role_arn" {
  value = module.eks.cluster_iam_role_arn
}

output "cluster_identity_providers" {
  value = module.eks.cluster_identity_providers
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "kms_key_arn" {
  value = module.eks.kms_key_arn
}

output "project" {
  value = var.project
}
