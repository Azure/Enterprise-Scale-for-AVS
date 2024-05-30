terraform {
  required_version = "~> 1.6"
  required_providers {
    azapi = {
      source = "azure/azapi"
      version = "= 1.12.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.105"
    }
  }
}