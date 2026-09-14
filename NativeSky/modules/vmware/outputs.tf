output "id" {
  description = "The BIOS UUID of the Ubuntu virtual machine."
  value       = vsphere_virtual_machine.ubuntu.id
}

output "uuid" {
  description = "The BIOS UUID reported by vSphere for the Ubuntu virtual machine."
  value       = vsphere_virtual_machine.ubuntu.uuid
}

output "moid" {
  description = "The vSphere managed object ID of the Ubuntu virtual machine."
  value       = vsphere_virtual_machine.ubuntu.moid
}

output "name" {
  description = "The name of the Ubuntu virtual machine."
  value       = vsphere_virtual_machine.ubuntu.name
}

output "default_ip_address" {
  description = "The default guest IP address reported by VMware Tools."
  value       = vsphere_virtual_machine.ubuntu.default_ip_address
}

output "guest_ip_addresses" {
  description = "All guest IP addresses reported by VMware Tools."
  value       = vsphere_virtual_machine.ubuntu.guest_ip_addresses
}

output "vmx_path" {
  description = "The datastore path to the virtual machine VMX file."
  value       = vsphere_virtual_machine.ubuntu.vmx_path
}
