#get current datacenter and datatstore information
data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "default" {
  name          = format("%s%s", data.vsphere_compute_cluster.cluster.name, "/Resources")
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.network_segment_display_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

#create a content library for storing the OVF files to work around the issue where a host is required but can't be discovered dynamically by terraform
resource "vsphere_content_library" "publisher_content_library" {
  name            = var.ovf_content_library_name
  description     = "Content Library for VM OVF's"
  storage_backing = [data.vsphere_datastore.datastore.id]
}

#import the OVF into the content library
resource "vsphere_content_library_item" "content_library_item" {
  name        = var.ovf_template_name
  description = var.ovf_template_description
  file_url    = var.ovf_template_url
  library_id  = vsphere_content_library.publisher_content_library.id
}

#create the VM using the OVF UUID - Assumes the template networking DHCP matches the OVF/OVA
resource "vsphere_virtual_machine" "labvm01" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  #datacenter_id    = data.vsphere_datacenter.datacenter.id
  datastore_id = data.vsphere_datastore.datastore.id
  num_cpus     = 4
  memory       = 16384

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = 16384
  }

  clone {
    template_uuid = vsphere_content_library_item.content_library_item.id
  }

}