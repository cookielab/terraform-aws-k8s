variable "project" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "autoscaler_scale_down_delay_after_add" {
  type    = string
  default = "10m"
}

variable "autoscaler_scale_down_delay_after_delete" {
  type    = string
  default = "0s"
}

variable "autoscaler_scale_down_unneeded_time" {
  type    = string
  default = "10m"
}

variable "autoscaler_scale_down_utilization_threshold" {
  type    = number
  default = 0.8
}

variable "external_domain_names" {
  type = list(string)
}

variable "datadog_site" {
  type    = string
  default = "datadoghq.eu"
}

variable "datadog_api_key" {
  type    = string
  default = null
}

variable "datadog_app_key" {
  type    = string
  default = null
}

variable "datadog_service_monitoring" {
  type    = bool
  default = true
}

variable "datadog_apm" {
  type    = bool
  default = true
}

variable "datadog_agent_node_selector" {
  type    = map(string)
  default = null
}
