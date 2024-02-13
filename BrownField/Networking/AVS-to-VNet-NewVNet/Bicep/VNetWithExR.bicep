@description('The name of the existing Private Cloud that should be used to generate an autorization key')
param PrivateCloudName string

@description('The resource group name that the existing Private Cloud resides in')
param PrivateCloudResourceGroup string = resourceGroup().name

@description('The subscription id that the existing Private Cloud resides in')
param PrivateCloudSubscriptionId string = subscription().id


@description('The location the new virtual network & gateway should reside in')
param Location string = resourceGroup().location

@description('Name of the virtual network to be created')
param VNetName string

@description('Address space for the virtual network to be created, should be a valid non-overlapping CIDR block in the format: 10.0.0.0/16')
param VNetAddressSpace string

@description('Subnet to be used for the virtual network gateway, should be a valid CIDR block within the address space provided above, in the format: 10.0.0.0/24')
param VNetGatewaySubnet string

@description('Name of the virtual network gateway to be created')
param GatewayName string = VNetName

// Customer Usage Attribution Id
var varCuaid = '938cd838-e22a-47da-8a6f-bdda923e3edb'

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

// Create a public ip for the virtual network gateway
resource GatewayPIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${GatewayName}-PIP'
  location: Location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
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

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../BrownField/Addons/CUAID/customerUsageAttribution/cuaIdResourceGroup.bicep' = {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(resourceGroup().location)}'
  params: {}
}
