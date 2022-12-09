terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.00"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.1.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.30.0"
    }
  }
  /*
  backend "azurerm" {
    resource_group_name  = "<state storage account resource group name>"
    storage_account_name = "<state storage account name>"
    container_name       = "<state storage account container name>"
    key                  = "<state storage file name"

    use_azuread_auth = true
    subscription_id  = "<state storage account subscription id>"
    tenant_id        = "<state storage account tenant id>"
  }
  */
}

provider "azurerm" {
  features {}
}