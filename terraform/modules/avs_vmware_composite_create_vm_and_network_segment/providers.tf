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
  host                 = var.vmware_creds.nsx.ip
  username             = var.vmware_creds.nsx.user
  password             = var.vmware_creds.nsx.password
  allow_unverified_ssl = true
}

# vSphere provider for vCenter and ESXi
provider "vsphere" {
  vsphere_server       = var.vmware_creds.vsphere.ip
  user                 = var.vmware_creds.vsphere.user
  password             = var.vmware_creds.vsphere.password
  allow_unverified_ssl = true
}