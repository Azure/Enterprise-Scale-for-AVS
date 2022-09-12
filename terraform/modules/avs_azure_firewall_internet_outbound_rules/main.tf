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

