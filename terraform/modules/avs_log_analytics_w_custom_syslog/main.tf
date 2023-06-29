#Deploy the Log Analytics workspace
resource "azurerm_log_analytics_workspace" "avs_log_workspace" {
  name                = var.log_analytics_name
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

#create a custom table
resource "azapi_resource" "law_table" {
  name      = var.custom_table_name
  parent_id = azurerm_log_analytics_workspace.avs_log_workspace.id
  type      = "Microsoft.OperationalInsights/workspaces/tables@2022-10-01"
  body = jsonencode(
    {
      "properties" : {
        "plan" : "Analytics"
        "schema" : {
          "name" : "${var.custom_table_name}",
          "columns" : [
            {
              "name" : "Facility",
              "type" : "string"
            },
            {
              "name" : "LogCreationTime",
              "type" : "datetime"
            },
            {
              "name" : "TimeGenerated",
              "type" : "datetime"
            },
            {
              "name" : "ResourceId",
              "type" : "string"
            },
            {
              "name" : "Severity",
              "type" : "string"
            },
            {
              "name" : "Message",
              "type" : "string"
            },
            {
            "name" : "syslog_timestamp",
            "type" : "datetime"
            },
            {
            "name" : "syslog_host",
            "type" : "string"
            },
            {
            "name" : "syslog_program",
            "type" : "string"
            },
            {
            "name" : "syslog_subprogram",
            "type" : "string"
            },
            {
            "name" : "syslog_pid",
            "type" : "int"
            },
            {
            "name" : "syslog_loglevel",
            "type" : "string"
            },
            {
            "name" : "syslog_message",
            "type" : "string"
            },
            {
            "name" : "syslog_trans_id",
            "type" : "string"
            }
          ]
        }
      }
    }
  )
}


###########################################################################################################
# Create a data collection endpoint and data collection rule.  Authorize the service principal to the rule
###########################################################################################################

#Create the DCE
resource "azurerm_monitor_data_collection_endpoint" "avs_log_processing_dce" {
  name                          = var.data_collection_endpoint_name
  resource_group_name           = var.rg_name
  location                      = var.rg_location
  public_network_access_enabled = true
  description                   = "monitor_data_collection_endpoint for AVS log processing"
  tags                          = var.tags

  depends_on = [
    azapi_resource.law_table
  ]
}

#Create the DCR
resource "azurerm_monitor_data_collection_rule" "avs_log_processing_dcr" {
  name                        = var.data_collection_rule_name
  resource_group_name         = var.rg_name
  location                    = var.rg_location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.avs_log_processing_dce.id

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.avs_log_workspace.id
      name                  = azurerm_log_analytics_workspace.avs_log_workspace.name
    }
  }

  data_flow {
    streams       = ["Custom-${var.custom_table_name}"]
    destinations  = ["${azurerm_log_analytics_workspace.avs_log_workspace.name}"]
    output_stream = "Custom-${var.custom_table_name}"
    transform_kql = "source"
  }

  data_sources {}

  stream_declaration {
    stream_name = "Custom-${var.custom_table_name}"
    column {
      name = "Facility"
      type = "string"
    }
    column {
      name = "LogCreationTime"
      type = "datetime"
    }
    column {
      name = "TimeGenerated"
      type = "datetime"
    }
    column {
      name = "ResourceId"
      type = "string"
    }
    column {
      name = "Severity"
      type = "string"
    }
    column {
      name = "Message"
      type = "string"
    }
    column {
      name = "syslog_timestamp"
      type = "datetime"
    }
    column {
      name = "syslog_host"
      type = "string"
    }
    column {
      name = "syslog_program"
      type = "string"
    }
    column {
      name = "syslog_subprogram"
      type = "string"
    }
    column {
      name = "syslog_pid"
      type = "int"
    }
    column {
      name = "syslog_loglevel"
      type = "string"
    }
    column {
      name = "syslog_message"
      type = "string"
    }
    column {
      name = "syslog_trans_id"
      type = "string"
    }
  }

  description = "data collection rule example"
  tags        = var.tags
  depends_on = [
    azapi_resource.law_table
  ]
}

#Permission the DCR
resource "azurerm_role_assignment" "log_service_principal_dcr_assignment" {
  scope                = azurerm_monitor_data_collection_rule.avs_log_processing_dcr.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = var.log_processing_principal_object_id
  depends_on = [
    azapi_resource.law_table
  ]
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
  module_identifier                       = lower("avs_log_analytics_w_custom_syslog")
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