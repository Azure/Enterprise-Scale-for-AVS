# Network configuration
nsx_ip       = "10.1.0.3"
nsx_username = "cloudadmin"
nsx_password = "xxxxxxxxxxxxxxx"
nsx_tag      = "LevelUp-NOV22"
dhcp_profile = {
  description      = "DHCP Profile"
  display_name     = "LUP-NOV22-DHCP"
  server_addresses = "192.168.0.2/27"
}
overlay_tz = {
  display_name = "TNT39-OVERLAY-TZ"
}
t0_gateway = {
  display_name = "TNT39-T0"
}
t1_gateway = {
  description      = "T1 Gateway"
  display_name     = "LUP-NOV22-T1GW"
  server_addresses = "192.168.0.2/27"
}
edge_cluster = {
  display_name = "TNT39-CLSTR"
}
lup_oct22_segment = {
  description  = "LUP NOV22 Segment"
  display_name = "LUP-NOV22-SEG"
  subnet = {
    cidr        = "192.168.1.1/24"
    dhcp_ranges = ["192.168.1.4-192.168.1.20"]
    dhcp_v4_config = {
      server_address = "192.168.0.2/27"
      lease_time     = 86400
      dns_servers    = ["10.179.0.192"]
    }
  }
  tag = {
    scope = "LevelUp"
    tag   = "NOV22"
  }
}

# VM configuration
vsphere_datacenter = "SDDC-Datacenter"
vsphere_server     = "10.1.0.2"
vsphere_user       = "cloudadmin@vsphere.local"
vsphere_password   = "xxxxxxx"
vm-name            = "levelup-vm"
datastore          = "vsanDatastore"
host               = "esx21-xxxxxxxxxxxx.canadacentral.avs.azure.com"
network            = "LUP-NOV22-SEG"
