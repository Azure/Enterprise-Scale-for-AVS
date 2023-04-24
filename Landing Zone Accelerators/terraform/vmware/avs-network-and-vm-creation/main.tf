module "network" {
  source            = "./network"
  nsx_ip            = var.nsx_ip
  nsx_username      = var.nsx_username
  nsx_password      = var.nsx_password
  nsx_tag           = var.nsx_tag
  dhcp_profile      = var.dhcp_profile
  overlay_tz        = var.overlay_tz
  t0_gateway        = var.t0_gateway
  t1_gateway        = var.t1_gateway
  edge_cluster      = var.edge_cluster
  lup_oct22_segment = var.lup_oct22_segment
}

resource "time_sleep" "wait_90_seconds" {
  depends_on      = [module.network]
  create_duration = "90s"
}

module "vm" {
  source             = "./vm"
  vsphere_datacenter = var.vsphere_datacenter
  vsphere_server     = var.vsphere_server
  vsphere_user       = var.vsphere_user
  vsphere_password   = var.vsphere_password
  network            = module.network.segment
  host               = var.host
  depends_on = [
    time_sleep.wait_90_seconds
  ]
}
