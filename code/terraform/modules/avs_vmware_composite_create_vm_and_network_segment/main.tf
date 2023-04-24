
module "avs_vmware_create_new_t1_gateway_w_dhcp" {
  source                  = "../avs_vmware_create_new_t1_gateway"
  nsxt_root               = var.vmware_deployment.nsxt_root
  t1_gateway_display_name = var.vmware_deployment.t1_gateway_display_name
  dhcp_profile            = var.vmware_deployment.dhcp_profile
}

module "avs_vmware_create_new_segment_w_dhcp" {
  source          = "../avs_vmware_create_new_segment"
  nsxt_root       = var.vmware_deployment.nsxt_root
  vm_segment      = var.vmware_deployment.vm_segment
  t1_gateway_path = module.avs_vmware_create_new_t1_gateway.t1_gateway_path

  depends_on = [
    module.avs_vmware_create_new_t1_gateway_w_dhcp
  ]
}

resource "time_sleep" "wait_90_seconds" {
  depends_on      = [module.avs_vmware_create_new_segment_w_dhcp]
  create_duration = "90s"
}

module "avs_vmware_create_test_vm" {
  source                       = "../avs_vmware_create_test_vm"
  vsphere_datacenter           = var.vmware_deployment.vsphere_datacenter
  vsphere_datastore            = var.vmware_deployment.vsphere_datastore
  ovf_content_library_name     = var.vmware_deployment.ovf_content_library_name
  ovf_template_name            = var.vmware_deployment.ovf_template_name
  ovf_template_description     = var.vmware_deployment.ovf_template_description
  ovf_template_url             = var.vmware_deployment.ovf_template_url
  vsphere_cluster              = var.vmware_deployment.vsphere_cluster
  network_segment_display_name = module.avs_vmware_create_new_segment_w_dhcp.vm_segment_display_name
  vm_name                      = var.vmware_deployment.vm_name

  depends_on = [
    time_sleep.wait_90_seconds
  ]
}
