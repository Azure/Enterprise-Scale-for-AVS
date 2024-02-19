#Primary Hub Values
hub_rg_location        = "canadacentral"
hub_prefix             = "AVS-Network-Hub"
hub_vnet_address_space = ["10.100.0.0/16"]
hub_subnets = [
  {
    name           = "GatewaySubnet",
    address_prefix = ["10.100.0.0/24"]
  },
  {
    name           = "RouteServerSubnet",
    address_prefix = ["10.100.1.0/24"]
  },
  {
    name           = "Firewall-Internal-Facing",
    address_prefix = ["10.100.2.0/24"]
  },
  {
    name           = "Firewall-Internet-Facing"
    address_prefix = ["10.100.3.0/24"]
  },
  {
    name           = "AzureBastionSubnet"
    address_prefix = ["10.100.4.0/24"]
  },
  {
    name           = "AzureFirewallSubnet"
    address_prefix = ["10.100.5.0/24"]
  }
]
hub_expressroute_gateway_sku = "Standard"

#Transit Hub values
transit_hub_rg_location        = "canadacentral"
transit_hub_prefix             = "AVS-Transit-Hub"
transit_hub_vnet_address_space = ["10.200.0.0/16", "192.168.0.0/24"]
transit_hub_subnets = [
  {
    name           = "GatewaySubnet",
    address_prefix = ["10.200.0.0/24"]
  },
  {
    name           = "RouteServerSubnet",
    address_prefix = ["10.200.1.0/24"]
  },
  {
    name           = "FirewallFacingSubnet",
    address_prefix = ["10.200.3.0/24"]
  },
  {
    name           = "AvsFacingSubnet"
    address_prefix = ["10.200.4.0/24"]
  },
  {
    name           = "BackupApplianceSubnet"
    address_prefix = ["10.200.5.0/24"]
  }
]

transit_hub_expressroute_gateway_sku = "Standard"
firewall_sku_tier                    = "Standard"
#firewall_avs_facing_ip_address = "10.48.153.4"

private_cloud_rg_prefix = "AVS-SDDC"
private_cloud_location  = "canadacentral"
avs_private_clouds = [
  {
    sddc_name                             = "avs_sddc_001"
    sddc_sku                              = "av36"
    management_cluster_size               = 3
    avs_network_cidr                      = "10.10.0.0/22"
    hcx_enabled                           = true
    hcx_key_prefix                        = "avs_sddc_001_hcx"
    expressroute_authorization_key_prefix = "avs_sddc_001_exr_auth_key"
    internet_enabled                      = false
    attach_to_expressroute_gateway        = true
  }
]

#configure this section if using another AVS private cloud for on-prem simulation. If 
onprem_enabled                 = true
onprem_private_cloud_rg_prefix = "ONPREM-SDDC"
onprem_private_cloud_location  = "canadacentral"
onprem_private_clouds = [
  {
    sddc_name                             = "onprem_sddc_001"
    sddc_sku                              = "av36"
    management_cluster_size               = 3
    avs_network_cidr                      = "10.20.0.0/22"
    hcx_enabled                           = true
    hcx_key_prefix                        = "avs_sddc_001_hcx"
    expressroute_authorization_key_prefix = "avs_sddc_001_exr_auth_key"
    internet_enabled                      = false
    attach_to_expressroute_gateway        = true
  }
]

tags = {
  environment = "Dev"
  CreatedBy   = "Terraform"
}
telemetry_enabled = true