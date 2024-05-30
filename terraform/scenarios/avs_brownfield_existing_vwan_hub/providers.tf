terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.105"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.13, != 1.13.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.50.0"
    }
  }

  #This block can be populated and uncommented if using Azure Storage for remote state
  /*
  backend "azurerm" {
    resource_group_name  = "<tfstate storage account resource group name>"
    storage_account_name = "<tfstate storage account name>"
    container_name       = "<tfstate blob container name>"
    key                  = "<tfstate file name>"
    use_azuread_auth     = true
    subscription_id      = "<subscription guid for the tfstate storage account>"
    tenant_id            = "<Azure AD tenant guid for the tfstate storage account>"
  }
*/
  required_version = ">= 1.6"
}

provider "azurerm" {
  #partner_id = "d8a06ade-2654-4a78-99da-e941f87a3a2a"
  features {}
}

provider "azapi" {
  enable_hcl_output_for_data_source = true
}