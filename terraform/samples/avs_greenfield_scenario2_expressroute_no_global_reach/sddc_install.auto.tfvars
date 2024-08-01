#Primary Hub Values
hub_rg_location        = "<location>"
hub_prefix             = "AVS-Network-Hub"
hub_vnet_address_space = ["w.x.y.z/aa"]
hub_subnets = [
  {
    name           = "GatewaySubnet",
    address_prefix = ["w.x.y.z/aa </27 minimum recommended CIDR block>"]
  },
  {
    name           = "RouteServerSubnet",
    address_prefix = ["w.x.y.z/aa </27 minimum recommended CIDR block>"]
  },
  {
    name           = "Firewall-Internal-Facing",
    address_prefix = ["w.x.y.z/aa"]
  },
  {
    name           = "Firewall-Internet-Facing"
    address_prefix = ["w.y.x.z/aa"]
  },
  {
    name           = "AzureBastionSubnet"
    address_prefix = ["w.x.y.z/aa </26 minimum recommended CIDR block>"]
  },
  {
    name           = "AzureFirewallSubnet"
    address_prefix = ["w.x.y.z/aa </26 is the recommended CIDR block>"]
  }
]
hub_expressroute_gateway_sku = "Standard"

#Transit Hub values
transit_hub_rg_location        = "<location>"
transit_hub_prefix             = "AVS-Transit-Hub"
transit_hub_vnet_address_space = ["w.x.y.z/aa"]
transit_hub_subnets = [
  {
    name           = "GatewaySubnet",
    address_prefix = ["w.x.y.z/aa </27 minimum recommended CIDR block>"]
  },
  {
    name           = "RouteServerSubnet",
    address_prefix = ["w.x.y.z/aa </27 minimum recommended CIDR block>"]
  },
  {
    name           = "FirewallFacingSubnet",
    address_prefix = ["w.x.y.z/aa"]
  },
  {
    name           = "AvsFacingSubnet"
    address_prefix = ["w.x.y.z/aa"]
  },
  {
    name           = "BackupApplianceSubnet"
    address_prefix = ["w.x.y.z/aa"]
  }
]

transit_hub_expressroute_gateway_sku = "Standard"
firewall_sku_tier                    = "Standard"
#firewall_avs_facing_ip_address = "w.x.y.z"

private_cloud_rg_prefix = "AVS-SDDC"
private_cloud_location  = "<location>"
avs_private_clouds = [
  {
    sddc_name                             = "avs_sddc_001"
    sddc_sku                              = "av36"
    management_cluster_size               = 3
    avs_network_cidr                      = "x.y.z.0/22"
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
onprem_private_cloud_location  = "<location>"
onprem_private_clouds = [
  {
    sddc_name                             = "onprem_sddc_001"
    sddc_sku                              = "av36"
    management_cluster_size               = 3
    avs_network_cidr                      = "x.y.z.0/22"
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