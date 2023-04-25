variable "resourceGroupNameVnetGateway" {
  type        = string
  description = "The resource group name where the virtual network gateway is deployed"
}

variable "resourceGroupNameExpressRoute" {
  type        = string
  description = "The resource group name where the virtual existing ExpressRoute circuit is deployed"
}

variable "expressRouteName" {
  type        = string
  description = "The resource name for the ExpressRoute circuit"
}
variable "gatewayName" {
  type        = string
  description = "The existing virtual network gateway name"
}

variable "connectionName" {
  type        = string
  description = "The connection name to be created"
}

variable "expressRouteAuthorizationKey" {
  type        = string
  sensitive   = true
  description = "The Express Route Authorization Key to be redeemed by the connection"
}




