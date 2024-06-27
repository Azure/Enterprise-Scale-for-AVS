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
  enable_hcl_output_for_data_source = true
}

provider "azuread" {
}

provider "azurerm" {
  features {}
}