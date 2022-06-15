@description('''
The name (string) of AVS Private Cloud 
This is used to:
- More easily generate an Express Route Authorization Key. 
- Obtain a handle on the AVS Express Route itself.
''')
param PrivateCloudName string

@description('Azure region to use to deploy new resources')
param Location string

@description('Resource naming prefix')
param Prefix string

@description('boolean value indicating if an Existing Vnet is to be used for deployment')
param VNetExists bool = true

@description('Name of Existing Vnet to use. required if VnetExists is set to true.')
param ExistingVnetName string

@description('boolean value indicating if an Existing Gateway Subnet is to be used for deployment')
param GatewaySubnetExists bool
// ExistingGatewaySubnetName must be 'GatewaySubnet'

@description('boolean value indicating if an Existing Gateway is to be used for deployment')
param GatewayExists bool

@description('Name of Existing Gateway to use. required if VnetExists is set to true')
param ExistingGatewayName string

@description('Address Prefix of the New Vnet to be used for deployment, Ex: \'192.168.0.0/24\'')
param NewVNetAddressSpace string

@description('Address Prefix of the New Gateway Subnet to be used for deployment, Ex: \'192.168.0.0/27\'')
param NewGatewaySubnetAddressPrefix string
param NewGatewaySku string = 'Standard'

// Label name for the Express Route Authorization Key. This value is NOT the key itself.
var AuthKeyName = '${Prefix}-authkey'

var NewVNetName = '${Prefix}-vnet'
// NewGatewaySubnet name must be 'GatewaySubnet'
var NewGatewayName = '${Prefix}-gw'

var VnetToAvsConnName = '${Prefix}-vnettoavs-conn'

resource ExistingVNet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = if (VNetExists) {
  name: ExistingVnetName
}

resource NewVNet 'Microsoft.Network/virtualNetworks@2021-08-01' = if (!VNetExists) {
  name: NewVNetName
  location: Location
    properties: {
    addressSpace: {
      addressPrefixes: [
        NewVNetAddressSpace
      ]
    }
  }
}

resource ExistingGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = if (GatewaySubnetExists) {
  name: '${ExistingVNet.name}/GatewaySubnet'
}

resource NewGatewaySubnetExitingVnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = if ((!GatewaySubnetExists) && VNetExists) {
  name: 'GatewaySubnet'
  parent: ExistingVNet
  properties: {
    addressPrefix: NewGatewaySubnetAddressPrefix
  }
}
resource NewGatewaySubnetNewVnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = if ((!GatewaySubnetExists) && (!VNetExists)) {
  name: 'GatewaySubnet'
  parent: NewVNet
  properties: {
    addressPrefix: NewGatewaySubnetAddressPrefix
  }
}

resource ExistingGateway 'Microsoft.Network/virtualNetworkGateways@2021-08-01' existing = if (GatewayExists) {
  name: ExistingGatewayName
}

resource NewGatewayPIP 'Microsoft.Network/publicIPAddresses@2021-08-01' = if (!GatewayExists) {
  name: '${NewGatewayName}-pip'
  location: Location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}

resource NewGatewayExistingGatewaySubnet 'Microsoft.Network/virtualNetworkGateways@2021-08-01' = if ((!GatewayExists) && GatewaySubnetExists) {
  name: NewGatewayName
  location: Location
  properties: {
    gatewayType: 'ExpressRoute'
    sku: {
      name: NewGatewaySku
      tier: NewGatewaySku
    }
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: ExistingGatewaySubnet.id
          }
          publicIPAddress: {
            id: NewGatewayPIP.id
          }
        }
      }
    ]
  }
}

resource NewGatewayNewGatewaySubnet 'Microsoft.Network/virtualNetworkGateways@2021-08-01' = if ((!GatewayExists) && (!GatewaySubnetExists)) {
  name: NewGatewayName
  location: Location
  properties: {
    gatewayType: 'ExpressRoute'
    sku: {
      name: NewGatewaySku
      tier: NewGatewaySku
    }
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: NewGatewaySubnetExitingVnet.id
          }
          publicIPAddress: {
            id: NewGatewayPIP.id
          }
        }
      }
    ]
  }
}


// Use AVS Private Cloud to Generate an Express Route Authoriation Key.
resource ExistingPrivateCloud 'Microsoft.AVS/privateClouds@2021-12-01' existing = {
  name: PrivateCloudName
}
// Derive the Express Route Id from the AVS Private Cloud resource.
var AvsExpressRouteId = ExistingPrivateCloud.properties.circuit.expressRouteID
resource ExpressRouteAuthKey 'Microsoft.AVS/privateClouds/authorizations@2021-12-01' = {
  name: AuthKeyName
  parent: ExistingPrivateCloud
}

// Create Connection from vnet via Express Route Gateway to AVS Private Cloud 
resource VnetToAvsConnExisitingGateway 'Microsoft.Network/connections@2021-08-01' = if (GatewayExists) {
  name: VnetToAvsConnName
  properties: {
    connectionType: 'ExpressRoute'
    authorizationKey: ExpressRouteAuthKey.properties.expressRouteAuthorizationKey
    enableBgp: true
    // FastPath option incurs additional costs, yet has performance benefit.
    // This can be enabled later.
    expressRouteGatewayBypass: false
    peer: {
      id: AvsExpressRouteId
    }
    virtualNetworkGateway1: {
      id: ExistingGateway.id
      properties: {}
    }
  }
}

// Create Connection from vnet via Express Route Gateway to AVS Private Cloud 
resource VnetToAvsConnNewGatewayExistingSubnet 'Microsoft.Network/connections@2021-08-01' = if ((!GatewayExists) && GatewaySubnetExists) {
  name: VnetToAvsConnName
  properties: {
    connectionType: 'ExpressRoute'
    authorizationKey: ExpressRouteAuthKey.properties.expressRouteAuthorizationKey
    enableBgp: true
    // FastPath option incurs additional costs, yet has performance benefit.
    // This can be enabled later.
    expressRouteGatewayBypass: false
    peer: {
      id: AvsExpressRouteId
    }
    virtualNetworkGateway1: {
      id: NewGatewayExistingGatewaySubnet.id
      properties: {}
    }
  }
}

// Create Connection from vnet via Express Route Gateway to AVS Private Cloud 
resource VnetToAvsConnNewGatewayNewSubnet 'Microsoft.Network/connections@2021-08-01' = if ((!GatewayExists) && (!GatewaySubnetExists)) {
  name: VnetToAvsConnName
  properties: {
    connectionType: 'ExpressRoute'
    authorizationKey: ExpressRouteAuthKey.properties.expressRouteAuthorizationKey
    enableBgp: true
    // FastPath option incurs additional costs, yet has performance benefit.
    // This can be enabled later.
    expressRouteGatewayBypass: false
    peer: {
      id: AvsExpressRouteId
    }
    virtualNetworkGateway1: {
      id: NewGatewayNewGatewaySubnet.id
      properties: {}
    }
  }
}

output ExpressRouteAuthorizationKey string = ExpressRouteAuthKey.properties.expressRouteAuthorizationKey
output ExpressRouteId string = ExistingPrivateCloud.properties.circuit.expressRouteID
// output DeploymentVNetName string = VNetExists ? ExistingVNet.name : NewVNet.name
// output DeploymentGatewayName string = GatewayExists ? ExistingGateway.name : NewGateway.name
// output DeploymentVNetResourceId string = VNetExists ? ExistingVNet.id : NewVNet.id
