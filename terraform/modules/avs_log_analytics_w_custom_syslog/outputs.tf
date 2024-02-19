output "logs_ingestion_endpoint" {
  value = azurerm_monitor_data_collection_endpoint.avs_log_processing_dce.logs_ingestion_endpoint
}

output "dcr_immutable_id" {
  value = azurerm_monitor_data_collection_rule.avs_log_processing_dcr.immutable_id
}

output "dcr_stream_name" {
  value = "Custom-${var.custom_table_name}"
}