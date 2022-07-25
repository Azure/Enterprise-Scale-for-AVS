// Create an action group to be used by the service health alert
resource "azurerm_monitor_action_group" "actionGroup" {
  name                = "AVS-ServiceHealth-${random_string.uniqueString.result}"
  resource_group_name = data.azurerm_resource_group.avs-servicehealth.name
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
resource "azurerm_monitor_activity_log_alert" "avsServiceHealth" {
  name                = "AVS-ServiceHealth-${random_string.uniqueString.result}"
  resource_group_name = data.azurerm_resource_group.avs-servicehealth.name
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