variable "datacenter_name" {
  type        = string
  description = "The name of the vSphere datacenter containing the target resources."

  validation {
    condition     = length(trimspace(var.datacenter_name)) > 0
    error_message = "datacenter_name must not be empty."
  }
}

variable "compute_cluster_name" {
  type        = string
  description = "The name of the vSphere compute cluster where the VM will run."

  validation {
    condition     = length(trimspace(var.compute_cluster_name)) > 0
    error_message = "compute_cluster_name must not be empty."
  }
}

variable "datastore_name" {
  type        = string
  description = "The name of the datastore where the VM will be created."

  validation {
    condition     = length(trimspace(var.datastore_name)) > 0
    error_message = "datastore_name must not be empty."
  }
}

variable "network_names" {
  type        = list(string)
  description = "An ordered list of one to seven distinct vSphere networks connected to the VM."

  validation {
    condition = (
      length(var.network_names) >= 1 &&
      length(var.network_names) <= 7 &&
      length(distinct(var.network_names)) == length(var.network_names) &&
      alltrue([for network_name in var.network_names : length(trimspace(network_name)) > 0])
    )
    error_message = "network_names must contain between one and seven unique, non-empty vSphere network names."
  }
}

variable "template_name" {
  type        = string
  description = "The inventory path or name of a cloud-init-enabled Ubuntu VM template."

  validation {
    condition     = length(trimspace(var.template_name)) > 0
    error_message = "template_name must not be empty."
  }
}

variable "vm_name" {
  type        = string
  description = "The name and cloud-init instance identifier of the Ubuntu VM."

  validation {
    condition     = length(trimspace(var.vm_name)) > 0 && length(var.vm_name) <= 63
    error_message = "vm_name must contain between 1 and 63 characters."
  }
}

variable "folder" {
  type        = string
  description = "Optional VM folder path relative to the datacenter VM folder."
  default     = null
  nullable    = true
}

variable "num_cpus" {
  type        = number
  description = "The number of virtual CPUs assigned to the VM."
  default     = 2

  validation {
    condition     = var.num_cpus >= 1 && floor(var.num_cpus) == var.num_cpus
    error_message = "num_cpus must be a positive whole number."
  }
}

variable "memory_mb" {
  type        = number
  description = "The amount of memory assigned to the VM in MiB."
  default     = 4096

  validation {
    condition     = var.memory_mb >= 512 && floor(var.memory_mb) == var.memory_mb
    error_message = "memory_mb must be a whole number of at least 512."
  }
}

variable "cloud_init_user_data" {
  type        = string
  description = "Cloud-init user-data passed to the Ubuntu guest through VMware GuestInfo."
  default     = "#cloud-config\n"

  validation {
    condition     = startswith(trimspace(var.cloud_init_user_data), "#cloud-config")
    error_message = "cloud_init_user_data must begin with #cloud-config."
  }
}

variable "linked_clone" {
  type        = bool
  description = "Create a linked clone. The source template must have exactly one snapshot when enabled."
  default     = false
}

variable "clone_timeout_minutes" {
  type        = number
  description = "The number of minutes to wait for the template clone operation."
  default     = 30

  validation {
    condition     = var.clone_timeout_minutes >= 10 && floor(var.clone_timeout_minutes) == var.clone_timeout_minutes
    error_message = "clone_timeout_minutes must be a whole number of at least 10."
  }
}

variable "wait_for_guest_ip_timeout" {
  type        = number
  description = "The number of minutes to wait for VMware Tools to report a guest IP; values below 1 disable the waiter."
  default     = 10
}

variable "wait_for_guest_net_timeout" {
  type        = number
  description = "The number of minutes to wait for VMware Tools to report routable guest networking; values below 1 disable the waiter."
  default     = 10
}
