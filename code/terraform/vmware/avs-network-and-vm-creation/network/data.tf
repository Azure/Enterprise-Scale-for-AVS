# Data source
data "nsxt_policy_transport_zone" "overlay_tz" {
  display_name = var.overlay_tz.display_name
}

data "nsxt_policy_tier0_gateway" "t0_gateway" {
  display_name = var.t0_gateway.display_name
}

data "nsxt_policy_edge_cluster" "edge_cluster" {
  display_name = var.edge_cluster.display_name
}