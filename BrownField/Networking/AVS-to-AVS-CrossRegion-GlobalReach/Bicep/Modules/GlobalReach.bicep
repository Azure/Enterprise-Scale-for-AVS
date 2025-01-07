@description('The existing Private Cloud name')
param PrivateCloudName string

@description('The Express Route Authorization Key to be redeemed by the connection')
@secure()
param ExpressRouteAuthorizationKey string

@description('The id of the Express Route to create the connection to')
@secure()
param ExpressRouteId string

// Customer Usage Attribution Id
var varCuaid = '1593acc2-6932-462b-af58-28f7fa9df52d'

// Get a reference to the existing private cloud
resource PrivateCloud 'Microsoft.AVS/privateClouds@2023-03-01' existing = {
  name: PrivateCloudName
}

// Create the global reach link
resource GlobalReach 'Microsoft.AVS/privateClouds/globalReachConnections@2023-03-01' = {
  name: guid(ExpressRouteId, ExpressRouteAuthorizationKey)
  parent: PrivateCloud
  properties: {
    authorizationKey: ExpressRouteAuthorizationKey
    peerExpressRouteCircuit: ExpressRouteId
  }
}

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../../BrownField/Addons/CUAID/customerUsageAttribution/cuaIdResourceGroup.bicep' = {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(resourceGroup().location)}'
  params: {}
}
