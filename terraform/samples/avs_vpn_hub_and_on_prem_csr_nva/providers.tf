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

/*
  backend "azurerm" {
    resource_group_name  = "sample_tfstate_resource_group_name"
    storage_account_name = "samplestatestorage"
    container_name       = "sample_tfstate_container"
    key                  = "sample_state_file.tfstate"

    use_azuread_auth = true
    subscription_id  = "00000000-0000-0000-0000-000000000000"
    tenant_id        = "00000000-0000-0000-0000-000000000000"
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