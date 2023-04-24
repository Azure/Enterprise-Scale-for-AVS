variable "DeploymentResourceGroupName" {
  type        = string
  description = "Resource Group where the new connection resource will be created. Typically the resource group where the VNet Gateway is deployed"
}

variable "PrivateCloudName" {
  type        = string
  description = "The name of the existing Private Cloud that should be used to generate an authorization key"
}

variable "PrivateCloudResourceGroup" {
  type        = string
  description = "PrivateCloudResourceGroup"
}

/*
variable "PrivateCloudSubscriptionId" {
  type        = string
  description = "PrivateCloudSubscriptionId"
}
*/

variable "Location" {
  type        = string
  description = "The location of the gateway and the new connection"
}

variable "GatewayName" {
  type        = string
  description = "Name of the virtual network gateway being connected"
}