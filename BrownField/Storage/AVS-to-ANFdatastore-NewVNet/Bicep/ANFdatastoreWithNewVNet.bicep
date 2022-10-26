@description('The name of the existing Private Cloud that should be used to generate an authorization key')
param PrivateCloudName string

@description('The name of the existing cluster that the Azure NetApp Files datastore should be connected to')
param PrivateCloudClusterName string

@description('The resource group name that the existing Private Cloud resides in')
param PrivateCloudResourceGroup string = resourceGroup().name

@description('The subscription id that the existing Private Cloud resides in')
param PrivateCloudSubscriptionId string = subscription().subscriptionId

@description('The location the new virtual network & gateway should reside in')
param Location string = resourceGroup().location

@description('Name of the virtual network to be created')
param VNetName string

@description('Address space for the virtual network to be created, should be a valid non-overlapping CIDR block in the format: 10.0.0.0/16')
param VNetAddressSpace string

@description('Subnet to be used for the virtual network gateway, should be a valid CIDR block within the address space provided above, in the format: 10.0.0.0/24')
param VNetGatewaySubnet string

@description('Subnet to be used for Azure NetApp Files datastores, should be a valid CIDR block within the address space provided above, in the format: 10.0.0.0/24')
param ANFDelegatedSubnet string

@description('Name of the NetApp Account to be created for the Azure NetApp Files datastore')
param netappAccountName string

@description('Name of the capacity pool to be created for the Azure NetApp Files datastore')
param netappCapacityPoolName string

@description('Service level of the Azure NetApp Files capacity pool and volume to be created')
@allowed([
  'Standard'
  'Premium'
  'Ultra'
])
param netappCapacityPoolServiceLevel string = 'Ultra'

@description('Size of the Azure NetApp Files datastore to be created')
param netappCapacityPoolSize int

@description('Name of the volume to be created for the Azure NetApp Files datastore')
param netappVolumeName string

@description('Size of the volume to be created for the Azure NetApp Files datastore')
param netappVolumeSize int

@description('Name of the virtual network gateway to be created')
param GatewayName string = VNetName

@description('Virtual network gateway SKU to be created')
@allowed([
  'Standard'
  'HighPerformance'
  'UltraPerformance'
  'ErGw1AZ'
  'ErGw2AZ'
  'ErGw3AZ'
])
param GatewaySku string = 'UltraPerformance'

// Customer Usage Attribution Id
var varCuaid = '938cd838-e22a-47da-8a6f-bdda923e3edb'

@description('import the existing AVS private cloud')
resource avsPrivateCloud 'Microsoft.AVS/privateClouds@2021-12-01' existing = {
  name: PrivateCloudName
}

@description('import the existing AVS private cloud cluster')
resource avsPrivateCloudCluster 'Microsoft.AVS/privateClouds/clusters@2021-12-01' existing = {
  parent: avsPrivateCloud
  name: PrivateCloudClusterName
}

// Create the Virtual Network with the gateway subnet
resource VNet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: VNetName
  location: Location
  properties: {
    addressSpace: {
      addressPrefixes: [
        VNetAddressSpace
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: VNetGatewaySubnet
        }
      }
    ]
  }
}

@description('create Azure NetApp files delegated subnet')
resource netappDelegatedSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  name: 'ANFDelegatedSubnet'
  parent: VNet
  properties: {
    delegations: [
      {
        name: 'microsoftnetapp'
        properties: {
          serviceName: 'Microsoft.Netapp/volumes'
        }
      }
    ]
    addressPrefix: ANFDelegatedSubnet
  }
}

// Create a public ip for the virtual network gateway
resource GatewayPIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${GatewayName}-PIP'
  location: Location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}

// Create the virtual network gateway
resource Gateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' = {
  name: GatewayName
  location: Location
  properties: {
    gatewayType: 'ExpressRoute'
    sku: {
      name: GatewaySku
      tier: GatewaySku
    }
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${VNet.id}/subnets/GatewaySubnet'
          }
          publicIPAddress: {
            id: GatewayPIP.id
          }
        }
      }
    ]
  }
}

// Create an AVS ExR Autorization Key via a module
module AVSAuthorization 'Modules/AVSAuthorization.bicep' = {
  name: 'AVSAuthorization'
  params: {
    AuthKeyName: GatewayName
    PrivateCloudName: PrivateCloudName
  }
  scope: resourceGroup(PrivateCloudSubscriptionId, PrivateCloudResourceGroup)
}

// Create a new connection for the Private Cloud Authorization that was generated
resource Connection 'Microsoft.Network/connections@2021-02-01' = {
  name: PrivateCloudName
  location: Location
  properties: {
    connectionType: 'ExpressRoute'
    routingWeight: 0
    expressRouteGatewayBypass: true
    virtualNetworkGateway1: {
      id: Gateway.id
      properties: {}
    }
    peer: {
      id: AVSAuthorization.outputs.ExpressRouteId
    }
    authorizationKey: AVSAuthorization.outputs.ExpressRouteAuthorizationKey
  }
}

@description('create Azure NetApp Files account')
resource netappAccount 'Microsoft.NetApp/netAppAccounts@2022-01-01' = { 
    name: netappAccountName
    location: Location 
}

@description('create Azure NetApp Files capacity pool')
resource netappCapacityPool 'Microsoft.NetApp/netAppAccounts/capacityPools@2022-01-01' = {
  name: netappCapacityPoolName
  location: Location
  parent: netappAccount
  properties: {
    coolAccess: false
    qosType: 'Auto'
    serviceLevel: netappCapacityPoolServiceLevel
    size: netappCapacityPoolSize
  }
}

@description('create Azure NetApp Files volume')
resource netappVolume 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes@2022-01-01' = {
  name: netappVolumeName
  location: Location
  parent: netappCapacityPool
  properties: {
    avsDataStore: 'Enabled'
    creationToken: netappVolumeName
    exportPolicy: {
      rules: [
        {
          allowedClients: '0.0.0.0/0'
          chownMode: 'restricted'
          cifs: false
          hasRootAccess: true
          nfsv3: true
          nfsv41: false
          ruleIndex: 1
          unixReadWrite: true
        }
      ]
    }
    networkFeatures: 'Standard'
    protocolTypes: ['NFSv3']
    serviceLevel: netappCapacityPoolServiceLevel
    subnetId: netappDelegatedSubnet.id
    usageThreshold: netappVolumeSize
  }
}

@description('create AVS datastore from ANF volume')
resource avsDatastore 'Microsoft.AVS/privateClouds/clusters/datastores@2021-12-01' = {
  name: netappVolumeName
  parent: avsPrivateCloudCluster
  properties: {
    netAppVolume: {
      id: netappVolume.id
    }
  }
  dependsOn: [
    Connection
  ]
}

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../BrownField/Addons/CUAID/customerUsageAttribution/cuaIdResourceGroup.bicep' = {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(resourceGroup().location)}'
  params: {}
}
