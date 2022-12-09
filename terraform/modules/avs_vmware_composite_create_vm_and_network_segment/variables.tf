variable "vmware_deployment" {
  description = "map of values for the terraform modules being built on vsphere and nsx"
}

variable "vmware_creds" {
  description = "map of credential values for the terraform provider"
  sensitive   = true
}