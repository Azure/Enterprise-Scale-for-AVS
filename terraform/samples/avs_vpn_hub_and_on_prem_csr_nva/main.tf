###### Deploy the AVS side hub ###############
module "deploy_greenfield_new_vpn_hub_no_firewall" {
  source = "../../scenarios/avs_greenfield_new_vpn_hub"

  prefix = "sample"
  region = "Southeast Asia"

  vnet_address_space = ["10.40.0.0/16"]
  subnets = [
    {
      name           = "GatewaySubnet",
      address_prefix = ["10.40.1.0/24"]
    },
    {
      name           = "RouteServerSubnet",
      address_prefix = ["10.40.2.0/24"]
    }
  ]

  expressroute_gateway_sku = "Standard"
  sddc_sku                 = "av36"
  management_cluster_size  = 3
  avs_network_cidr         = "10.2.0.0/20"
  hcx_enabled              = true
  hcx_key_names            = ["DallasDC", "SeattleDC"]
  vpn_gateway_sku          = "VpnGw2"
  asn                      = 65515
  firewall_sku_tier        = "Standard"
  email_addresses          = ["donotreply@microsoft.com"]

  jumpbox_sku                      = "Standard_D2as_v4"
  jumpbox_admin_username           = "azureuser"
  jumpbox_spoke_vnet_address_space = ["10.41.0.0/16"]
  bastion_subnet_prefix            = "10.41.1.0/16"
  jumpbox_subnet_prefix            = "10.41.2.0/16"

  tags = {
    environment = "Dev"
    CreatedBy   = "Terraform"
  }
  module_telemetry_enabled = false
}

######## Create a pre-shared key for the VPN ######
resource "random_password" "shared_key" {
  length  = 20
  special = false
  upper   = true
  lower   = true
}

resource "azurerm_key_vault_secret" "vpn_shared_key" {
  name         = "on-prem-to-avs-vpn-shared-key"
  value        = random_password.shared_key.result
  key_vault_id = module.deploy_on_prem_nva_vpn.key_vault_id
  depends_on   = [module.deploy_on_prem_nva_vpn.key_vault_id]
}

#Deploy a dummy on-prem
#Requires that the marketplace offer language has been accepted.
######## Deploy the CSR and on-prem jump #########
module "deploy_on_prem_nva_vpn" {
  source = "../../modules/avs_test_vpn_nva_one_node"

  prefix = "sample-on-prem"
  region = "Southeast Asia"

  vnet_address_space = ["10.50.0.0/16"]
  subnets = [
    {
      name           = "AzureBastionSubnet",
      address_prefix = ["10.50.1.0/24"]
    },
    {
      name           = "JumpBoxSubnet"
      address_prefix = ["10.50.2.0/24"]
    },
    {
      name           = "CSRSubnet"
      address_prefix = ["10.50.0.0/24"]
    }
  ]

  csr_bgp_ip          = "192.168.255.1"
  csr_tunnel_cidr     = "172.30.0.0/28"
  csr_subnet_name     = "CSRSubnet"
  remote_bgp_peer_ips = module.deploy_greenfield_new_vpn_hub_no_firewall.vpn_gateway_bgp_peering_addresses
  pre_shared_key      = random_password.shared_key.result
  asn                 = 64100
  jumpbox_sku         = "Standard_D2as_v4"
  admin_username      = "azureuser"
  remote_gw_pubip0    = module.deploy_greenfield_new_vpn_hub_no_firewall.vpn_gateway_pip_1
  remote_gw_pubip1    = module.deploy_greenfield_new_vpn_hub_no_firewall.vpn_gateway_pip_2
  tags = {
    environment = "Dev"
    CreatedBy   = "Terraform"
  }
  module_telemetry_enabled = false
}


module "create_vpn_connections" {
  source = "../../modules/avs_vpn_create_local_gateways_and_connections_active_active_w_bgp"

  rg_name                    = module.deploy_greenfield_new_vpn_hub_no_firewall.network_resource_group_name
  rg_location                = module.deploy_greenfield_new_vpn_hub_no_firewall.network_resource_group_location
  virtual_network_gateway_id = module.deploy_greenfield_new_vpn_hub_no_firewall.vpn_gateway_id
  #remote configurations
  remote_asn                     = module.deploy_on_prem_nva_vpn.asn
  local_gateway_bgp_ip           = module.deploy_on_prem_nva_vpn.csr_bgp_ip
  local_gateway_name_0           = "on-prem-csr-peer-0"
  local_gateway_name_1           = "on-prem-csr-peer-1"
  vnet_gateway_connection_name_0 = "on-prem-csr-peer-0-connection"
  vnet_gateway_connection_name_1 = "on-prem-csr-peer-1-connection"
  remote_gateway_address_0       = module.deploy_on_prem_nva_vpn.csr_pip_0
  remote_gateway_address_1       = module.deploy_on_prem_nva_vpn.csr_pip_0
  bgp_peering_address_0          = module.deploy_on_prem_nva_vpn.bgp_peer_ip_0
  bgp_peering_address_1          = module.deploy_on_prem_nva_vpn.bgp_peer_ip_1
  shared_key                     = random_password.shared_key.result
  module_telemetry_enabled       = false

  depends_on = [
    module.deploy_on_prem_nva_vpn,
    module.deploy_greenfield_new_vpn_hub_no_firewall
  ]
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
  module_identifier                       = lower("avs_deploy_vmware_segment_and_vm_using_linux_vm")
  telem_arm_deployment_name               = "241716b3-e71d-481d-a333-e520ea00ccf2.${substr(local.module_identifier, 0, 20)}.${random_string.telemetry.result}"
  telemetry_enabled                       = true
}

#create a random string for uniqueness  
resource "random_string" "telemetry" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

resource "azurerm_subscription_template_deployment" "telemetry_core" {
  count = local.telemetry_enabled ? 1 : 0

  name             = local.telem_arm_deployment_name
  location         = azurerm_resource_group.greenfield_privatecloud.location
  template_content = local.telem_arm_subscription_template_content
}