variable "DeploymentResourceGroupName" {
  type        = string
  description = "Resource Group where the new gateway vnet and resources will be created."
}

variable "PrivateCloudName" {
  type        = string
  description = "The name of the existing Private Cloud that should be used to generate an authorization key"
}

variable "PrivateCloudResourceGroup" {
  type        = string
  description = "PrivateCloudResourceGroup"
}

variable "PrivateCloudSubscriptionId" {
  type        = string
  description = "PrivateCloudSubscriptionId"
}

variable "Location" {
  type        = string
  description = "The location the new virtual network & gateway should reside in"
}

variable "VNetName" {
  type        = string
  description = "Name of the virtual network to be created"
}

variable "VNetAddressSpaceCIDR" {
  type        = list(string)
  description = "Address space for the virtual network to be created, should be a valid non-overlapping CIDR block in the format: 10.0.0.0/16"
}

variable "VNetGatewaySubnetCIDR" {
  type        = list(string)
  description = "Subnet to be used for the virtual network gateway, should be a valid CIDR block within the address space provided above, in the format: 10.0.0.0/24"
}

variable "GatewayName" {
  type        = string
  description = "Name of the virtual network gateway to be created"
}

variable "GatewaySku" {
  type        = string
  description = "Virtual network gateway SKU to be created"

}