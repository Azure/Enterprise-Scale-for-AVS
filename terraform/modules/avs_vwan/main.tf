resource "azurerm_virtual_wan" "vwan" {
  #create a vwan resource indexed with the VWAN name if the exists flag is false
  count = (var.vwan_already_exists ? 0 : 1)

  name                           = var.vwan_name
  resource_group_name            = var.rg_name
  location                       = var.rg_location
  allow_branch_to_branch_traffic = true
  type                           = "Standard"
  tags                           = var.tags
}

data "azurerm_virtual_wan" "vwan" {
  name                = var.vwan_name
  resource_group_name = var.rg_name
  depends_on = [
    azurerm_virtual_wan.vwan
  ]
}