# Configure the minimum required providers supported by this module

data "azurerm_client_config" "current" {}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.68.0"
    }
  }
}

## Optional settings to setup a terraform backend in Azure storage

# terraform {
#     backend "azurerm" {
#         resource_group_name = "replace me"   
#         storage_account_name = "replace me"
#         container_name = "replace me"
#         key = "terraform.tfstate"
#     }
# }

provider "azurerm" {
  features {}
}

# Create the AVS Private Cloud Resource Group
resource "azurerm_resource_group" "privatecloud" {
  name     = "${var.prefix}-PrivateCloud"
  location = "${var.region}"
}

# Create the Jumpbox Resource Group
resource "azurerm_resource_group" "jumpbox" {
  name     = "${var.prefix}-Jumpbox"
  location = "${var.region}"
}

# Create Network Resource Group
resource "azurerm_resource_group" "network" {
  name     = "${var.prefix}-Network"
  location = "${var.region}"
}
