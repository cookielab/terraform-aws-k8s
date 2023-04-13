data "aws_eks_cluster" "this" {
  name = var.cluster_id
}

data "aws_eks_node_groups" "this" {
  cluster_name = data.aws_eks_cluster.this.name
}

data "aws_eks_node_group" "this" {
  for_each = data.aws_eks_node_groups.this.names

  cluster_name    = data.aws_eks_cluster.this.name
  node_group_name = each.value
}

data "aws_region" "current" {}

data "aws_subnet" "this" {
  for_each = toset(flatten([
    for node_group in data.aws_eks_node_group.this : node_group.subnet_ids
  ]))

  id = each.value
}

locals {
  tains_map = {
    NO_SCHEDULE        = "NoSchedule"
    NO_EXECUTE         = "NoExecute"
    PREFER_NO_SCHEDULE = "PreferNoSchedule"
  }
  node_groups_autoscaling_groups = {
    for node_group in data.aws_eks_node_group.this : node_group.node_group_name => toset(flatten([
      for resource in node_group.resources : [
        for autoscaling_group in resource.autoscaling_groups : autoscaling_group.name
      ]
    ]))
  }
  node_groups_labels = {
    for node_group in data.aws_eks_node_group.this : node_group.node_group_name => node_group.labels
  }
  node_groups_taints = {
    for node_group in data.aws_eks_node_group.this : node_group.node_group_name => node_group.taints
  }
  autoscaling_groups_labels = {
    for v in flatten([
      for node_group_name, autoscaling_groups in local.node_groups_autoscaling_groups : flatten([
        for autoscaling_group in autoscaling_groups : flatten([
          for label_key, label_value in local.node_groups_labels[node_group_name] : {
            autoscaling_group = autoscaling_group
            label = {
              key   = "k8s.io/cluster-autoscaler/node-template/label/${label_key}"
              value = label_value
            }
          }
        ])
      ])
    ]) : "${v.autoscaling_group}#${v.label.key}" => v
  }
  autoscaling_groups_taints = {
    for v in flatten([
      for node_group_name, autoscaling_groups in local.node_groups_autoscaling_groups : flatten([
        for autoscaling_group in autoscaling_groups : flatten([
          for taint_values in local.node_groups_taints[node_group_name] : {
            autoscaling_group = autoscaling_group
            taint = {
              key   = "k8s.io/cluster-autoscaler/node-template/taint/${taint_values.key}"
              value = "${taint_values.value}:${local.tains_map[taint_values.effect]}"
            }
          }
        ])
      ])
    ]) : "${v.autoscaling_group}#${v.taint.key}" => v
  }
  autoscaling_groups_aws_labels = {
    for v in flatten([
      for node_group_name, autoscaling_groups in local.node_groups_autoscaling_groups : flatten([
        for autoscaling_group in autoscaling_groups : concat(
          [
            {
              autoscaling_group = autoscaling_group
              label = {
                key   = "k8s.io/cluster-autoscaler/node-template/label/eks.amazonaws.com/capacityType"
                value = data.aws_eks_node_group.this[node_group_name].capacity_type
              }
            },
            {
              autoscaling_group = autoscaling_group
              label = {
                key   = "k8s.io/cluster-autoscaler/node-template/label/topology.kubernetes.io/region"
                value = data.aws_region.current.name
              }
            },
            {
              autoscaling_group = autoscaling_group
              label = {
                key   = "k8s.io/cluster-autoscaler/node-template/label/failure-domain.beta.kubernetes.io/region"
                value = data.aws_region.current.name
              }
            },
          ],
          length(data.aws_eks_node_group.this[node_group_name].subnet_ids) == 1 ? [
            {
              autoscaling_group = autoscaling_group
              label = {
                key   = "k8s.io/cluster-autoscaler/node-template/label/topology.kubernetes.io/zone"
                value = data.aws_subnet.this[one(data.aws_eks_node_group.this[node_group_name].subnet_ids)].availability_zone
              }
            },
            {
              autoscaling_group = autoscaling_group
              label = {
                key   = "k8s.io/cluster-autoscaler/node-template/label/failure-domain.beta.kubernetes.io/zone"
                value = data.aws_subnet.this[one(data.aws_eks_node_group.this[node_group_name].subnet_ids)].availability_zone
              }
            }
          ] : [],
          data.aws_eks_node_group.this[node_group_name].ami_type != "CUSTOM" ? [
            {
              autoscaling_group = autoscaling_group
              label = {
                key   = "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/os"
                value = "linux"
              }
            },
            {
              autoscaling_group = autoscaling_group
              label = {
                key   = "k8s.io/cluster-autoscaler/node-template/label/beta.kubernetes.io/os"
                value = "linux"
              }
            },
            {
              autoscaling_group = autoscaling_group
              label = {
                key   = "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/arch"
                value = length(regexall(".*x86_64.*", data.aws_eks_node_group.this[node_group_name].ami_type)) != 0 ? "amd64" : "arm64"
              }
            },
            {
              autoscaling_group = autoscaling_group
              label = {
                key   = "k8s.io/cluster-autoscaler/node-template/label/beta.kubernetes.io/arch"
                value = length(regexall(".*x86_64.*", data.aws_eks_node_group.this[node_group_name].ami_type)) != 0 ? "amd64" : "arm64"
              }
            },
          ] : []
        )
      ])
    ]) : "${v.autoscaling_group}#${v.label.key}" => v
  }
}

resource "aws_autoscaling_group_tag" "label" {
  for_each = local.autoscaling_groups_labels

  autoscaling_group_name = each.value.autoscaling_group

  tag {
    key                 = each.value.label.key
    value               = each.value.label.value
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "taint" {
  for_each = local.autoscaling_groups_taints

  autoscaling_group_name = each.value.autoscaling_group

  tag {
    key                 = each.value.taint.key
    value               = each.value.taint.value
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "aws_label" {
  for_each = local.autoscaling_groups_aws_labels

  autoscaling_group_name = each.value.autoscaling_group

  tag {
    key                 = each.value.label.key
    value               = each.value.label.value
    propagate_at_launch = true
  }
}
