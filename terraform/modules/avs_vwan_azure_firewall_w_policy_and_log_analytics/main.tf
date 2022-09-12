#firewall errors if not installed in the same resource group as the vnet with the firewall subnet
resource "azurerm_log_analytics_workspace" "simple" {
  name                = var.log_analytics_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

resource "azurerm_firewall_policy" "avs_base_policy" {
  name                = var.vwan_firewall_policy_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  dns {
    proxy_enabled = true
  }
}

resource "azurerm_firewall" "firewall" {
  name                = var.firewall_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku_name            = "AZFW_Hub"
  sku_tier            = var.firewall_sku_tier
  private_ip_ranges   = ["IANAPrivateRanges", ]
  firewall_policy_id  = azurerm_firewall_policy.avs_base_policy.id
  tags                = var.tags

  virtual_hub {
    virtual_hub_id  = var.virtual_hub_id
    public_ip_count = var.public_ip_count
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

