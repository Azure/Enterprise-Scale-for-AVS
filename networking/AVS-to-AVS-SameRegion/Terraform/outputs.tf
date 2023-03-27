output "arm_template_output" {
  value = jsondecode(azurerm_resource_group_template_deployment.avsCloudLinkSameRegion.output_content)
}