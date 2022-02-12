locals {
  deploymentName = "${var.PrimaryPrivateCloudName}-${random_string.namestring.result}"
}

resource "random_string" "namestring" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

resource "azurerm_resource_group_template_deployment" "avsCloudGlobalReachCrossRegion" {
  name                = local.deploymentName
  resource_group_name = var.PrimaryPrivateCloudResourceGroup
  deployment_mode     = "Incremental"

  parameters_content = jsonencode({
    "PrimaryPrivateCloudName" = {
      value = var.PrimaryPrivateCloudName
    },
    "SecondaryPrivateCloudName" = {
      value = var.SecondaryPrivateCloudName
    },
    "PrimaryPrivateCloudResourceGroup" = {
      value = var.PrimaryPrivateCloudResourceGroup
    },
    "SecondaryPrivateCloudResourceGroup" = {
      value = var.SecondaryPrivateCloudResourceGroup
    }
  })

  template_content = file(CrossAVSGlobalReach.deploy.json)

}