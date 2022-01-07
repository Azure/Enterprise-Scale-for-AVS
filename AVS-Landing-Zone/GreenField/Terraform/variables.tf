#-----------------------------------------------------------------
# Variables
#-----------------------------------------------------------------

variable "prefix" {
  type    = string
}

variable "region" {
  type    = string
}

variable "avs-networkblock" {
  type    = string
}

variable "adminusername" {
  type    = string
}

variable "adminpassword" {
  type    = string
}

variable "jumpboxsku" {
  type    = string
  default = "Standard_D2as_v4"
}

variable "vnetaddressspace" {
  type    = string
}

variable "gatewaysubnet" {
  type    = string
}

variable "azurebastionsubnet" {
  type    = string
}

variable "jumpboxsubnet" {
  type    = string
}


