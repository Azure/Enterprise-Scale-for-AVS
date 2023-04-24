
param Location string
param Prefix string
param NewVNetAddressSpace string
param NewVnetNewGatewaySubnetAddressPrefix string
param NewGatewaySku string = 'Standard'

var NewVNetName = '${Prefix}-vnet'
var NewVnetNewGatewayName = '${Prefix}-gw'

//New VNet Workflow
resource NewVNet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: NewVNetName
  location: Location
  properties: {
    addressSpace: {
      addressPrefixes: [
        NewVNetAddressSpace
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: NewVnetNewGatewaySubnetAddressPrefix
      }
    }
    ]
  }
}

resource NewGatewayPIP 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: '${NewVnetNewGatewayName}-pip'
  location: Location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}

//New Gateway Workflow
resource NewVnetNewGateway 'Microsoft.Network/virtualNetworkGateways@2021-08-01' = {
  name: NewVnetNewGatewayName
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
            id: NewVNet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: NewGatewayPIP.id
          }
        }
      }
    ]
  }
}

output VNetName string = NewVNet.name
output GatewayName string = NewVnetNewGateway.name
output VNetResourceId string = NewVNet.id
