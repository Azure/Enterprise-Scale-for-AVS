data "azurerm_client_config" "current" {}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.68.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "privatecloud" {
  name     = "${var.prefix}-PrivateCloud"
  location = "${var.region}"
}

# Create Resource Group
resource "azurerm_resource_group" "jumpbox" {
  name     = "${var.prefix}-Jumpbox"
  location = "${var.region}"
}

# Create Resource Group
resource "azurerm_resource_group" "network" {
  name     = "${var.prefix}-Network"
  location = "${var.region}"
}
