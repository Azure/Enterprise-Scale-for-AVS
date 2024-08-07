data "template_file" "node_config" {
  template = file("${path.module}/templates/ios_config_vpn_one_nic.txt")

  vars = {
    asn                       = var.asn
    pre_shared_key            = var.pre_shared_key
    csr_bgp_ip                = var.csr_bgp_ip
    csr_tunnel_ip_0           = cidrhost(var.csr_tunnel_cidr, 1)
    csr_tunnel_ip_1           = cidrhost(var.csr_tunnel_cidr, 2)
    csr_vnet                  = (split("/", var.csr_vnet_cidr))[0]
    csr_vnet_mask             = cidrnetmask(var.csr_vnet_cidr)
    csr_subnet_gateway        = cidrhost(var.csr_subnet_cidr, 1)
    remote_gw_pubip0          = var.remote_gw_pubip0
    remote_gw_pubip1          = var.remote_gw_pubip1
    remote_bgp_peer_ip_0      = var.remote_bgp_peer_ip_0
    remote_bgp_peer_ip_mask_0 = "255.255.255.255"
    remote_bgp_peer_ip_1      = var.remote_bgp_peer_ip_1
    remote_bgp_peer_ip_mask_1 = "255.255.255.255"

  }

  depends_on = [
    azurerm_public_ip.gatewaypip_1
  ]
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.node_config.rendered
  }
}

resource "azurerm_public_ip" "gatewaypip_1" {
  name                = var.vpn_pip_name_1
  resource_group_name = var.rg_name
  location            = var.rg_location
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "node0_csr_nic0" {
  name                 = "${var.node0_name}-nic-0"
  location             = var.rg_location
  resource_group_name  = var.rg_name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.fw_facing_subnet_id
    public_ip_address_id          = azurerm_public_ip.gatewaypip_1.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
}

resource "azurerm_linux_virtual_machine" "csr1000v_node0" {
  name                            = var.node0_name
  resource_group_name             = var.rg_name
  location                        = var.rg_location
  size                            = "Standard_DS2_v2"
  admin_username                  = "azureuser"
  admin_password                  = random_password.admin_password.result
  disable_password_authentication = false
  custom_data                     = data.template_cloudinit_config.config.rendered
  zone                            = var.zone

  network_interface_ids = [
    azurerm_network_interface.node0_csr_nic0.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = "17_3_3-byol"
    product   = "cisco-csr-1000v"
    publisher = "cisco"
  }

  source_image_reference {
    publisher = "cisco"
    offer     = "cisco-csr-1000v"
    sku       = "17_3_3-byol"
    version   = "latest"
  }
}



resource "random_password" "admin_password" {
  length  = 20
  special = false
  upper   = true
  lower   = true
}


#write secret to keyvault
resource "azurerm_key_vault_secret" "admin_password" {
  name         = "csr-azureuser-password"
  value        = random_password.admin_password.result
  key_vault_id = var.keyvault_id
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
  module_identifier                       = lower("avs_nva_cisco_1000v_vpn_config_one_node")
  telem_arm_deployment_name               = "${lower(var.guid_telemetry)}.${substr(local.module_identifier, 0, 20)}.${random_string.telemetry.result}"
}

#create a random string for uniqueness  
resource "random_string" "telemetry" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

resource "azurerm_subscription_template_deployment" "telemetry_core" {
  count = var.module_telemetry_enabled ? 1 : 0

  name             = local.telem_arm_deployment_name
  location         = var.rg_location
  template_content = local.telem_arm_subscription_template_content
}