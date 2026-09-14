data "vsphere_datacenter" "this" {
  name = var.datacenter_name
}

data "vsphere_compute_cluster" "this" {
  name          = var.compute_cluster_name
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_datastore" "this" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_network" "this" {
  for_each = toset(var.network_names)

  name          = each.value
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_virtual_machine" "ubuntu_template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.this.id
}

locals {
  cloud_init_metadata = yamlencode({
    "instance-id"    = var.vm_name
    "local-hostname" = var.vm_name
  })
}

resource "vsphere_virtual_machine" "ubuntu" {
  name             = var.vm_name
  folder           = var.folder
  resource_pool_id = data.vsphere_compute_cluster.this.resource_pool_id
  datastore_id     = data.vsphere_datastore.this.id

  num_cpus  = var.num_cpus
  memory    = var.memory_mb
  guest_id  = data.vsphere_virtual_machine.ubuntu_template.guest_id
  scsi_type = data.vsphere_virtual_machine.ubuntu_template.scsi_type
  firmware  = data.vsphere_virtual_machine.ubuntu_template.firmware

  wait_for_guest_ip_timeout  = var.wait_for_guest_ip_timeout
  wait_for_guest_net_timeout = var.wait_for_guest_net_timeout

  dynamic "network_interface" {
    for_each = var.network_names

    content {
      network_id   = data.vsphere_network.this[network_interface.value].id
      adapter_type = data.vsphere_virtual_machine.ubuntu_template.network_interface_types[0]
    }
  }

  dynamic "disk" {
    for_each = data.vsphere_virtual_machine.ubuntu_template.disks

    content {
      label            = disk.value.label
      unit_number      = disk.key
      size             = disk.value.size
      eagerly_scrub    = disk.value.eagerly_scrub
      thin_provisioned = disk.value.thin_provisioned
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.ubuntu_template.id
    linked_clone  = var.linked_clone
    timeout       = var.clone_timeout_minutes
  }

  extra_config = {
    "guestinfo.metadata"          = base64encode(local.cloud_init_metadata)
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(var.cloud_init_user_data)
    "guestinfo.userdata.encoding" = "base64"
  }

  extra_config_reboot_required = false
}
