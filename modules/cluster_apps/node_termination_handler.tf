locals {
  aws_node_termination_handler_service_account_name = "aws-node-termination-handler"
  aws_node_termination_handler_sqs_name             = "aws-node-termination-handler-${data.aws_eks_cluster.this.name}"
}

data "aws_iam_policy_document" "aws_node_termination_handler_sqs" {
  statement {
    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${local.aws_node_termination_handler_sqs_name}"]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "sqs.amazonaws.com",
      ]
    }
  }
}

module "aws_node_termination_handler_sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.0.1"

  name                      = local.aws_node_termination_handler_sqs_name
  message_retention_seconds = 300
}

resource "aws_sqs_queue_policy" "aws_node_termination_handler" {
  queue_url = module.aws_node_termination_handler_sqs.queue_url
  policy    = data.aws_iam_policy_document.aws_node_termination_handler_sqs.json
}

module "node_termination_handler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.16.0"

  role_name_prefix = "node-termination-handler"
  role_description = "IRSA role for node termination handler"

  attach_node_termination_handler_policy  = true
  node_termination_handler_sqs_queue_arns = [module.aws_node_termination_handler_sqs.queue_arn]

  oidc_providers = {
    main = {
      provider_arn               = data.aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["${kubernetes_namespace.cluster_apps.metadata[0].name}:${local.aws_node_termination_handler_service_account_name}"]
    }
  }
}

resource "helm_release" "aws_node_termination_handler" {
  name      = "aws-node-termination-handler"
  namespace = kubernetes_namespace.cluster_apps.metadata[0].name

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-node-termination-handler"
  version    = "0.21.0"

  values = [<<YAML
awsRegion: ${data.aws_region.current.name}
serviceAccount:
  name: ${local.aws_node_termination_handler_service_account_name}
  annotations:
    eks.amazonaws.com/role-arn: ${module.node_termination_handler_irsa.iam_role_arn}
enableSqsTerminationDraining: true
enableSpotInterruptionDraining: true
queueURL: ${module.aws_node_termination_handler_sqs.queue_url}
logLevel: debug
YAML
  ]
}

resource "aws_cloudwatch_event_rule" "aws_node_termination_handler_asg" {
  name        = "${local.aws_node_termination_handler_sqs_name}-asg-termination"
  description = "Node termination event rule"

  event_pattern = jsonencode({
    "source" : ["aws.autoscaling"],
    "detail-type" : ["EC2 Instance-terminate Lifecycle Action"]
    "resources" : [for group in data.aws_autoscaling_group.this : group.arn]
  })
}

resource "aws_cloudwatch_event_target" "aws_node_termination_handler_asg" {
  target_id = "${local.aws_node_termination_handler_sqs_name}-asg-termination"
  rule      = aws_cloudwatch_event_rule.aws_node_termination_handler_asg.name
  arn       = module.aws_node_termination_handler_sqs.queue_arn
}

resource "aws_cloudwatch_event_rule" "aws_node_termination_handler_spot" {
  name        = "${local.aws_node_termination_handler_sqs_name}-spot-termination"
  description = "Node termination event rule"
  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : ["EC2 Spot Instance Interruption Warning"]
  })
}

resource "aws_cloudwatch_event_target" "aws_node_termination_handler_spot" {
  target_id = "${local.aws_node_termination_handler_sqs_name}-spot-termination"
  rule      = aws_cloudwatch_event_rule.aws_node_termination_handler_spot.name
  arn       = module.aws_node_termination_handler_sqs.queue_arn
}

resource "aws_autoscaling_lifecycle_hook" "aws_node_termination_handler" {
  for_each = local.autoscaling_groups

  name                   = "aws-node-termination-handler-${each.value}"
  autoscaling_group_name = each.value
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  heartbeat_timeout      = 300
  default_result         = "CONTINUE"
}
