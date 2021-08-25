param PrivateCloudName string
param PrivateCloudResourceGroup string = resourceGroup().name
param PrivateCloudSubscriptionId string = subscription().id

param Location string = resourceGroup().location
param VNetName string
param VNetAddressSpace string
param VNetGatewaySubnet string
param GatewayName string = VNetName
param GatewaySku string = 'Standard'
param ConnectionName string = '${VNetName}-${PrivateCloudName}'

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

module AVSAuthorization 'Module-AVSAuthorization.bicep' = {
  name: 'AVSAuthorization'
  params: {
    ConnectionName: ConnectionName
    PrivateCloudName: PrivateCloudName
  }
  scope: resourceGroup(PrivateCloudSubscriptionId, PrivateCloudResourceGroup)
}

resource Connection 'Microsoft.Network/connections@2021-02-01' = {
  name: ConnectionName
  location: Location
  properties: {
    connectionType: 'ExpressRoute'
    routingWeight: 0
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
