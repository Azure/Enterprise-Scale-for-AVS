resource "random_password" "nsxt" {
  length           = 14
  special          = true
  number           = true
  override_special = "%@#"
  min_special = 1
  min_numeric = 1
  min_upper = 1
}

resource "random_password" "vcenter" {
  length           = 14
  special          = true
  number           = true
  override_special = "%@#"
  min_special = 1
  min_numeric = 1
  min_upper = 1
}


resource "azurerm_vmware_private_cloud" "privatecloud" {
  name                = "${var.prefix}-SDDC"
  resource_group_name = azurerm_resource_group.privatecloud.name
  location            = azurerm_resource_group.privatecloud.location
  sku_name            = var.avs-sku

  management_cluster {
    size = var.avs-hostcount
  }

  network_subnet_cidr         = "${var.avs-networkblock}"
  internet_connection_enabled = false
  nsxt_password               = random_password.nsxt.result
  vcenter_password            = random_password.vcenter.result
}

resource "azurerm_vmware_express_route_authorization" "expressrouteauthkey" {
  name             = "${var.prefix}-AVS"
  private_cloud_id = azurerm_vmware_private_cloud.privatecloud.id
}