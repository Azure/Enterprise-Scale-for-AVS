terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.00"
    }
    azapi = {
      source = "azure/azapi"
    }
  }

/* uncomment this if using a storage backend
  backend "azurerm" {
    resource_group_name  = "<storage account resource group>"
    storage_account_name = "<storage account name>"
    container_name       = "<state blob container name>"
    key                  = "<state blob file name>"
    use_azuread_auth     = true
    subscription_id      = "<subscription id for the storage account>"
    tenant_id            = "<tenant id for the storage account>"
  }
*/
}

provider "azapi" {
}

provider "azuread" {
}

provider "azurerm" {
  features {}
}