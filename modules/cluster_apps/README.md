<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0, < 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.8 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.5 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.10 |

Basic usage of this module is as follows:

```hcl
module "example" {
	 source  = "<module-path>"

	 # Required variables
	 cluster_name  = 
	 external_domain_names  = 
	 project  = 

	 # Optional variables
	 autoscaler_scale_down_delay_after_add  = "10m"
	 autoscaler_scale_down_delay_after_delete  = "0s"
	 autoscaler_scale_down_unneeded_time  = "10m"
	 autoscaler_scale_down_utilization_threshold  = 0.8
	 datadog_agent_node_selector  = null
	 datadog_api_key  = null
	 datadog_apm  = true
	 datadog_app_key  = null
	 datadog_service_monitoring  = true
	 datadog_site  = "datadoghq.eu"
}
```

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_lifecycle_hook.aws_node_termination_handler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_lifecycle_hook) | resource |
| [aws_cloudwatch_event_rule.aws_node_termination_handler_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.aws_node_termination_handler_spot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.aws_node_termination_handler_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.aws_node_termination_handler_spot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_sqs_queue_policy.aws_node_termination_handler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [helm_release.aws_lb_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.aws_node_termination_handler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.datadog](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.external_dns](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_daemonset.instance_metadata_exporter](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/daemonset) | resource |
| [kubernetes_namespace.cluster_apps](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.datadog](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_storage_class_v1.gp3](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [kubernetes_storage_class_v1.io2](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/autoscaling_group) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_node_group) | data source |
| [aws_eks_node_groups.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_node_groups) | data source |
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_policy_document.aws_node_termination_handler_sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaler_scale_down_delay_after_add"></a> [autoscaler\_scale\_down\_delay\_after\_add](#input\_autoscaler\_scale\_down\_delay\_after\_add) | n/a | `string` | `"10m"` | no |
| <a name="input_autoscaler_scale_down_delay_after_delete"></a> [autoscaler\_scale\_down\_delay\_after\_delete](#input\_autoscaler\_scale\_down\_delay\_after\_delete) | n/a | `string` | `"0s"` | no |
| <a name="input_autoscaler_scale_down_unneeded_time"></a> [autoscaler\_scale\_down\_unneeded\_time](#input\_autoscaler\_scale\_down\_unneeded\_time) | n/a | `string` | `"10m"` | no |
| <a name="input_autoscaler_scale_down_utilization_threshold"></a> [autoscaler\_scale\_down\_utilization\_threshold](#input\_autoscaler\_scale\_down\_utilization\_threshold) | n/a | `number` | `0.8` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_datadog_agent_node_selector"></a> [datadog\_agent\_node\_selector](#input\_datadog\_agent\_node\_selector) | n/a | `map(string)` | `null` | no |
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key) | n/a | `string` | `null` | no |
| <a name="input_datadog_apm"></a> [datadog\_apm](#input\_datadog\_apm) | n/a | `bool` | `true` | no |
| <a name="input_datadog_app_key"></a> [datadog\_app\_key](#input\_datadog\_app\_key) | n/a | `string` | `null` | no |
| <a name="input_datadog_service_monitoring"></a> [datadog\_service\_monitoring](#input\_datadog\_service\_monitoring) | n/a | `bool` | `true` | no |
| <a name="input_datadog_site"></a> [datadog\_site](#input\_datadog\_site) | n/a | `string` | `"datadoghq.eu"` | no |
| <a name="input_external_domain_names"></a> [external\_domain\_names](#input\_external\_domain\_names) | n/a | `list(string)` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kube_namespace"></a> [kube\_namespace](#output\_kube\_namespace) | n/a |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->