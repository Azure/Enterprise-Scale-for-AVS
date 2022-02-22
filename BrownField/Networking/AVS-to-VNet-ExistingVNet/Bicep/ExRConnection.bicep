@description('The name of the existing Private Cloud that should be used to generate an autorization key')
param PrivateCloudName string

@description('The resource group name that the existing Private Cloud resides in')
param PrivateCloudResourceGroup string = resourceGroup().name

@description('The subscription id that the existing Private Cloud resides in')
param PrivateCloudSubscriptionId string = subscription().id


@description('The existing virtual network gateway name, should be in the resource group this template is deployed to')
param GatewayName string

@description('The location of the virtual network gateway')
param Location string = resourceGroup().location

// Customer Usage Attribution Id
var varCuaid = '754599a0-0a6f-424a-b4c5-1b12be198ae8'

// Create an AVS ExR Autorization Key via a module
module AVSAuthorization 'Modules/AVSAuthorization.bicep' = {
  name: 'AVSAuthorization'
  params: {
    AuthKeyName: GatewayName
    PrivateCloudName: PrivateCloudName
  }
  scope: resourceGroup(PrivateCloudSubscriptionId, PrivateCloudResourceGroup)
}

// Get a reference to the existing virtual network gateway
resource Gateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' existing = {
  name: GatewayName
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
