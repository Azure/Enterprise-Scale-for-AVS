variable "private_cloud_name" {
  type        = string
  description = "name of the private cloud where the hcx addon will be enabled"
}

variable "private_cloud_resource_group" {
  type        = string
  description = "name of the resource group where the private cloud is deployed"
}

variable "hcx_key_names" {
  type        = list(string)
  description = "list of key names to use when generating hcx site activation keys."
}