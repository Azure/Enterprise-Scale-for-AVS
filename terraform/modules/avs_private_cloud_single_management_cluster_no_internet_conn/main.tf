#generate a random password to use for the initial NSXT admin account password
resource "random_password" "nsxt" {
  length           = 14
  special          = true
  numeric          = true
  override_special = "%@#"
  min_special      = 1
  min_numeric      = 1
  min_upper        = 1
}

#generate a random password to use for the initial vcenter cloudadmin account password
resource "random_password" "vcenter" {
  length           = 14
  special          = true
  numeric          = true
  override_special = "%@#"
  min_special      = 1
  min_numeric      = 1
  min_upper        = 1
}

#Ensure the resource provider is properly registered
#resource "azurerm_resource_provider_registration" "AVS" {
#  name = "Microsoft.AVS"
#}

#create the initial private cloud with the VWAN internet connection disabled
#override the create timeout to address issues with the API retry limits and long-running deployments
resource "azurerm_vmware_private_cloud" "privatecloud" {
  name                = var.sddc_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  sku_name            = var.sddc_sku
  tags                = var.tags

  management_cluster {
    size = var.management_cluster_size
  }

  network_subnet_cidr         = var.avs_network_cidr
  internet_connection_enabled = false
  nsxt_password               = random_password.nsxt.result
  vcenter_password            = random_password.vcenter.result

  timeouts {
    create = "20h"
  }

  lifecycle {
    ignore_changes = [
      nsxt_password,
      vcenter_password
    ]
  }

  #depends_on = [
  #  azurerm_resource_provider_registration.AVS
  #]
}


#Generate an expressRoute authorization key for connection to Azure
resource "azurerm_vmware_express_route_authorization" "expressrouteauthkey" {
  name             = var.expressroute_authorization_key_name
  private_cloud_id = azurerm_vmware_private_cloud.privatecloud.id
}

