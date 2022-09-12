#create a local gateway representing the AVS VWAN gateway
resource "azurerm_local_network_gateway" "this_local_gateway_0" {
  name                = var.local_gateway_name_0
  location            = var.rg_location
  resource_group_name = var.rg_name
  gateway_address     = var.remote_gateway_address_0
  address_space       = ["${var.local_gateway_bgp_ip}/32"]


  bgp_settings {
    asn                 = var.remote_asn
    bgp_peering_address = var.local_gateway_bgp_ip
  }
}

#create the remote connections 
resource "azurerm_virtual_network_gateway_connection" "on_prem_to_avs_hub_0" {
  name                = var.vnet_gateway_connection_name_0
  location            = var.rg_location
  resource_group_name = var.rg_name

  type                       = "IPsec"
  virtual_network_gateway_id = var.virtual_network_gateway_id
  local_network_gateway_id   = azurerm_local_network_gateway.this_local_gateway_0.id
  enable_bgp                 = true

  shared_key = var.shared_key
}
