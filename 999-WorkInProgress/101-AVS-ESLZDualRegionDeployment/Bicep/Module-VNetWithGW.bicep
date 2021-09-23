param Location string = resourceGroup().location
param Prefix string
param VNetAddressSpace string
param VNetGatewaySubnet string
param GatewaySku string = 'Standard'

var GatewayName = '${Prefix}-GW'

resource VNet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: '${Prefix}-VNet'
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

output VNetName string = VNet.name
output GatewayName string = Gateway.name
