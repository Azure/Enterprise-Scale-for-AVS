variable "expressroute_pip_name" {
  type        = string
  description = "Azure resource name assigned to the expressroute public ip"
}
variable "expressroute_gateway_name" {
  type        = string
  description = "Azure resource name assigned to the AVS expressroute gateway instance"
}
variable "expressroute_gateway_sku" {
  type        = string
  description = "The sku for the AVS expressroute gateway"
  default     = "Standard"
}

variable "rg_name" {
  type        = string
  description = "Resource Group Name where the expressroute gateway and the associated public ip are being deployed"
}
variable "rg_location" {
  type        = string
  description = "Resource Group location"
  default     = "westus2"
}
variable "gateway_subnet_id" {
  type        = string
  description = "The full resource id for the subnet where the bastion will be deployed"
}

variable "express_route_connection_name" {
  type        = string
  description = "Azure resource name for the express_route connection to the AVS private cloud"
}

variable "express_route_id" {
  type        = string
  description = "Azure resource id for the AVS express_route"
}

variable "express_route_authorization_key" {
  type        = string
  description = "AVS private cloud express route authorization key"
}



