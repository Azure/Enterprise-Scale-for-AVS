# # Provider
# terraform {
#   required_providers {
#     vsphere = {
#       source = "hashicorp/vsphere"
#     }
#   }
# }

# # vSphere provider for vCenter and ESXi
# provider "vsphere" {
#   vsphere_server       = var.vsphere_server
#   user                 = var.vsphere_user
#   password             = var.vsphere_password
#   allow_unverified_ssl = true
# }