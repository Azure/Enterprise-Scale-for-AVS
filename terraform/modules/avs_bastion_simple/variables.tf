variable "bastion_pip_name" {
  type        = string
  description = "Azure resource name assigned to the bastion public ip"
}
variable "bastion_name" {
  type        = string
  description = "Azure resouuce name assigned to the bastion instance"
}
variable "rg_name" {
  type        = string
  description = "Resource Group Name where Bastion and the associated public ip are being deployed"
}
variable "rg_location" {
  type        = string
  description = "Resource Group location"
  default     = "westus2"
}
variable "bastion_subnet_id" {
  type        = string
  description = "The full resource id for the subnet where the bastion will be deployed"
}

variable "tags" {
  type        = map(string)
  description = "List of the tags that will be assigned to each resource"
}