rg_name                                     = "AvsLogFilterExample"
rg_location                                 = "Canada Central"
avs_log_processing_service_principal_name   = "AvsLogFilterSP"
eventhub_namespace_name                     = "avslogfilterehnamespace"
eventhub_capacity                           = 4
eventhub_name                               = "avslogfiltereh"
eventhub_partition_count                    = 2
eventhub_message_retention_days             = 3
diagnostic_eventhub_authorization_rule_name = "diagnosticSettingAuthRule"
logstash_eventhub_authorization_rule_name   = "logstashAuthRule"
consumer_group_name                         = "logstashConsumerGroup"
plugin_storage_account_name                 = "avslogfilterstgacct"
log_analytics_name                          = "avsLogAnalyticsWorkspace"
custom_table_name                           = "CustomAVSFilteredSyslog_CL"
data_collection_endpoint_name               = "AvsLogFilterDataCollectionEndpoint"
data_collection_rule_name                   = "AvsLogFilterDataCollectionRule"
diagnostics_setting_name                    = "AVSEventHubLogAnalytics"
private_cloud_resource_id                   = "<resourceID of the private cloud being monitored>"
logstash_subnet_id                          = "<resourceId of the subnet for the logstash processing vm>"
keyvault_name                               = "avslogkeyvault"

tags = {
  environment = "Dev"
  CreatedBy   = "Terraform"
}

logstash_vms = [
  {
    vm_name = "logstashvm1",
    vm_sku  = "Standard_E2as_v5"
  },
  {
    vm_name = "logstashvm2",
    vm_sku  = "Standard_E2as_v5"
  },
]

