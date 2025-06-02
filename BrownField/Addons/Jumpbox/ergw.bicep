@description('Name for the ExpressRoute Gateway')
param gatewayName string = 'jumpbox-ergw'

@description('Location for the gateway resource')
param location string = resourceGroup().location

@description('Virtual network name where the gateway subnet exists')
param vnetName string = ''

@description('SKU for the ExpressRoute Gateway')
@allowed([
  'Standard'
  'HighPerformance'
  'UltraPerformance'
  'ErGw1AZ'
  'ErGw2AZ'
  'ErGw3AZ'
])
param gatewaySku string = 'Standard'

@description('Tags for the gateway resource')
param tags object = {}

@description('Subnet resource ID')
param subnetId string = ''

@description('Public IP resource ID')
param publicIpId string = ''

// Check if we're using direct resource IDs or creating resources inline
var useDirectIds = !empty(subnetId) && !empty(publicIpId)

// Reference the existing GatewaySubnet if not using direct IDs
resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = if (!useDirectIds) {
  name: '${vnetName}/GatewaySubnet'
}

// Create a public IP for the gateway if not using a direct ID
resource gatewayPublicIP 'Microsoft.Network/publicIPAddresses@2023-04-01' = if (!useDirectIds) {
  name: '${gatewayName}-pip'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Deploy the ExpressRoute Gateway
resource expressRouteGateway 'Microsoft.Network/virtualNetworkGateways@2023-04-01' = {
  name: gatewayName
  location: location
  tags: tags
  properties: {
    gatewayType: 'ExpressRoute'
    vpnType: 'RouteBased'  // Required even for ER gateways
    sku: {
      name: gatewaySku
      tier: gatewaySku
    }
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: useDirectIds ? subnetId : gatewaySubnet.id
          }
          publicIPAddress: {
            id: useDirectIds ? publicIpId : gatewayPublicIP.id
          }
        }
      }
    ]
  }
}

// Outputs
output gatewayId string = expressRouteGateway.id
output gatewayName string = expressRouteGateway.name
output publicIpId string = useDirectIds ? publicIpId : gatewayPublicIP.id
