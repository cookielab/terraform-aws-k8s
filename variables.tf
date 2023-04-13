
variable "availability_zones" {
  type        = list(string)
  description = "List of availability zone strings in the region. Those are bound to subnets order!"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version to use in EKS"
}

variable "k8s_coredns_version" {
  type        = string
  description = "Kubernetes coredns addon version to use in EKS"
}

variable "k8s_kube_proxy_version" {
  type        = string
  description = "Kubernetes kube-proxy addon version to use in EKS"
}

variable "k8s_vpc_cni_version" {
  type        = string
  description = "Kubernetes vpc-cni addon version to use in EKS"
}

variable "k8s_ebs_csi_driver_version" {
  type        = string
  description = "Kubernetes aws-ebs-csi-driver addon version to use in EKS"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet ID strings. Those are bound to AZ order!"
}

variable "project" {
  type        = string
  description = "Unique project name. Used in automatic labeling."
}

variable "region" {
  type        = string
  description = "AWS region name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy the EKS to"
}

variable "aws_auth_roles" {
  type        = list(any)
  description = "List of IAM roles to attach to the EKS cluster"
  default     = []
}

variable "k8s_control_private" {
  type        = bool
  default     = true
  description = "Allow access to EKS control plane from private network"
}

variable "k8s_control_public" {
  type        = bool
  default     = true
  description = "Allow access to EKS control plane from public subnets"
}

variable "node_group_defaults" {
  type = object({
    instance_types             = list(string)
    ami_type                   = optional(string, "BOTTLEROCKET_x86_64")
    platform                   = optional(string, "bottlerocket")
    use_custom_launch_template = optional(bool, false)
  })
  description = <<-EOF
  Contains configuration for EKS module's `node_group_defaults` attribute.

  Bottlerocket is used by default.

  Example:
  ```
  {
    instance_types = ["t3.medium"]
  }
  ```
  EOF
}

variable "node_groups_all_az" {
  type = map(object({
    min_size       = number
    max_size       = number
    desired_size   = number
    instance_types = list(string)
    capacity_type  = optional(string, "ON_DEMAND")
    disk_size      = optional(number, 50)
    labels         = optional(map(string), {})
    tags           = optional(map(string), {})
    subnet_ids     = optional(list(string))
  }))
  default     = {}
  description = <<-EOF
  This deploys one node-group across all AZs. You can define multiple node groups

  Example:
  ```
  {
    pod = {
      capacity_type  = "ON_DEMAND"
      instance_types = []
      min_size       = 1
      max_size       = 3
      desired_size   = 1
      disk_size      = 50 # GiB
      labels = {
        "infra.k8s.mailstep/group" = "primary"
      }
    }
  }
  ```
  EOF
}

variable "node_groups_per_az" {
  type = map(object({
    min_size       = number
    max_size       = number
    desired_size   = number
    instance_types = list(string)
    capacity_type  = optional(string, "ON_DEMAND")
    disk_size      = optional(number, 50)
    labels         = optional(map(string), {})
    tags           = optional(map(string), {})
    subnet_ids     = optional(list(string))
  }))
  default     = {}
  description = <<-EOF
  This deploys one node-group for each AZ. You can define multiple node groups

  Example:
  ```
  {
    pod = {
      capacity_type  = "ON_DEMAND"
      instance_types = []
      min_size       = 1
      max_size       = 3
      desired_size   = 1
      disk_size      = 50 # GiB
      labels = {
        "infra.k8s.mailstep/group" = "primary"
      }
    }
  }
  ```
  EOF
}


variable "sg_rules_cluster" {
  type = map(object({
    description                = string
    from_port                  = number
    to_port                    = number
    type                       = string
    protocol                   = optional(string, "-1")
    cidr_blocks                = optional(list(string), [])
    ipv6_cidr_blocks           = optional(list(string), [])
    self                       = optional(bool)
    source_node_security_group = optional(bool)
  }))
  default     = {}
  description = <<-EOF
  Additional security group rules for node groups

  Example:
  ```
  {
    ingress_smtp = {
      description      = "A dirty SMTP example"
      protocol         = "udp"
      from_port        = 25
      to_port          = 25
      type             = "ingress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  ```
  EOF
}

variable "sg_rules_nodes" {
  type = map(object({
    description                = string
    from_port                  = number
    to_port                    = number
    type                       = string
    protocol                   = optional(string, "-1")
    cidr_blocks                = optional(list(string), [])
    ipv6_cidr_blocks           = optional(list(string), [])
    self                       = optional(bool)
    source_node_security_group = optional(bool)
  }))
  default     = {}
  description = <<-EOF
  Additional security group rules for cluster control plane

  Example:
  ```
  {
    ingress_smtp = {
      description      = "A dirty SMTP example"
      protocol         = "udp"
      from_port        = 25
      to_port          = 25
      type             = "ingress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  ```
  EOF
}

