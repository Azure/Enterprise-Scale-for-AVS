# Configure the minimum required providers supported by this module

data "azurerm_client_config" "current" {}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.68"
    }
  }
}

provider "azurerm" {
  features {}
  partner_id = "754599a0-0a6f-424a-b4c5-1b12be198ae8"
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