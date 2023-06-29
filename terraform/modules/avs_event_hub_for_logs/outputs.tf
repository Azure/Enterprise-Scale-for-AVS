output "event_hub_connection_string" {
  value = azurerm_eventhub_authorization_rule.avs_log_processing.primary_connection_string
}

output "event_hub_consumer_group_name" {
  value = azurerm_eventhub_consumer_group.avs_log_processing.name
}

output "event_hub_storage_account_name" {
  value = azurerm_storage_account.avs_log_processing.primary_connection_string
}

output "event_hub_name" {
  value = azurerm_eventhub.avs_log_processing.name
}

output "event_hub_authorization_rule_id" {
  value = azurerm_eventhub_namespace_authorization_rule.avs_log_processing.id
}