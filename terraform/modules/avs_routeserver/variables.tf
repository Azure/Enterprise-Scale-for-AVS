variable "rg_name" {
  type        = string
  description = "The azure resource name for the resource group"
}

variable "rg_location" {
  description = "Resource Group region location"
  default     = "westus2"
}

variable "virtual_hub_name" {
  type        = string
  description = "The azure resource name for the virtual hub housing the route server"
}

variable "virtual_hub_pip_name" {
  type        = string
  description = "Azure resource name assigned to the virtual hub public ip"
}

variable "route_server_name" {
  type        = string
  description = "Azure resource name assigned to the routeserver"
}

variable "route_server_subnet_id" {
  type        = string
  description = "The full resource id for the route server subnet"
}