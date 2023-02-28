#-----------------------------------------------------------------
# DO NOT CHANGE
# Update any variables from the terraform.tfvars file as required
#-----------------------------------------------------------------

variable "prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "avs-networkblock" {
  type = string
}

variable "avs-sku" {
  type    = string
  default = "AV36"
}

variable "avs-hostcount" {
  type    = number
  default = 3
}

variable "adminusername" {
  type = string
}

variable "adminpassword" {
  type = string
}

variable "jumpboxsku" {
  type    = string
  default = "Standard_D2as_v4"
}

variable "vnetaddressspace" {
  type = string
}

variable "gatewaysubnet" {
  type = string
}

variable "azurebastionsubnet" {
  type = string
}

variable "jumpboxsubnet" {
  type = string
}

variable "hcx_key_names" {
  type        = list(string)
  description = "list of key names to use when generating hcx site activation keys."
  default     = []
}

variable "telemetry_enabled" {
  type        = bool
  description = "toggle the telemetry on/off for this module"
  default     = true
}
