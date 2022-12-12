#get the current transport zone overlay details
data "nsxt_policy_transport_zone" "overlay_tz" {
  display_name = "${var.nsxt_root}-OVERLAY-TZ"
}
#
# Create a workload segment or logical switch
# VMs can be attached to this CIDR
#
resource "nsxt_policy_segment" "vm_segment" {
  description         = var.vm_segment.description
  display_name        = var.vm_segment.display_name
  connectivity_path   = var.t1_gateway_path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path

  subnet {
    cidr        = var.vm_segment.subnet.cidr
    dhcp_ranges = var.vm_segment.subnet.dhcp_ranges

    dhcp_v4_config {
      server_address = var.vm_segment.subnet.dhcp_v4_config.server_address
      lease_time     = var.vm_segment.subnet.dhcp_v4_config.lease_time
      dns_servers    = var.vm_segment.subnet.dhcp_v4_config.dns_servers
    }
  }
  tag {
    scope = var.vm_segment.tag.scope
    tag   = var.vm_segment.tag.tag
  }
}