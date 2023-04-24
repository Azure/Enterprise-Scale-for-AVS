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
  description = "Name of the region to create the resource group in (not mandatory if reusing existant resource group)"
  type        = string
  default     = "" # not mandatory if reusing existant resource group
}

variable "actionGroupEmails" {
  description = "Email addresses to be added to the action group. Use the format [\"name1@domain.com\",\"name2@domain.com\"]"
  type        = list(string)
}

variable "privateCloudResourceId" {
  description = "The existing Private Cloud full resource id"
  type        = string
}