#create a vnet with single subnet
resource "azurerm_virtual_network" "vwan_spoke_vnet" {
  name                = var.vwan_spoke_vnet_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  address_space       = var.vwan_spoke_vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "vwan_spoke_subnet" {
  for_each             = { for subnet in var.vwan_spoke_subnets : subnet.name => subnet }
  name                 = each.value.name
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vwan_spoke_vnet.name
  address_prefixes     = each.value.address_prefix
}

#create a vnet connection to the vwan hub
resource "azurerm_virtual_hub_connection" "vwan_spoke_connection" {
  name                      = var.virtual_hub_spoke_vnet_connection_name
  virtual_hub_id            = var.virtual_hub_id
  remote_virtual_network_id = azurerm_virtual_network.vwan_spoke_vnet.id
  internet_security_enabled = true
}

