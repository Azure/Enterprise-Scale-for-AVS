terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.42.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "ed0a3e52-11f8-47a0-9748-c95e49a694e0"
  client_id = "d734e535-6499-46f3-bf64-e71fddb58a2c"
  client_secret = "kfx8Q~lVkuCFkbBz5E~D9d3M-LtYnJul5lgZ-dq5"
  tenant_id = "449fbe1d-9c99-4509-9014-4fd5cf25b014"
}

resource "azurerm_resource_group" "sblair_transit" {
  name     = "hub-resources"
  location = "Central US"
}

resource "azurerm_virtual_network" "sblair_vnet" {
  name                = "sblair-vnet"
  address_space       = ["10.1.0.0/24"]
  location            = azurerm_resource_group.sblair_transit.location
  resource_group_name = azurerm_resource_group.sblair_transit.name
}

