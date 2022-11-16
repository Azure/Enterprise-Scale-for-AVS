# Provider
terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
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