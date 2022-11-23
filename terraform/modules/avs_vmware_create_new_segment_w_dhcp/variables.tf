variable "nsxt_root" {
  type        = string
  description = "AVS automation prefix used for managed networking components"
}

variable "vm_segment" {
  description = "map of strings and maps with vm segment configuration details"
}

variable "t1_gateway_path" {
  type        = string
  description = "Path value for the t1 gateway where this segment will be created"
}
