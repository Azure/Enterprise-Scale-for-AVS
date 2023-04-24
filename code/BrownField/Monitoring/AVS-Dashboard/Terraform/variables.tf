#-----------------------------------------------------------------
# DO NOT CHANGE
# Update any variables from the terraform.tfvars file as required
#-----------------------------------------------------------------

variable "createResourceGroup" {
  description = "Create the Resource Group ? (true/false)"
  type        = bool
  default     = "true"
}

variable "resourceGroupName" {
  description = "Name of the resource group to create"
  type        = string
}

variable "region" {
  description = "Location for this resource"
  type        = string
}

variable "dashboardName" {
  description = "The name of the dashboard to create"
  type        = string
  default     = "AVS Dashboard"
  validation {
    condition     = length(var.dashboardName) < 64
    error_message = "The dashboardName must be less than 64 characters in length."
  }
}

variable "privateCloudResourceId" {
  description = "'The full resource ID of the Private Cloud you want displayed on this dashboard"
  type        = string
}

variable "exRConnectionResourceId" {
  description = "Optional, The full resource ID of the Express Route Connection used by AVS that you want displayed on this dashboard. Can be left empty to remove this metric"
  type        = string
  default     = ""
}