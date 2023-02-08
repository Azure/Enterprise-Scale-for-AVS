# Create the Resource Group if asked to
resource "azurerm_resource_group" "avs-dashboard" {
  count    = var.createResourceGroup ? 1 : 0 # Only create if the variable is set
  name     = var.resourceGroupName
  location = var.region
}

data "azurerm_resource_group" "avs-dashboard" {
  name = var.resourceGroupName
  depends_on = [
    azurerm_resource_group.avs-dashboard
  ]
}