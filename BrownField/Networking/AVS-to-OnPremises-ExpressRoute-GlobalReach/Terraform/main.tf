#The provider doesn't have an existing configuration here yet.  Confirm provider update status
#Is possible to call the ARM API template directly, but doesn't allow for destroy or tracking
locals {
  deploymentName = "${var.PrivateCloudName}-${var.ExpressRouteId}-${random_string.namestring.result}"
}

resource "random_string" "namestring" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}


resource "azurerm_resource_group_template_deployment" "avsGlobalReach" {
  name                = local.deploymentName
  resource_group_name = var.DeploymentResourceGroupName
  deployment_mode     = "Incremental"

  parameters_content = jsonencode({
    "PrivateCloudName" = {
      value = var.PrivateCloudName
    },
    "ExpressRouteAuthorizationKey" = {
      value = var.ExpressRouteAuthorizationKey
    },
    "ExpressRouteId" = {
      value = var.ExpressRouteId
    }

  })

  template_content = file(AVSGlobalReach.deploy.json)

}
