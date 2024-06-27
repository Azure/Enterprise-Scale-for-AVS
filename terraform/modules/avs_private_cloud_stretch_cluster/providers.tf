terraform {
  required_version = "~> 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.105"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.13, != 1.13.0"
    }
  }
}

provider "azapi" {
  enable_hcl_output_for_data_source = true
}