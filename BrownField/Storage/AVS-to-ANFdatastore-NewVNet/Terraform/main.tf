terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }
        azapi = {
            source  = "azure/azapi"
        }
    }
}

provider "azurerm" {
  features {}
  alias                      = "AVS-to-ANFdatastore-NewVnet"
  partner_id                 = "938cd838-e22a-47da-8a6f-bdda923e3edb"
  skip_provider_registration = "true"
}

provider "azapi" {
  skip_provider_registration = "true"
}

resource "azurerm_resource_group" "deploymentRG" {
  provider = azurerm.AVS-to-ANFdatastore-NewVnet
  name     = var.DeploymentResourceGroupName
  location = var.Location
}

resource "azurerm_virtual_network" "vnetGatewayVnet" {
  provider            = azurerm.AVS-to-ANFdatastore-NewVnet
  name                = var.VNetName
  location            = azurerm_resource_group.deploymentRG.location
  resource_group_name = azurerm_resource_group.deploymentRG.name
  address_space       = var.VNetAddressSpaceCIDR
}

resource "azurerm_subnet" "gatewaySubnet" {
  provider             = azurerm.AVS-to-ANFdatastore-NewVnet
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.deploymentRG.name
  virtual_network_name = azurerm_virtual_network.vnetGatewayVnet.name
  address_prefixes     = var.VNetGatewaySubnetCIDR
}

resource "azurerm_subnet" "ANFDelegatedSubnet" {
  provider             = azurerm.AVS-to-ANFdatastore-NewVnet
  name                 = "ANFDelegatedSubnet"
  resource_group_name  = azurerm_resource_group.deploymentRG.name
  virtual_network_name = azurerm_virtual_network.vnetGatewayVnet.name
  address_prefixes     = var.VNetANFDelegatedSubnetCIDR
  delegation {
        name = "microsoftnetapp"
        service_delegation {
            name = "Microsoft.Netapp/volumes"
        }
    }
}

resource "azurerm_public_ip" "gatewayIP" {
  provider            = azurerm.AVS-to-ANFdatastore-NewVnet
  name                = "${var.GatewayName}-PIP"
  resource_group_name = azurerm_resource_group.deploymentRG.name
  location            = azurerm_resource_group.deploymentRG.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  sku_tier            = "Regional"
}

resource "azurerm_virtual_network_gateway" "ERGateway" {
  provider            = azurerm.AVS-to-ANFdatastore-NewVnet
  name                = var.GatewayName
  location            = azurerm_resource_group.deploymentRG.location
  resource_group_name = azurerm_resource_group.deploymentRG.name

  type = "ExpressRoute"
  sku  = var.GatewaySku

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gatewayIP.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gatewaySubnet.id
  }
}

#assumes the same subscription (need to reference different provider blocks if a separate sub is required.
data "azurerm_vmware_private_cloud" "existing" {
  provider            = azurerm.AVS-to-ANFdatastore-NewVnet
  name                = var.PrivateCloudName
  resource_group_name = var.PrivateCloudResourceGroup
}

#check this is the proper way to name the authorization
resource "azurerm_vmware_express_route_authorization" "thisVnet" {
  provider         = azurerm.AVS-to-ANFdatastore-NewVnet
  name             = azurerm_virtual_network.vnetGatewayVnet.name
  private_cloud_id = data.azurerm_vmware_private_cloud.existing.id
}

resource "azurerm_virtual_network_gateway_connection" "expressRoute" {
  provider            = azurerm.AVS-to-ANFdatastore-NewVnet
  name                = var.PrivateCloudName
  location            = azurerm_resource_group.deploymentRG.location
  resource_group_name = azurerm_resource_group.deploymentRG.name

  type                       = "ExpressRoute"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.ERGateway.id
  express_route_circuit_id   = data.azurerm_vmware_private_cloud.existing.circuit[0].express_route_id

  authorization_key = azurerm_vmware_express_route_authorization.thisVnet.express_route_authorization_key
  routing_weight    = 0
  express_route_gateway_bypass = true
}

resource "azurerm_netapp_account" "avs_anf_account" {
    provider            = azurerm.AVS-to-ANFdatastore-NewVnet
    name                = var.netappAccountName
    location            = azurerm_resource_group.deploymentRG.location
    resource_group_name = azurerm_resource_group.deploymentRG.name
}

resource "azurerm_netapp_pool" "avs_anf_pool" {
    provider            = azurerm.AVS-to-ANFdatastore-NewVnet
    name                = var.netappCapacityPoolName
    location            = azurerm_resource_group.deploymentRG.location
    resource_group_name = azurerm_resource_group.deploymentRG.name
    account_name        = azurerm_netapp_account.avs_anf_account.name
    service_level       = var.netappCapacityPoolServiceLevel
    size_in_tb          = var.netappCapacityPoolSize
}

resource "azapi_resource" "avs_anf_volume_avsdatastoreenabled" {
    depends_on = [
        azurerm_netapp_pool.avs_anf_pool
    ]
    type = "Microsoft.NetApp/netAppAccounts/capacityPools/volumes@2022-05-01"
    name = var.netappVolumeName
    parent_id = azurerm_netapp_pool.avs_anf_pool.id
    body = jsonencode({
        location = azurerm_resource_group.deploymentRG.location
        properties = {
            creationToken = var.netappVolumeName,
            serviceLevel = var.netappCapacityPoolServiceLevel,
            subnetId = azurerm_subnet.ANFDelegatedSubnet.id,
            usageThreshold = var.netappVolumeSize,
            protocolTypes = ["NFSv3"],
            networkFeatures = "Standard",
            avsDataStore = "Enabled"
            exportPolicy = {
                rules = [
                    {
                        ruleIndex = 1,
                        allowedClients = "0.0.0.0/0",
                        unixReadOnly = false,
                        hasRootAccess = true,
                        nfsv3 = true
                    }
                ]
            }
        }
    })
}

data "azurerm_vmware_private_cloud" "avs_privatecloud" {
    provider            = azurerm.AVS-to-ANFdatastore-NewVnet
    name                = var.PrivateCloudName
    resource_group_name = var.PrivateCloudResourceGroup
}

data "azurerm_netapp_volume" "anf_datastorevolume" {
    provider            = azurerm.AVS-to-ANFdatastore-NewVnet
    depends_on = [
        azapi_resource.avs_anf_volume_avsdatastoreenabled
    ]
    name = var.netappVolumeName
    account_name = var.netappAccountName
    pool_name = var.netappCapacityPoolName
    resource_group_name = azurerm_resource_group.deploymentRG.name
}

resource "azapi_resource" "avs_datastore_attach_anfvolume" {
    type = "Microsoft.AVS/privateClouds/clusters/datastores@2021-12-01"
    depends_on = [
        azurerm_virtual_network_gateway_connection.expressRoute
    ]
    name = var.netappVolumeName
    parent_id = "${data.azurerm_vmware_private_cloud.avs_privatecloud.id}/clusters/Cluster-1"
    body = jsonencode({
        properties = {
            netAppVolume = {
                id = data.azurerm_netapp_volume.anf_datastorevolume.id
            }
        }
    })
}