locals {
  deploymentName = "${var.PrimaryPrivateCloudName}-${random_string.namestring.result}"
}

resource "random_string" "namestring" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

resource "azurerm_resource_group_template_deployment" "avsCloudLinkSameRegion" {
  name                = local.deploymentName
  resource_group_name = var.DeploymentResourceGroupName
  deployment_mode     = "Incremental"

  parameters_content = jsonencode({
    "PrimaryPrivateCloudName" = {
      value = var.PrimaryPrivateCloudName
    },
    "SecondaryPrivateCloudId" = {
      value = var.SecondaryPrivateCloudId
    }
  })

  template_content = file(CrossAVSWithinRegion.deploy.json)

}