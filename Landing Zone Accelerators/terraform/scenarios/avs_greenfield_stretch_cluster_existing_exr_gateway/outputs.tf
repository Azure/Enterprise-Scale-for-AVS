output "sddc_id" {
  value = module.avs_private_cloud.sddc_id
}

output "sddc_vcsa_endpoint" {
  value = module.avs_private_cloud.sddc_vcsa_endpoint
}

output "sddc_nsxt_manager_endpoint" {
  value = module.avs_private_cloud.sddc_nsxt_manager_endpoint
}

output "sddc_hcx_cloud_manager_endpoint" {
  value = module.avs_private_cloud.sddc_hcx_cloud_manager_endpoint
}

output "sddc_provisioning_subnet_cidr" {
  value = module.avs_private_cloud.sddc_provisioning_subnet_cidr
}

/* #removing HCX output for now as pre-GA stretch clusters require a support case to activate HCX. 
#UnComment this section after the GA date
output "hcx_keys" {
  value = module.avs_private_cloud.hcx_keys
}
*/

output "full_cluster_details" {
  value = jsondecode(module.avs_private_cloud.full_cluster_details.output)
}