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

provider "azurerm" {
  features {}
}