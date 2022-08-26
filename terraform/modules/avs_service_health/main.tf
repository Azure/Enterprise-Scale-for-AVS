locals {
  Alerts = [
    {
      Name : "CPU"
      Description : "CPU Usage per Cluster"
      Metric : "EffectiveCpuAverage"
      SplitDimension : "clustername"
      Threshold : 80
      Severity : 2
    },
    {
      Name : "Memory"
      Description : "Memory Usage per Cluster"
      Metric : "UsageAverage"
      SplitDimension : "clustername"
      Threshold : 80
      Severity : 2
    },
    {
      Name : "Storage"
      Description : "Storage Usage per Datastore"
      Metric : "DiskUsedPercentage"
      SplitDimension : "dsname"
      Threshold : 70
      Severity : 2
    },
    {
      Name : "StorageCritical"
      Description : "Storage Usage per Datastore"
      Metric : "DiskUsedPercentage"
      SplitDimension : "dsname"
      Threshold : 75
      Severity : 0
    }
  ]
}


resource "azurerm_monitor_action_group" "avs_service_health" {
  name                = var.action_group_name
  resource_group_name = var.rg_name
  short_name          = var.action_group_shortname

  dynamic "email_receiver" {
    for_each = toset(var.email_addresses)
    content {
      name          = trimspace(split("@", email_receiver.key)[0])
      email_address = trimspace(email_receiver.key)
    }
  }
}

resource "azurerm_monitor_activity_log_alert" "avs_rg_service_health" {
  name                = var.service_health_alert_name
  resource_group_name = var.rg_name
  scopes              = [var.service_health_alert_scope_id]
  description         = "This alert monitors service health for the AVS SDDC resource group."

  criteria {
    category = "ServiceHealth"

    service_health {
      locations = ["Global"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.avs_service_health.id
  }
}

resource "azurerm_monitor_metric_alert" "avs_metric_alerts" {
  for_each = { for alert in local.Alerts : alert.Name => alert }

  name                = each.value.Name
  resource_group_name = var.rg_name
  scopes              = [var.private_cloud_id]
  description         = each.value.Description
  severity            = each.value.Severity
  frequency           = "PT5M"
  window_size         = "PT30M"
  enabled             = true
  auto_mitigate       = true

  criteria {
    metric_namespace = "microsoft.avs/privateclouds"
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
    action_group_id = azurerm_monitor_action_group.avs_service_health.id
  }
}