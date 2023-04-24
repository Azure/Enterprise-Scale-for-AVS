variable "PrimaryPrivateCloudName" {
  type        = string
  description = "Name of the existing primary private cloud that will contain the inter-private cloud link resource, must exist within this resource group"
}

variable "SecondaryPrivateCloudName" {
  type        = string
  description = "Name of the existing secondary private cloud that global reach will connect to"
}

variable "PrimaryPrivateCloudResourceGroup" {
  type        = string
  description = "Resource gorup name of the existing primary private cloud"
}

variable "SecondaryPrivateCloudResourceGroup" {
  type        = string
  description = "Resource gorup name of the existing secondary private cloud"
}
