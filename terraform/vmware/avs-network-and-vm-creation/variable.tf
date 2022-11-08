# Network variables
variable "nsx_ip" {
  type        = string
  description = "NSX-T manager IP address"
}

variable "nsx_tag" {}

variable "nsx_username" {
  description = "NSX-T administrator username"
  type        = string
  sensitive   = true
}

variable "nsx_password" {
  description = "NSX-T administrator password"
  type        = string
  sensitive   = true
}

variable "dhcp_profile" {}
variable "overlay_tz" {}
variable "edge_cluster" {}
variable "t0_gateway" {}
variable "t1_gateway" {}
variable "lup_oct22_segment" {}

# VM Variables
variable "vsphere_datacenter" {
  type = string
}

variable "vsphere_server" {
  type = string
}
variable "vsphere_user" {
  type = string
}
variable "vsphere_password" {
  type = string
}

variable "vm-name" {
  type = string
}

variable "datastore" {
  type = string  
  default = "vsanDatastore"
}

variable "cluster" {
  type = string  
  default = "Cluster-1"
}

variable "host" {
  type = string  
  default = "testvm"
}
variable "network" {
  type = string  
}

