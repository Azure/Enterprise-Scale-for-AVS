#firewall errors if not installed in the same resource group as the vnet with the firewall subnet
#passing the resource group details in as a variable and creating a manual depends on reference

resource "azurerm_log_analytics_workspace" "simple" {
  name                = var.log_analytics_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

resource "azurerm_public_ip" "firewall_pip" {
  name                = var.firewall_pip_name
  location            = var.rg_location
  resource_group_name = var.rg_name

  allocation_method = "Static"
  sku               = "Standard"
  tags              = var.tags
}

resource "azurerm_firewall" "firewall" {
  name                = var.firewall_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.firewall_sku_tier
  private_ip_ranges   = ["IANAPrivateRanges", ]
  tags                = var.tags
  firewall_policy_id  = azurerm_firewall_policy.avs_base_policy.id

  ip_configuration {
    name                 = "${var.firewall_name}-ipconfiguration1"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }
}

resource "azurerm_firewall_policy" "avs_base_policy" {
  name                = var.firewall_policy_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  dns {
    proxy_enabled = true
  }
}

#configure the firewall to send logs to a log analytics workspace
resource "azurerm_monitor_diagnostic_setting" "firewall_metrics" {
  name                           = "${var.firewall_name}-diagnostic-setting"
  target_resource_id             = azurerm_firewall.firewall.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.simple.id
  log_analytics_destination_type = "AzureDiagnostics"

  log {
    category = "AzureFirewallApplicationRule"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AzureFirewallNetworkRule"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AzureFirewallDnsProxy"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWNetworkRule"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWApplicationRule"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWNatRule"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWThreatIntel"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWIdpsSignature"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWDnsQuery"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWFqdnResolveFailure"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWApplicationRuleAggregation"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWNetworkRuleAggregation"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWNatRuleAggregation"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}

#############################################################################################
# Telemetry Section - Toggled on and off with the telemetry variable
# This allows us to get deployment frequency statistics for deployments
# Re-using parts of the Core Enterprise Landing Zone methodology
#############################################################################################
locals {
  #create an empty ARM template to use for generating the deployment value
  telem_arm_subscription_template_content = <<TEMPLATE
    {
      "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {},
      "variables": {},
      "resources": [],
      "outputs": {
        "telemetry": {
          "type": "String",
          "value": "For more information, see https://aka.ms/alz/tf/telemetry"
        }
      }
    }
    TEMPLATE
  module_identifier                       = lower("avs_azure_firewall_w_log_analytics")
  telem_arm_deployment_name               = "${lower(var.guid_telemetry)}.${substr(local.module_identifier, 0, 20)}.${random_string.telemetry.result}"
}

#create a random string for uniqueness  
resource "random_string" "telemetry" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

resource "azurerm_subscription_template_deployment" "telemetry_core" {
  count = var.module_telemetry_enabled ? 1 : 0

  name             = local.telem_arm_deployment_name
  location         = var.rg_location
  template_content = local.telem_arm_subscription_template_content
}