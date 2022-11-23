
#Get existing AVS NSXT data details
data "nsxt_policy_tier0_gateway" "t0_gateway" {
  display_name = "${var.nsxt_root}-T0"
}

data "nsxt_policy_edge_cluster" "edge_cluster" {
  display_name = "${var.nsxt_root}-CLSTR"
}

resource "nsxt_policy_dhcp_server" "dhcp_profile" {
  display_name     = var.dhcp_profile.description
  description      = var.dhcp_profile.display_name
  server_addresses = [var.dhcp_profile.server_addresses]
}


#
# Create T1 Gateway
#
resource "nsxt_policy_tier1_gateway" "t1_gateway" {
  display_name      = var.t1_gateway_display_name
  dhcp_config_path  = nsxt_policy_dhcp_server.dhcp_profile.path
  tier0_path        = data.nsxt_policy_tier0_gateway.t0_gateway.path
  edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster.path
  failover_mode     = "NON_PREEMPTIVE"
  route_advertisement_types = [
    "TIER1_CONNECTED",
    "TIER1_DNS_FORWARDER_IP",
    "TIER1_IPSEC_LOCAL_ENDPOINT",
    "TIER1_LB_SNAT",
    "TIER1_LB_VIP",
    "TIER1_NAT",
    "TIER1_STATIC_ROUTES"
  ]
}