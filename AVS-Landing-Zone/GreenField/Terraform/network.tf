# This module creates the virtual network and required subnets

resource "azurerm_virtual_network" "network" {
  name                = "${var.prefix}-VNet"
  address_space       = [var.vnetaddressspace]
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
}

resource "azurerm_subnet" "gatewaysubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [var.gatewaysubnet]
}

resource "azurerm_subnet" "azurebastionsubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [var.azurebastionsubnet]
}

resource "azurerm_subnet_network_security_group_association" "this_bastion" {
  subnet_id                 = azurerm_subnet.azurebastionsubnet.id
  network_security_group_id = module.testnsg.nsg_resource.id
}

resource "azurerm_subnet" "jumpboxsubnet" {
  name                 = "JumpboxSubnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [var.jumpboxsubnet]  
}

resource "azurerm_subnet_network_security_group_association" "this_jumpbox" {
  subnet_id                 = azurerm_subnet.jumpboxsubnet.id
  network_security_group_id = module.testnsg.nsg_resource.id
  depends_on = [ azurerm_virtual_network.network, azurerm_subnet.jumpboxsubnet, module.testnsg ]
}

module "testnsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.1.1"

  enable_telemetry    = var.telemetry_enabled
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  name                = var.nsg_name
  nsgrules = { #allow all in this example, but set your 
    "rule01" : {
      "nsg_rule_access" : "Allow",
      "nsg_rule_destination_address_prefix" : "*",
      "nsg_rule_destination_port_range" : "*",
      "nsg_rule_direction" : "Inbound",
      "nsg_rule_priority" : 100,
      "nsg_rule_protocol" : "Tcp",
      "nsg_rule_source_address_prefix" : "*",
      "nsg_rule_source_port_range" : "*"
    },
    "rule02" : {
      "nsg_rule_access" : "Allow",
      "nsg_rule_destination_address_prefix" : "*",
      "nsg_rule_destination_port_range" : "*",
      "nsg_rule_direction" : "Outbound",
      "nsg_rule_priority" : 200,
      "nsg_rule_protocol" : "Tcp",
      "nsg_rule_source_address_prefix" : "*",
      "nsg_rule_source_port_range" : "*"
    }
  }
}