locals {



  hub_vnet_name                     = "${var.hub_prefix}-Hub-VNET-${random_string.namestring.result}"
  hub_network_rg_name               = "${random_string.namestring.result}-${var.hub_prefix}-Hub-Network-RG"
  hub_expressroute_pip_name         = "${var.hub_prefix}-expressroute-gw-pip-${random_string.namestring.result}"
  hub_expressroute_gateway_name     = "${var.hub_prefix}-expressroute-gw-01-${random_string.namestring.result}"
  hub_express_route_connection_name = "${var.hub_prefix}-expressroute-connection-sddc-01-${random_string.namestring.result}"
  hub_virtual_hub_name              = "${var.hub_prefix}-routeserver-virtualhub-01-${random_string.namestring.result}"
  hub_virtual_hub_pip_name          = "${var.hub_prefix}-routeserver-virtualhub-pip-${random_string.namestring.result}"
  hub_route_server_name             = "${var.hub_prefix}-routeserver-01-${random_string.namestring.result}"
  hub_gateway_route_table_name      = "${var.hub_prefix}-gateway-rt-${random_string.namestring.result}"
  bastion_pip_name                  = "${var.hub_prefix}-bastion-pip-${random_string.namestring.result}"
  bastion_name                      = "${var.hub_prefix}-bastion-${random_string.namestring.result}"
  firewall_pip_name                 = "${var.hub_prefix}-AVS-firewall-pip-${random_string.namestring.result}"
  firewall_name                     = "${var.hub_prefix}-AVS-firewall-${random_string.namestring.result}"
  firewall_policy_name              = "${var.hub_prefix}-AVS-firewall-policy-${random_string.namestring.result}"
  log_analytics_name                = "${var.hub_prefix}-AVS-log-analytics-${random_string.namestring.result}"
  keyvault_name                     = "kv-avs-${random_string.namestring.result}"

  transit_hub_network_rg_name               = "${random_string.namestring.result}-${var.transit_hub_prefix}-Transit-Hub-Network-RG"
  transit_hub_vnet_name                     = "${var.transit_hub_prefix}-Transit-Hub-VNET-${random_string.namestring.result}"
  transit_hub_expressroute_pip_name         = "${var.transit_hub_prefix}-expressroute-gw-pip-${random_string.namestring.result}"
  transit_hub_expressroute_gateway_name     = "${var.transit_hub_prefix}-expressroute-gw-01-${random_string.namestring.result}"
  transit_hub_express_route_connection_name = "${var.transit_hub_prefix}-expressroute-connection-sddc-01-${random_string.namestring.result}"
  transit_hub_virtual_hub_name              = "${var.transit_hub_prefix}-routeserver-virtualhub-01-${random_string.namestring.result}"
  transit_hub_virtual_hub_pip_name          = "${var.transit_hub_prefix}-routeserver-virtualhub-pip-${random_string.namestring.result}"
  transit_hub_route_server_name             = "${var.transit_hub_prefix}-routeserver-01-${random_string.namestring.result}"
  transit_hub_nva_fw_facing_subnet_rt_name  = "${var.transit_hub_prefix}-cisco-nva-ewn-rt-${random_string.namestring.result}"

  transit_hub_nva_node0_name = "${var.transit_hub_prefix}-cisco-node0-${random_string.namestring.result}"
  transit_hub_nva_node1_name = "${var.transit_hub_prefix}-cisco-node1-${random_string.namestring.result}"

  tags = var.tags

  #onprem private cloud names if using AVS to simulate an on-prem environment
  onprem_rg_name = "${random_string.namestring.result}-${var.onprem_private_cloud_rg_prefix}-RG"
  avs_rg_name    = "${random_string.namestring.result}-${var.private_cloud_rg_prefix}-RG"

}

#create a random string for uniqueness during redeployments using the same values
resource "random_string" "namestring" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

###################################################################################################
# Create the primary network hub and resources
###################################################################################################

#Create the Network objects resource group
resource "azurerm_resource_group" "greenfield_network_hub" {
  name     = local.hub_network_rg_name
  location = var.hub_rg_location
}

module "primary_hub_virtual_network" {
  source = "../../modules/avs_vnet_variable_subnets"

  rg_name            = azurerm_resource_group.greenfield_network_hub.name
  rg_location        = azurerm_resource_group.greenfield_network_hub.location
  vnet_name          = local.hub_vnet_name
  vnet_address_space = var.hub_vnet_address_space
  subnets            = var.hub_subnets
  tags               = local.tags
}

#deploy the expressroute gateway in the gateway subnet 
module "primary_hub_expressroute_gateway" {
  source = "../../modules/avs_expressroute_gateway"

  expressroute_pip_name     = local.hub_expressroute_pip_name
  expressroute_gateway_name = local.hub_expressroute_gateway_name
  expressroute_gateway_sku  = var.hub_expressroute_gateway_sku
  rg_name                   = azurerm_resource_group.greenfield_network_hub.name
  rg_location               = azurerm_resource_group.greenfield_network_hub.location
  gateway_subnet_id         = module.primary_hub_virtual_network.subnet_ids["GatewaySubnet"].id
  tags                      = local.tags
}

#deploy a routeserver
module "primary_hub_routeserver" {
  source = "../../modules/avs_routeserver"

  rg_name                = azurerm_resource_group.greenfield_network_hub.name
  rg_location            = azurerm_resource_group.greenfield_network_hub.location
  virtual_hub_name       = local.hub_virtual_hub_name
  virtual_hub_pip_name   = local.hub_virtual_hub_pip_name
  route_server_name      = local.hub_route_server_name
  route_server_subnet_id = module.primary_hub_virtual_network.subnet_ids["RouteServerSubnet"].id
  #tags                   = local.tags
}

#create Gateway route table with transit hub prefixes and AVS prefixes pointing to the firewall
#bgp route propogation disabled
#Routes for each firewall subnet next-hop to firewall
resource "azurerm_route_table" "gateway_rt" {
  name                          = local.hub_gateway_route_table_name
  location                      = azurerm_resource_group.greenfield_network_hub.location
  resource_group_name           = azurerm_resource_group.greenfield_network_hub.name
  disable_bgp_route_propagation = false
  tags                          = local.tags
}

#add firewall hub routes to the route table directing traffic to the firewall (with the exception of the route server)
resource "azurerm_route" "gateway_rt_routes" {
  for_each               = { for subnet in var.transit_hub_subnets : subnet.name => subnet if subnet.name != "RouteServerSubnet" && subnet.name != "GatewaySubnet" }
  name                   = each.value.name
  resource_group_name    = azurerm_resource_group.greenfield_network_hub.name
  route_table_name       = azurerm_route_table.gateway_rt.name
  address_prefix         = each.value.address_prefix[0]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.avs_azure_firewall.firewall_private_ip_address
}

#add a route for the AVS prefixes
resource "azurerm_route" "gateway-avs-routes" {
  for_each               = { for sddc in var.avs_private_clouds : sddc.sddc_name => sddc }
  name                   = "AVS_Management_routes-${each.value.sddc_name}"
  resource_group_name    = azurerm_resource_group.greenfield_network_hub.name
  route_table_name       = azurerm_route_table.gateway_rt.name
  address_prefix         = each.value.avs_network_cidr
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.avs_azure_firewall.firewall_private_ip_address
}


resource "azurerm_subnet_route_table_association" "hub_gateway_subnet" {
  subnet_id      = module.primary_hub_virtual_network.subnet_ids["GatewaySubnet"].id
  route_table_id = azurerm_route_table.gateway_rt.id
}

#deploy a keyvault for central secret management
data "azurerm_client_config" "current" {
}

module "avs_keyvault_with_access_policy" {
  source = "../../modules/avs_key_vault"

  #values to create the keyvault
  rg_name                   = azurerm_resource_group.greenfield_network_hub.name
  rg_location               = azurerm_resource_group.greenfield_network_hub.location
  keyvault_name             = local.keyvault_name
  azure_ad_tenant_id        = data.azurerm_client_config.current.tenant_id
  deployment_user_object_id = data.azurerm_client_config.current.object_id
  tags                      = var.tags
}


###################################################################################################
# Create the ONPREM AVS configuration if enabled
###################################################################################################

#Create the onprem AVS environment and connections if onprem is enabled
resource "azurerm_resource_group" "onprem" {
  count    = var.onprem_enabled ? 1 : 0
  name     = local.onprem_rg_name
  location = var.onprem_private_cloud_location
}

module "onprem_private_clouds" {
  source   = "../../modules/avs_private_cloud_single_management_cluster_no_internet_conn_w_exr"
  for_each = { for sddc in var.onprem_private_clouds : sddc.sddc_name => sddc }

  sddc_name                             = each.value.sddc_name
  sddc_sku                              = each.value.sddc_sku
  management_cluster_size               = each.value.management_cluster_size
  rg_name                               = azurerm_resource_group.onprem[0].name
  rg_location                           = azurerm_resource_group.onprem[0].location
  avs_network_cidr                      = each.value.avs_network_cidr
  expressroute_authorization_key_prefix = each.value.expressroute_authorization_key_prefix
  internet_enabled                      = each.value.internet_enabled
  hcx_enabled                           = each.value.hcx_enabled
  hcx_key_prefix                        = each.value.hcx_key_prefix
  tags                                  = local.tags
  module_telemetry_enabled              = false
  attach_to_expressroute_gateway        = each.value.attach_to_expressroute_gateway
  expressroute_gateway_id               = module.primary_hub_expressroute_gateway.expressroute_gateway_id
}

###################################################################################################
# Deploy Azure Firewall
###################################################################################################

module "avs_azure_firewall" {
  source = "../../modules/avs_azure_firewall_w_log_analytics"

  rg_name              = azurerm_resource_group.greenfield_network_hub.name
  rg_location          = azurerm_resource_group.greenfield_network_hub.location
  firewall_sku_tier    = var.firewall_sku_tier
  tags                 = var.tags
  firewall_pip_name    = local.firewall_pip_name
  firewall_name        = local.firewall_name
  firewall_subnet_id   = module.primary_hub_virtual_network.subnet_ids["AzureFirewallSubnet"].id
  log_analytics_name   = local.log_analytics_name
  firewall_policy_name = local.firewall_policy_name
}

module "avs_test_firewall_rules" {
  source                 = "../../modules/avs_azure_firewall_internet_outbound_rules"
  count                  = var.onprem_enabled ? 1 : 0
  firewall_policy_id     = module.avs_azure_firewall.firewall_policy_id
  azure_firewall_name    = module.avs_azure_firewall.firewall_name
  azure_firewall_rg_name = module.avs_azure_firewall.firewall_rg_name
  private_range_prefixes = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  has_firewall_policy    = true
}

###################################################################################################
# Create the transit network hub and resources
###################################################################################################
#Create the Network objects resource group
resource "azurerm_resource_group" "transit_network_hub" {
  name     = local.transit_hub_network_rg_name
  location = var.transit_hub_rg_location
}

module "transit_hub_virtual_network" {
  source = "../../modules/avs_vnet_variable_subnets"

  rg_name            = azurerm_resource_group.transit_network_hub.name
  rg_location        = azurerm_resource_group.transit_network_hub.location
  vnet_name          = local.transit_hub_vnet_name
  vnet_address_space = var.transit_hub_vnet_address_space
  subnets            = var.transit_hub_subnets
  tags               = local.tags
}


#deploy the expressroute gateway in the gateway subnet 
module "transit_hub_expressroute_gateway" {
  source = "../../modules/avs_expressroute_gateway"

  expressroute_pip_name     = local.transit_hub_expressroute_pip_name
  expressroute_gateway_name = local.transit_hub_expressroute_gateway_name
  expressroute_gateway_sku  = var.transit_hub_expressroute_gateway_sku
  rg_name                   = azurerm_resource_group.transit_network_hub.name
  rg_location               = azurerm_resource_group.transit_network_hub.location
  gateway_subnet_id         = module.transit_hub_virtual_network.subnet_ids["GatewaySubnet"].id
  tags                      = local.tags
}

#deploy a routeserver
module "transit_hub_routeserver" {
  source = "../../modules/avs_routeserver"

  rg_name                = azurerm_resource_group.transit_network_hub.name
  rg_location            = azurerm_resource_group.transit_network_hub.location
  virtual_hub_name       = local.transit_hub_virtual_hub_name
  virtual_hub_pip_name   = local.transit_hub_virtual_hub_pip_name
  route_server_name      = local.transit_hub_route_server_name
  route_server_subnet_id = module.transit_hub_virtual_network.subnet_ids["RouteServerSubnet"].id
  #tags                   = local.tags
}


#create NVA fw-facing route table
#bgp route propogation disabled
#Routes for each firewall subnet next-hop to firewall
resource "azurerm_route_table" "nva_fw_facing_subnet" {
  name                          = local.transit_hub_nva_fw_facing_subnet_rt_name
  location                      = azurerm_resource_group.transit_network_hub.location
  resource_group_name           = azurerm_resource_group.transit_network_hub.name
  disable_bgp_route_propagation = true
  tags                          = local.tags
}

#add firewall hub routes to the route table directing traffic to the firewall (with the exception of the route server)
resource "azurerm_route" "nva_fw_facing_subnet_routes" {
  for_each               = { for subnet in var.hub_subnets : subnet.name => subnet if subnet.name != "RouteServerSubnet" && subnet.name != "AzureBastionSubnet" }
  name                   = each.value.name
  resource_group_name    = azurerm_resource_group.transit_network_hub.name
  route_table_name       = azurerm_route_table.nva_fw_facing_subnet.name
  address_prefix         = each.value.address_prefix[0]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.avs_azure_firewall.firewall_private_ip_address
}

#add a default route directing traffic to the firweall
resource "azurerm_route" "nva_fw_facing_subnet_default_route" {
  name                   = "default"
  resource_group_name    = azurerm_resource_group.transit_network_hub.name
  route_table_name       = azurerm_route_table.nva_fw_facing_subnet.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.avs_azure_firewall.firewall_private_ip_address
}


resource "azurerm_subnet_route_table_association" "nva_fw_facing_subnet" {
  subnet_id      = module.transit_hub_virtual_network.subnet_ids["FirewallFacingSubnet"].id
  route_table_id = azurerm_route_table.nva_fw_facing_subnet.id
}


module "create_cisco_csr8000" {
  source = "../../modules/avs_nva_cisco_8000v_scenario2"

  rg_name                  = azurerm_resource_group.transit_network_hub.name
  rg_location              = azurerm_resource_group.transit_network_hub.location
  asn                      = "65111"
  router_id                = "65.1.1.1"
  fw_ars_ips               = module.primary_hub_routeserver.routeserver_details.virtual_router_ips
  avs_ars_ips              = module.transit_hub_routeserver.routeserver_details.virtual_router_ips
  csr_fw_facing_subnet_gw  = cidrhost([for subnet in var.transit_hub_subnets : subnet.address_prefix[0] if subnet.name == "FirewallFacingSubnet"][0], 1)
  csr_avs_facing_subnet_gw = cidrhost([for subnet in var.transit_hub_subnets : subnet.address_prefix[0] if subnet.name == "AvsFacingSubnet"][0], 1)
  avs_network_subnet       = split("/", var.avs_private_clouds[0].avs_network_cidr)[0]
  avs_network_mask         = cidrnetmask(var.avs_private_clouds[0].avs_network_cidr)
  node0_name               = local.transit_hub_nva_node0_name
  node1_name               = local.transit_hub_nva_node1_name
  fw_facing_subnet_id      = module.transit_hub_virtual_network.subnet_ids["FirewallFacingSubnet"].id
  avs_facing_subnet_id     = module.transit_hub_virtual_network.subnet_ids["AvsFacingSubnet"].id
  keyvault_id              = module.avs_keyvault_with_access_policy.keyvault_id
  avs_hub_replacement_asn  = "65222"
  fw_hub_replacement_asn   = "65333"
  nva_sku_size             = "Standard_D3_v2"
  onprem_avs               = true
  tags                     = local.tags

  depends_on = [
    module.primary_hub_routeserver,
    module.transit_hub_routeserver
  ]
}

#create BGP peerings from firewall hub route server to CSR 
#create routeserver peering
resource "azurerm_virtual_hub_bgp_connection" "fw_hub_csr_rs_conn_0" {
  name           = "firewall-rs-csr-bgp-connection-0"
  virtual_hub_id = module.primary_hub_routeserver.virtual_hub_id
  peer_asn       = module.create_cisco_csr8000.asn
  peer_ip        = module.create_cisco_csr8000.csr0_fw_facing_ip
  depends_on = [
    module.primary_hub_routeserver
  ]
}

resource "azurerm_virtual_hub_bgp_connection" "fw_hub_csr_rs_conn_1" {
  name           = "firewall-rs-csr-bgp-connection-1"
  virtual_hub_id = module.primary_hub_routeserver.virtual_hub_id
  peer_asn       = module.create_cisco_csr8000.asn
  peer_ip        = module.create_cisco_csr8000.csr1_fw_facing_ip
  depends_on = [
    module.primary_hub_routeserver
  ]
}

resource "azurerm_virtual_hub_bgp_connection" "avs_hub_csr_rs_conn_0" {
  name           = "avs-rs-csr-bgp-connection-0"
  virtual_hub_id = module.transit_hub_routeserver.virtual_hub_id
  peer_asn       = module.create_cisco_csr8000.asn
  peer_ip        = module.create_cisco_csr8000.csr0_avs_facing_ip
  depends_on = [
    module.transit_hub_routeserver
  ]
}

resource "azurerm_virtual_hub_bgp_connection" "avs_hub_csr_rs_conn_1" {
  name           = "avs-rs-csr-bgp-connection-1"
  virtual_hub_id = module.transit_hub_routeserver.virtual_hub_id
  peer_asn       = module.create_cisco_csr8000.asn
  peer_ip        = module.create_cisco_csr8000.csr1_avs_facing_ip
  depends_on = [
    module.transit_hub_routeserver
  ]
}

#create a vnet peering relationship between the hubs without gateway access
resource "azurerm_virtual_network_peering" "firewall-hub-to-avs-hub" {
  name                      = "firewall-hub-to-avs-hub"
  resource_group_name       = azurerm_resource_group.greenfield_network_hub.name
  virtual_network_name      = module.primary_hub_virtual_network.vnet_name
  remote_virtual_network_id = module.transit_hub_virtual_network.vnet_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "avs-hub-to-firewall-hub" {
  name                      = "avs-hub-to-firewall-hub"
  resource_group_name       = azurerm_resource_group.transit_network_hub.name
  virtual_network_name      = module.transit_hub_virtual_network.vnet_name
  remote_virtual_network_id = module.primary_hub_virtual_network.vnet_id
  allow_forwarded_traffic   = true
}


#deploy the bastion host
module "avs_bastion" {
  source = "../../modules/avs_bastion_simple"

  bastion_pip_name         = local.bastion_pip_name
  bastion_name             = local.bastion_name
  rg_name                  = azurerm_resource_group.greenfield_network_hub.name
  rg_location              = azurerm_resource_group.greenfield_network_hub.location
  bastion_subnet_id        = module.primary_hub_virtual_network.subnet_ids["AzureBastionSubnet"].id
  tags                     = local.tags
  module_telemetry_enabled = false
}


#deploy the AVS private clouds
resource "azurerm_resource_group" "private_clouds_resource_group" {
  name     = local.avs_rg_name
  location = var.private_cloud_location
}

module "avs_private_clouds" {
  source   = "../../modules/avs_private_cloud_single_management_cluster_no_internet_conn_w_exr"
  for_each = { for sddc in var.avs_private_clouds : sddc.sddc_name => sddc }

  sddc_name                             = each.value.sddc_name
  sddc_sku                              = each.value.sddc_sku
  management_cluster_size               = each.value.management_cluster_size
  rg_name                               = azurerm_resource_group.private_clouds_resource_group.name
  rg_location                           = azurerm_resource_group.private_clouds_resource_group.location
  avs_network_cidr                      = each.value.avs_network_cidr
  expressroute_authorization_key_prefix = each.value.expressroute_authorization_key_prefix
  internet_enabled                      = each.value.internet_enabled
  hcx_enabled                           = each.value.hcx_enabled
  hcx_key_prefix                        = each.value.hcx_key_prefix
  tags                                  = local.tags
  module_telemetry_enabled              = false
  attach_to_expressroute_gateway        = each.value.attach_to_expressroute_gateway
  expressroute_gateway_id               = module.transit_hub_expressroute_gateway.expressroute_gateway_id
}

