variable "rg_name" {
  type        = string
  description = "Resource Group Name where the jumpbox is deployed"
}

variable "rg_location" {
  type        = string
  description = "Resource Group location"
  default     = "westus2"
}

variable "vwan_spoke_vnet_name" {
  type        = string
  description = "azure resource name for the spoke vnet"
}

variable "vwan_spoke_vnet_address_space" {
  type        = list(string)
  description = "Address space summaries for the spoke Vnet"
}

variable "vwan_spoke_subnets" {
  type = list(object({
    name           = string
    address_prefix = list(string)
  }))
}

variable "virtual_hub_spoke_vnet_connection_name" {
  type        = string
  description = "Azure resource name for the connection between the vnet and the vwan virtual hub"
}

variable "tags" {
  type        = map(string)
  description = "List of the tags that will be assigned to each resource"
}

variable "virtual_hub_id" {
  type        = string
  description = "Azure resource id for the virtual hub linked to the vnet spoke connection"
}