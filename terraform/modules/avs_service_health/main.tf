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
      Name : "CPUCritical"
      Description : "CPU Usage per Cluster - Critical"
      Metric : "EffectiveCpuAverage"
      SplitDimension : "clustername"
      Threshold : 95
      Severity : 0
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
      Name : "MemoryCritical"
      Description : "Memory Usage per Cluster - Critical"
      Metric : "UsageAverage"
      SplitDimension : "clustername"
      Threshold : 95
      Severity : 0
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
  module_identifier                       = lower("avs_service_health")
  telem_arm_deployment_name               = "${lower(var.guid_telemetry)}.${substr(local.module_identifier, 0, 20)}.${random_string.telemetry.result}"
}

data "azurerm_resource_group" "deployment" {
  name = var.rg_name
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
  location         = data.azurerm_resource_group.deployment.location
  template_content = local.telem_arm_subscription_template_content
}