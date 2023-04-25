#
# DHCP Profile for VMs
# 
resource "nsxt_policy_dhcp_server" "LUP-OCT22-DHCP" {
  display_name     = var.dhcp_profile.description
  description      = var.dhcp_profile.display_name
  server_addresses = ["${var.dhcp_profile.server_addresses}"]
}


#
# Create T1 Gateway
#
resource "nsxt_policy_tier1_gateway" "LUP-OCT22-T1GW" {
  display_name      = var.t1_gateway.display_name
  dhcp_config_path  = nsxt_policy_dhcp_server.LUP-OCT22-DHCP.path
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

#
# Create a workload segment or logical switch
# VMs can be attached to this CIDR
#
resource "nsxt_policy_segment" "LUP-OCT22-SEG" {
  description         = var.lup_oct22_segment.description
  display_name        = var.lup_oct22_segment.display_name
  connectivity_path   = nsxt_policy_tier1_gateway.LUP-OCT22-T1GW.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path

  subnet {
    cidr        = var.lup_oct22_segment.subnet.cidr
    dhcp_ranges = var.lup_oct22_segment.subnet.dhcp_ranges

    dhcp_v4_config {
      server_address = var.lup_oct22_segment.subnet.dhcp_v4_config.server_address
      lease_time     = var.lup_oct22_segment.subnet.dhcp_v4_config.lease_time
      dns_servers    = var.lup_oct22_segment.subnet.dhcp_v4_config.dns_servers
    }
  }
  tag {
    scope = var.lup_oct22_segment.tag.scope
    tag   = var.lup_oct22_segment.tag.tag
  }
}






