variable "nsx_ip" {
    type = string
    description = "NSX-T manager IP address"
}

variable "nsx_tag" {
  type = string
  default = "terraform-demo"
}

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