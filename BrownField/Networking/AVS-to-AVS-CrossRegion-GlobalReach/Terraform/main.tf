provider "azurerm" {
  alias      = "AVS-to-AVS-CrossRegion-GlobalReach"
  partner_id = "1593acc2-6932-462b-af58-28f7fa9df52d"
  features {}
}

locals {
  deploymentName = "${var.PrimaryPrivateCloudName}-${random_string.namestring.result}"
}

resource "random_string" "namestring" {
  provider = azurerm.AVS-to-AVS-CrossRegion-GlobalReach
  length   = 4
  special  = false
  upper    = false
  lower    = true
}

resource "azurerm_resource_group_template_deployment" "avsCloudGlobalReachCrossRegion" {
  provider            = azurerm.AVS-to-AVS-CrossRegion-GlobalReach
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

  template_content = file("${path.module}/CrossAVSGlobalReach.deploy.json")

}