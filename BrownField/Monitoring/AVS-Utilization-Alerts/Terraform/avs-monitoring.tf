// Create an action group to be used by the alerts
resource "azurerm_monitor_action_group" "actionGroup" {
  name                = var.actionGroupName
  resource_group_name = data.azurerm_resource_group.avs-alerts.name
  short_name          = "avs${random_string.uniqueString.result}"

  dynamic "email_receiver" {
    for_each = var.actionGroupEmails

    content {
      name                    = split("@", email_receiver.value)[0]
      email_address           = email_receiver.value
      use_common_alert_schema = false
    }
  }
}

// Deploy service health alerts
resource "azurerm_monitor_activity_log_alert" "avsMonitoring" {
  name                = "${var.alertPrefix}-ServiceHealth"
  resource_group_name = data.azurerm_resource_group.avs-alerts.name
  scopes              = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
  description         = "Service Health Alerts"
  enabled             = true

  criteria {
    category = "ServiceHealth"
    service_health {
      locations = ["Global"]
      services = [
        "Azure VMware Solution"
      ]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.actionGroup.id
  }
}

resource "azurerm_monitor_metric_alert" "avsMetricAlert" {
  for_each            = local.alerts
  name                = "${var.alertPrefix}-${each.key}"
  resource_group_name = data.azurerm_resource_group.avs-alerts.name
  scopes              = [var.privateCloudResourceId]
  description         = each.value.Description
  enabled             = true
  window_size         = "PT30M"
  frequency           = "PT5M"
  auto_mitigate       = true
  severity            = each.value.Severity

  criteria {
    metric_namespace = "Microsoft.AVS/privateClouds"
    metric_name      = each.value.Metric
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = each.value.Threshold
    dimension {
      name     = each.value.SplitDimension
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.actionGroup.id
  }
}