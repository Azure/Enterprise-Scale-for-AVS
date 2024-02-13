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

/* uncomment this if using a storage account for tfstate
  backend "azurerm" {
    resource_group_name  = "<tfstate_rg_name>"
    storage_account_name = "<tfstate_stg_acct_name>"
    container_name       = "<tfstate_container_name"
    key                  = "<tfstate_file_name>"
    use_azuread_auth     = true
    subscription_id      = "<tfstate_subscription_guid>"
    tenant_id            = "<tfstate_tenant_guid>"
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