#The provider doesn't have an existing configuration here yet.  Confirm provider update status
#Is possible to call the ARM API template directly, but doesn't allow for destroy or tracking
provider "azurerm" {
  alias      = "AVS-to-OnPremises-ExpressRoute-GlobalReach"
  partner_id = "8fb78b9c-973d-45d1-bd35-fcad3c00e09e"
  features {}
}

locals {
  deploymentName = "${var.PrivateCloudName}-${random_string.namestring.result}"
}

#use to generate random subscript for deployments
resource "random_string" "namestring" {
  provider = azurerm.AVS-to-OnPremises-ExpressRoute-GlobalReach
  length   = 4
  special  = false
  upper    = false
  lower    = true
}

resource "azurerm_resource_group_template_deployment" "avsGlobalReach" {
  provider            = azurerm.AVS-to-OnPremises-ExpressRoute-GlobalReach
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

  template_content = file("${path.module}/AVSGlobalReach.deploy.json")

}
