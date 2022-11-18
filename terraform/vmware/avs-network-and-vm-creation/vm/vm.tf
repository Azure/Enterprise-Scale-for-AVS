##
## Deployment of PhotonOS VM from Remote OVF
##

resource "vsphere_folder" "folder" {
  path          = "Workloads"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

resource "vsphere_virtual_machine" "testvm01" {
  name                 = var.vm-name
  folder               = trimprefix(vsphere_folder.folder.path, "/${data.vsphere_datacenter.datacenter.name}/vm")
  datacenter_id        = data.vsphere_datacenter.datacenter.id
  datastore_id         = data.vsphere_datastore.datastore.id
  host_system_id       = data.vsphere_host.host.id
  resource_pool_id     = data.vsphere_resource_pool.pool.id
  num_cpus             = data.vsphere_ovf_vm_template.photon_ovf.num_cpus
  num_cores_per_socket = data.vsphere_ovf_vm_template.photon_ovf.num_cores_per_socket
  memory               = data.vsphere_ovf_vm_template.photon_ovf.memory
  guest_id             = data.vsphere_ovf_vm_template.photon_ovf.guest_id
  scsi_type            = data.vsphere_ovf_vm_template.photon_ovf.scsi_type
  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.photon_ovf.ovf_network_map
    content {
        network_id = network_interface.value
    }
  }
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0

  ovf_deploy {
      allow_unverified_ssl_cert = false
      remote_ovf_url            = data.vsphere_ovf_vm_template.photon_ovf.remote_ovf_url
      disk_provisioning         = data.vsphere_ovf_vm_template.photon_ovf.disk_provisioning
      ovf_network_map           = data.vsphere_ovf_vm_template.photon_ovf.ovf_network_map
      ip_protocol               = "IPV4"
      ip_allocation_policy      = "STATIC_MANUAL"
  }

  lifecycle {
      ignore_changes = [
      annotation,
      disk[0].io_share_count,
      disk[1].io_share_count,
      disk[2].io_share_count,
      vapp[0].properties,
      ]
  }
}
