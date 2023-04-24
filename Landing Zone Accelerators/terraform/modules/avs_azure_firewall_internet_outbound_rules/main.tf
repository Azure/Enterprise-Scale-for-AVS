resource "azurerm_firewall_policy_rule_collection_group" "outbound_internet_test_group" {
  count              = var.has_firewall_policy ? 1 : 0
  name               = "outbound_internet_test_group"
  firewall_policy_id = var.firewall_policy_id
  priority           = 1111

  network_rule_collection {
    name     = "test_network_rule_collection_1"
    priority = 1111
    action   = "Allow"
    rule {
      name                  = "outbound_internet_and_branch_to_branch"
      protocols             = ["TCP", "UDP", "ICMP"]
      source_addresses      = var.private_range_prefixes
      destination_addresses = ["*"]
      destination_ports     = ["80", "443", "53", "123", "3389", "22"]
    }
  }
}

resource "azurerm_firewall_network_rule_collection" "outbound_internet_test_collection" {
  count               = var.has_firewall_policy ? 0 : 1
  name                = "test_network_rule_collection_1"
  azure_firewall_name = var.azure_firewall_name
  resource_group_name = var.azure_firewall_rg_name
  priority            = 1111
  action              = "Allow"

  rule {
    name                  = "outbound_internet_and_branch_to_branch"
    source_addresses      = var.private_range_prefixes
    destination_ports     = ["80", "443", "53", "123", "3389", "22"]
    destination_addresses = ["*"]
    protocols             = ["TCP", "UDP", "ICMP"]
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
  module_identifier                       = lower("avs_azure_firewall_internet_outbound_rules")
  telem_arm_deployment_name               = "${lower(var.guid_telemetry)}.${substr(local.module_identifier, 0, 20)}.${random_string.telemetry.result}"
}

#create a random string for uniqueness  
resource "random_string" "telemetry" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

data "azurerm_resource_group" "deployment" {
  name = var.azure_firewall_rg_name
}

resource "azurerm_subscription_template_deployment" "telemetry_core" {
  count = var.module_telemetry_enabled ? 1 : 0

  name             = local.telem_arm_deployment_name
  location         = data.azurerm_resource_group.deployment.location
  template_content = local.telem_arm_subscription_template_content
}