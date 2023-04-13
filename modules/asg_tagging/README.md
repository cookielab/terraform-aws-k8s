<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.29 |

Basic usage of this module is as follows:

```hcl
module "example" {
	 source  = "<module-path>"

	 # Required variables
	 cluster_id  = 
}
```

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group_tag.aws_label](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group_tag) | resource |
| [aws_autoscaling_group_tag.label](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group_tag) | resource |
| [aws_autoscaling_group_tag.taint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group_tag) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_node_group) | data source |
| [aws_eks_node_groups.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_node_groups) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | EKS cluster id | `string` | n/a | yes |
## Outputs

No outputs.
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->