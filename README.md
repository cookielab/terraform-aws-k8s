<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

No requirements.

Basic usage of this module is as follows:

```hcl
module "example" {
	 source  = "<module-path>"

	 # Required variables
	 availability_zones  = 
	 cluster_name  = 
	 k8s_coredns_version  = 
	 k8s_ebs_csi_driver_version  = 
	 k8s_kube_proxy_version  = 
	 k8s_version  = 
	 k8s_vpc_cni_version  = 
	 node_group_defaults  = 
	 private_subnet_ids  = 
	 project  = 
	 region  = 
	 vpc_id  = 

	 # Optional variables
	 aws_auth_roles  = []
	 k8s_control_private  = true
	 k8s_control_public  = true
	 node_groups_all_az  = {}
	 node_groups_per_az  = {}
	 sg_rules_cluster  = {}
	 sg_rules_nodes  = {}
}
```

## Resources

| Name | Type |
|------|------|
| [aws_iam_role_policy_attachment.k8s_ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.k8s](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zone strings in the region. Those are bound to subnets order! | `list(string)` | n/a | yes |
| <a name="input_aws_auth_roles"></a> [aws\_auth\_roles](#input\_aws\_auth\_roles) | List of IAM roles to attach to the EKS cluster | `list(any)` | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_k8s_control_private"></a> [k8s\_control\_private](#input\_k8s\_control\_private) | Allow access to EKS control plane from private network | `bool` | `true` | no |
| <a name="input_k8s_control_public"></a> [k8s\_control\_public](#input\_k8s\_control\_public) | Allow access to EKS control plane from public subnets | `bool` | `true` | no |
| <a name="input_k8s_coredns_version"></a> [k8s\_coredns\_version](#input\_k8s\_coredns\_version) | Kubernetes coredns addon version to use in EKS | `string` | n/a | yes |
| <a name="input_k8s_ebs_csi_driver_version"></a> [k8s\_ebs\_csi\_driver\_version](#input\_k8s\_ebs\_csi\_driver\_version) | Kubernetes aws-ebs-csi-driver addon version to use in EKS | `string` | n/a | yes |
| <a name="input_k8s_kube_proxy_version"></a> [k8s\_kube\_proxy\_version](#input\_k8s\_kube\_proxy\_version) | Kubernetes kube-proxy addon version to use in EKS | `string` | n/a | yes |
| <a name="input_k8s_version"></a> [k8s\_version](#input\_k8s\_version) | Kubernetes version to use in EKS | `string` | n/a | yes |
| <a name="input_k8s_vpc_cni_version"></a> [k8s\_vpc\_cni\_version](#input\_k8s\_vpc\_cni\_version) | Kubernetes vpc-cni addon version to use in EKS | `string` | n/a | yes |
| <a name="input_node_group_defaults"></a> [node\_group\_defaults](#input\_node\_group\_defaults) | Contains configuration for EKS module's `node_group_defaults` attribute.<br><br>Bottlerocket is used by default.<br><br>Example:<pre>{<br>  instance_types = ["t3.medium"]<br>}</pre> | <pre>object({<br>    instance_types             = list(string)<br>    ami_type                   = optional(string, "BOTTLEROCKET_x86_64")<br>    platform                   = optional(string, "bottlerocket")<br>    use_custom_launch_template = optional(bool, false)<br>  })</pre> | n/a | yes |
| <a name="input_node_groups_all_az"></a> [node\_groups\_all\_az](#input\_node\_groups\_all\_az) | This deploys one node-group across all AZs. You can define multiple node groups<br><br>Example:<pre>{<br>  pod = {<br>    capacity_type  = "ON_DEMAND"<br>    instance_types = []<br>    min_size       = 1<br>    max_size       = 3<br>    desired_size   = 1<br>    disk_size      = 50 # GiB<br>    labels = {<br>      "infra.k8s.mailstep/group" = "primary"<br>    }<br>  }<br>}</pre> | <pre>map(object({<br>    min_size       = number<br>    max_size       = number<br>    desired_size   = number<br>    instance_types = list(string)<br>    capacity_type  = optional(string, "ON_DEMAND")<br>    disk_size      = optional(number, 50)<br>    labels         = optional(map(string), {})<br>    tags           = optional(map(string), {})<br>    subnet_ids     = optional(list(string))<br>  }))</pre> | `{}` | no |
| <a name="input_node_groups_per_az"></a> [node\_groups\_per\_az](#input\_node\_groups\_per\_az) | This deploys one node-group for each AZ. You can define multiple node groups<br><br>Example:<pre>{<br>  pod = {<br>    capacity_type  = "ON_DEMAND"<br>    instance_types = []<br>    min_size       = 1<br>    max_size       = 3<br>    desired_size   = 1<br>    disk_size      = 50 # GiB<br>    labels = {<br>      "infra.k8s.mailstep/group" = "primary"<br>    }<br>  }<br>}</pre> | <pre>map(object({<br>    min_size       = number<br>    max_size       = number<br>    desired_size   = number<br>    instance_types = list(string)<br>    capacity_type  = optional(string, "ON_DEMAND")<br>    disk_size      = optional(number, 50)<br>    labels         = optional(map(string), {})<br>    tags           = optional(map(string), {})<br>    subnet_ids     = optional(list(string))<br>  }))</pre> | `{}` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet ID strings. Those are bound to AZ order! | `list(string)` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Unique project name. Used in automatic labeling. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region name | `string` | n/a | yes |
| <a name="input_sg_rules_cluster"></a> [sg\_rules\_cluster](#input\_sg\_rules\_cluster) | Additional security group rules for node groups<br><br>Example:<pre>{<br>  ingress_smtp = {<br>    description      = "A dirty SMTP example"<br>    protocol         = "udp"<br>    from_port        = 25<br>    to_port          = 25<br>    type             = "ingress"<br>    cidr_blocks      = ["0.0.0.0/0"]<br>    ipv6_cidr_blocks = ["::/0"]<br>  }<br>}</pre> | <pre>map(object({<br>    description                = string<br>    from_port                  = number<br>    to_port                    = number<br>    type                       = string<br>    protocol                   = optional(string, "-1")<br>    cidr_blocks                = optional(list(string), [])<br>    ipv6_cidr_blocks           = optional(list(string), [])<br>    self                       = optional(bool)<br>    source_node_security_group = optional(bool)<br>  }))</pre> | `{}` | no |
| <a name="input_sg_rules_nodes"></a> [sg\_rules\_nodes](#input\_sg\_rules\_nodes) | Additional security group rules for cluster control plane<br><br>Example:<pre>{<br>  ingress_smtp = {<br>    description      = "A dirty SMTP example"<br>    protocol         = "udp"<br>    from_port        = 25<br>    to_port          = 25<br>    type             = "ingress"<br>    cidr_blocks      = ["0.0.0.0/0"]<br>    ipv6_cidr_blocks = ["::/0"]<br>  }<br>}</pre> | <pre>map(object({<br>    description                = string<br>    from_port                  = number<br>    to_port                    = number<br>    type                       = string<br>    protocol                   = optional(string, "-1")<br>    cidr_blocks                = optional(list(string), [])<br>    ipv6_cidr_blocks           = optional(list(string), [])<br>    self                       = optional(bool)<br>    source_node_security_group = optional(bool)<br>  }))</pre> | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to deploy the EKS to | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_addons"></a> [cluster\_addons](#output\_cluster\_addons) | n/a |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | n/a |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | n/a |
| <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn) | n/a |
| <a name="output_cluster_identity_providers"></a> [cluster\_identity\_providers](#output\_cluster\_identity\_providers) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | n/a |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | n/a |
| <a name="output_project"></a> [project](#output\_project) | n/a |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->