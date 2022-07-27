locals {
  default_route_destinations = concat(["0.0.0.0/0"], var.private_range_prefixes)
}


#create a virtual hub
resource "azurerm_virtual_hub" "vwan_hub" {
  name                = var.vwan_hub_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  virtual_wan_id      = var.vwan_id
  address_prefix      = var.vwan_hub_address_prefix
  tags                = var.tags
}

resource "azurerm_express_route_gateway" "vwan_express_route_gateway" {
  name                = var.express_route_gateway_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  virtual_hub_id      = azurerm_virtual_hub.vwan_hub.id
  scale_units         = var.express_route_scale_units

  tags = var.tags
}

resource "azurerm_vpn_gateway" "vwan_vpn_gateway" {
  name                = var.vpn_gateway_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  virtual_hub_id      = azurerm_virtual_hub.vwan_hub.id
  scale_unit          = var.vpn_scale_units
}

resource "azurerm_express_route_connection" "avs_private_cloud_connection" {
  name                             = var.express_route_connection_name
  express_route_gateway_id         = azurerm_express_route_gateway.vwan_express_route_gateway.id
  express_route_circuit_peering_id = var.express_route_circuit_peering_id
  authorization_key                = var.express_route_authorization_key
  enable_internet_security         = var.all_branch_traffic_through_firewall #publish a default route to the internet through Azure Firewall when true
}

#add a 0/0 route pointing to the firewall in the default route table
resource "azurerm_virtual_hub_route_table_route" "default_secure_internet" {
  count          = var.all_branch_traffic_through_firewall ? 1 : 0 #push a default route if routing branch traffic to azfw in a secure hub
  route_table_id = azurerm_virtual_hub.vwan_hub.default_route_table_id

  name              = "default_route"
  destinations_type = "CIDR"
  destinations      = local.default_route_destinations
  next_hop_type     = "ResourceId"
  next_hop          = var.azure_firewall_id
}

