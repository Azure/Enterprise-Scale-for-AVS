provider "azurerm" {
  alias      = "AVS-to-AVS-SameRegion"
  partner_id = "08d3edb1-3d70-4c0f-ab9f-f491b4a8d737"
  features {}
}

locals {
  deploymentName = "${var.PrimaryPrivateCloudName}-${random_string.namestring.result}"
}

resource "random_string" "namestring" {
  provider = azurerm.AVS-to-AVS-SameRegion
  length   = 4
  special  = false
  upper    = false
  lower    = true
}

resource "azurerm_resource_group_template_deployment" "avsCloudLinkSameRegion" {
  provider            = azurerm.AVS-to-AVS-SameRegion
  name                = local.deploymentName
  resource_group_name = var.PrimaryPrivateCloudResourceGroupName
  deployment_mode     = "Incremental"

  parameters_content = jsonencode({
    "PrimaryPrivateCloudName" = {
      value = var.PrimaryPrivateCloudName
    },
    "SecondaryPrivateCloudId" = {
      value = var.SecondaryPrivateCloudId
    }
  })

  template_content = file("${path.module}/CrossAVSWithinRegion.deploy.json")

}