variable "PrimaryPrivateCloudName" {
  type        = string
  sensitive   = true
  description = "Name of the existing primary private cloud that will contain the inter-private cloud link resource, must exist within this resource group"
}

variable "SecondaryPrivateCloudId" {
  type        = string
  description = "Full resource id of the secondary private cloud, must be in the same region as the primary"
}

variable "DeploymentResourceGroupName" {
  type        = string
  description = "Resource Group where the new globalReach resource will be created."
}