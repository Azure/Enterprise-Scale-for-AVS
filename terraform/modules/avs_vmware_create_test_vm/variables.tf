variable "vsphere_datacenter" {
  type        = string
  description = "Name of the vsphere datacenter where vm will be deployed"
  default     = "SDDC-Datacenter"
}

variable "vsphere_datastore" {
  type        = string
  description = "Name of the vsphere datastore where vm will be deployed"
  default     = "vsanDatastore"
}

variable "ovf_content_library_name" {
  type        = string
  description = "Name for the local content library where OVF's will be imported for VM deployment"
  default     = "ovfContentLibrary"
}

variable "ovf_template_name" {
  type        = string
  description = "Name for the OVF template being downloaded to the content library"
}

variable "ovf_template_description" {
  type        = string
  description = "Description for the OVF template being downloaded to the content library"
}

variable "vsphere_cluster" {
  type        = string
  description = "Name of the vsphere cluster where vm will be deployed"
  default     = "Cluster-1"
}

variable "network_segment_display_name" {
  type        = string
  description = "Name of the network segment where this VM will be deployed"
}

variable "ovf_template_url" {
  type        = string
  description = "URL of the OVA or OVF being used as the template for the VM"
}

variable "vm_name" {
  type        = string
  description = "name for the new test vm"
}