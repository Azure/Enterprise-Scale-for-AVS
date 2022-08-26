resource "azurerm_public_ip" "gatewaypip_1" {
  name                = var.vpn_pip_name_1
  resource_group_name = var.rg_name
  location            = var.rg_location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_public_ip" "gatewaypip_2" {
  name                = var.vpn_pip_name_2
  resource_group_name = var.rg_name
  location            = var.rg_location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_virtual_network_gateway" "gateway" {
  name                = var.vpn_gateway_name
  resource_group_name = var.rg_name
  location            = var.rg_location

  type       = "Vpn"
  vpn_type   = "RouteBased"
  sku        = var.vpn_gateway_sku
  generation = "Generation2"

  active_active = true
  enable_bgp    = true

  bgp_settings {
    asn = var.asn
  }


  ip_configuration {
    name                          = "${var.vpn_gateway_name}_active_1"
    public_ip_address_id          = azurerm_public_ip.gatewaypip_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  ip_configuration {
    name                          = "${var.vpn_gateway_name}_active_2"
    public_ip_address_id          = azurerm_public_ip.gatewaypip_2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }
}