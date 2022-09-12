variable "rg_name" {
  type        = string
  description = "Resource Group Name where the vwan is deployed"
}

variable "rg_location" {
  type        = string
  description = "Resource Group location"
  default     = "westus2"
}

variable "vwan_name" {
  type        = string
  description = "Azure resource name assigned to the vwan"
  default     = ""
}

variable "vwan_already_exists" {
  type        = bool
  description = "Flag value that indicates whether a VWAN already exists. If set to false a new VWAN will be created"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "List of the tags that will be assigned to each resource"
}