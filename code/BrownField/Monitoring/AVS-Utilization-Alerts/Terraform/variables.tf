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

variable "actionGroupName" {
  description = "Name of the action group to be created"
  type        = string
  default     = "AVSAlerts"
}

variable "alertPrefix" {
  description = "Prefix to use for alert creation"
  type        = string
  default     = "AVSAlert"
}

variable "actionGroupEmails" {
  description = "Email addresses to be added to the action group. Use the format [\"name1@domain.com\",\"name2@domain.com\"]"
  type        = list(string)
}

variable "privateCloudResourceId" {
  description = "The existing Private Cloud full resource id"
  type        = string
}


# Define the alerts that will be created as resources
locals {
  alerts = {
    "CPU" = {
      Description    = "CPU Usage per Cluster"
      Metric         = "EffectiveCpuAverage"
      SplitDimension = "clustername"
      Threshold      = 80
      Severity       = 2
    },
    "Memory" = {
      Description    = "Memory Usage per Cluster"
      Metric         = "UsageAverage"
      SplitDimension = "clustername"
      Threshold      = 80
      Severity       = 2
    },
    "Storage" = {
      Description    = "Storage Usage per Datastore"
      Metric         = "DiskUsedPercentage"
      SplitDimension = "dsname"
      Threshold      = 70
      Severity       = 2
    },
    "StorageCritical" = {
      Description    = "Storage Usage per Datastore"
      Metric         = "DiskUsedPercentage"
      SplitDimension = "dsname"
      Threshold      = 75
      Severity       = 0
    }
  }
}
