@description('The name of the existing Private Cloud to setup HCX on')
param PrivateCloudName string

@description('Set Parameter to true to Opt-out of deployment telemetry')
param parTelemetryOptOut bool = false

// Customer Usage Attribution Id
var varCuaid = '754599a0-0a6f-424a-b4c5-1b12be198ae8'

// Get a reference to the existing private cloud
resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' existing = {
  name: PrivateCloudName
}

// Set up HCX
resource HCX 'Microsoft.AVS/privateClouds/addons@2021-06-01' = {
  name: 'hcx'
  parent: PrivateCloud
  properties: {
    addonType: 'HCX'
    // At the moment only HCX Advanced can be programatically deployed
    offer: 'VMware MaaS Cloud Provider'
  }
}

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../CRML/customerUsageAttribution/cuaIdResourceGroup.bicep' = if (!parTelemetryOptOut) {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(resourceGroup().location)}'
  params: {}
}

