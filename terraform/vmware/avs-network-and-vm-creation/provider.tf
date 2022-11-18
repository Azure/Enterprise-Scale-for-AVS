# Provider
terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
    }
    vsphere = {
      source = "hashicorp/vsphere"
    }
  }
}

# Configure the VMware NSX-T Provider
provider "nsxt" {
  host                 = var.nsx_ip
  username             = var.nsx_username
  password             = var.nsx_password
  allow_unverified_ssl = true
}

# vSphere provider for vCenter and ESXi
provider "vsphere" {
  vsphere_server       = var.vsphere_server
  user                 = var.vsphere_user
  password             = var.vsphere_password
  allow_unverified_ssl = true
}
