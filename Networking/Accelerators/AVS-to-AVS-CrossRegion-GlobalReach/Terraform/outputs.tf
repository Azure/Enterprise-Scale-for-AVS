output "arm_template_output" {
  value = jsondecode(azurerm_resource_group_template_deployment.avsCloudGlobalReachCrossRegion.output_content)
}