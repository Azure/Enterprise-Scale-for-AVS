param Location string = resourceGroup().location
param Prefix string
param VNetExists bool
param VNetAddressSpace string
param VNetGatewaySubnet string
param GatewaySku string = 'Standard'

var GatewayName = '${Prefix}-GW'
var VNetName = '${Prefix}-VNet'

resource VNet 'Microsoft.Network/virtualNetworks@2021-02-01' = if (!VNetExists) {
  name: VNetName
  location: Location
  properties: {
    addressSpace: {
      addressPrefixes: [
        VNetAddressSpace
      ]
    }
  }
}

resource ExistingVNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = if (VNetExists) {
  name: VNetName
}

resource GatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = if (!VNetExists) {
  name: 'GatewaySubnet'
  parent: VNet
  properties: {
    addressPrefix: VNetGatewaySubnet
  }
}

resource GatewayPIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = if (!VNetExists) {
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

resource ExistingGateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' existing = if (VNetExists) {
  name: GatewayName
}

resource Gateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' = if (!VNetExists) {
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
            id: GatewaySubnet.id
          }
          publicIPAddress: {
            id: GatewayPIP.id
          }
        }
      }
    ]
  }
}

output VNetName string = VNetExists ? ExistingVNet.name : VNet.name
output GatewayName string = VNetExists ? ExistingGateway.name : Gateway.name
output VNetResourceId string = VNetExists ? ExistingVNet.id : VNet.id
