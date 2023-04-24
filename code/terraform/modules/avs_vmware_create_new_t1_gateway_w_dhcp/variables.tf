variable "nsxt_root" {
  type        = string
  description = "AVS root value used in t0, edge, and transport overlay naming"
}

variable "t1_gateway_display_name" {
  type        = string
  description = "Display name for the new T1 gateway"
}

variable "dhcp_profile" {
  description = "map of strings used to create the dhcp profile"
}

