locals {
  cisco_byol = var.cisco_byol ? "17_10_01a-byol" : "17_04_02-payg-essentials"
}

data "template_file" "node_config" {
  template = file("${path.module}/templates/ios_config.txt")

  vars = {
    asn                      = var.asn
    router_id                = var.router_id
    fw_ars_ip_0              = var.fw_ars_ips[0]
    fw_ars_ip_1              = var.fw_ars_ips[1]
    avs_ars_ip_0             = var.avs_ars_ips[0]
    avs_ars_ip_1             = var.avs_ars_ips[1]
    csr_fw_facing_subnet_gw  = var.csr_fw_facing_subnet_gw
    csr_avs_facing_subnet_gw = var.csr_avs_facing_subnet_gw
    avs_network_subnet       = var.avs_network_subnet
    avs_network_mask         = var.avs_network_mask
    avs_hub_replacement_asn  = var.avs_hub_replacement_asn
    fw_hub_replacement_asn   = var.fw_hub_replacement_asn
    onprem_avs               = var.onprem_avs ? "" : "!!!"
  }
}


resource "azurerm_marketplace_agreement" "cisco-8000v" {
  publisher = "cisco"
  offer     = "cisco-c8000v"
  plan      = local.cisco_byol
}

resource "azurerm_network_interface" "node0_csr_nic0" {
  name                          = "${var.node0_name}-nic-0"
  location                      = var.rg_location
  resource_group_name           = var.rg_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true
  tags                          = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.fw_facing_subnet_id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
}

resource "azurerm_network_interface" "node0_csr_nic1" {
  name                          = "${var.node0_name}-nic-1"
  location                      = var.rg_location
  resource_group_name           = var.rg_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true
  tags                          = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.avs_facing_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "csr1000v_node0" {
  name                            = var.node0_name
  resource_group_name             = var.rg_name
  location                        = var.rg_location
  size                            = var.nva_sku_size
  admin_username                  = var.admin_username
  admin_password                  = random_password.admin_password.result
  disable_password_authentication = false
  custom_data                     = base64encode(data.template_file.node_config.rendered)
  tags                            = var.tags

  network_interface_ids = [
    azurerm_network_interface.node0_csr_nic0.id, azurerm_network_interface.node0_csr_nic1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = local.cisco_byol
    product   = "cisco-c8000v"
    publisher = "cisco"
  }

  source_image_reference {
    publisher = "cisco"
    offer     = "cisco-c8000v"
    sku       = local.cisco_byol
    version   = "latest"
  }

  depends_on = [
    azurerm_marketplace_agreement.cisco-8000v
  ]

  lifecycle {
    ignore_changes = [
      identity
    ]
  }
}

resource "azurerm_network_interface" "node1_csr_nic0" {
  name                          = "${var.node1_name}-nic-0"
  location                      = var.rg_location
  resource_group_name           = var.rg_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true
  tags                          = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.fw_facing_subnet_id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
}

resource "azurerm_network_interface" "node1_csr_nic1" {
  name                          = "${var.node1_name}-nic-1"
  location                      = var.rg_location
  resource_group_name           = var.rg_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true
  tags                          = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.avs_facing_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_password" "admin_password" {
  length  = 20
  special = false
  upper   = true
  lower   = true
}

resource "azurerm_linux_virtual_machine" "csr1000v_node1" {
  name                            = var.node1_name
  resource_group_name             = var.rg_name
  location                        = var.rg_location
  size                            = var.nva_sku_size
  admin_username                  = var.admin_username
  admin_password                  = random_password.admin_password.result
  disable_password_authentication = false
  custom_data                     = base64encode(data.template_file.node_config.rendered)
  tags                            = var.tags

  network_interface_ids = [
    azurerm_network_interface.node1_csr_nic0.id, azurerm_network_interface.node1_csr_nic1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = local.cisco_byol
    product   = "cisco-c8000v"
    publisher = "cisco"
  }

  source_image_reference {
    publisher = "cisco"
    offer     = "cisco-c8000v"
    sku       = local.cisco_byol
    version   = "latest"
  }
  depends_on = [
    azurerm_marketplace_agreement.cisco-8000v
  ]

  lifecycle {
    ignore_changes = [
      identity
    ]
  }
}


#write secret to keyvault
resource "azurerm_key_vault_secret" "admin_password" {
  name         = "csr-azureuser-password"
  value        = random_password.admin_password.result
  key_vault_id = var.keyvault_id
}
