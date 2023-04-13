data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "kubernetes_namespace" "cluster_apps" {
  metadata {
    name = "cluster-apps"
  }
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_node_groups" "this" {
  cluster_name = data.aws_eks_cluster.this.name
}

data "aws_eks_node_group" "this" {
  for_each = data.aws_eks_node_groups.this.names

  cluster_name    = data.aws_eks_cluster.this.name
  node_group_name = each.value
}

locals {
  autoscaling_groups = toset(flatten([
    for node_group in data.aws_eks_node_group.this : [
      for resource in node_group.resources : [
        for autoscaling_group in resource.autoscaling_groups : autoscaling_group.name
      ]
    ]
  ]))
}

data "aws_autoscaling_group" "this" {
  for_each = local.autoscaling_groups

  name = each.value
}

data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}
