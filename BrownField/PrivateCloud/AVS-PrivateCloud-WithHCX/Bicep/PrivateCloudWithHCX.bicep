@description('The name of the Private Cloud to be created')
param PrivateCloudName string

@description('The network block to be used for the management address space, should be a valid /22 CIDR block in the format: 10.0.0.0/22')
param NetworkBlock string

@description('Size of the management (first) cluster within the Private Cloud')
param ManagementClusterSize int = 3

@description('The location the Private Cloud should be deployed to. Must have quota in this region prior to deployment')
param Location string = resourceGroup().location

@description('Opt-out of deployment telemetry')
param TelemetryOptOut bool = false

// Customer Usage Attribution Id
var varCuaid = '99f18c8b-1767-4302-9cee-ecc0d135dd52'

// Create the Private Cloud
resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' = {
  name: PrivateCloudName
  sku: {
    name: 'AV36P'
  }
  location: Location
  properties: {
    networkBlock: NetworkBlock
    managementCluster: {
      clusterSize: ManagementClusterSize
    }
  }
}

// Setup HCX
resource HCX 'Microsoft.AVS/privateClouds/addons@2021-06-01' = {
  name: 'hcx'
  parent: PrivateCloud
  properties: {
    addonType: 'HCX'
    offer: 'VMware MaaS Cloud Provider'
  }
}

resource Telemetry 'Microsoft.Resources/deployments@2021-04-01' = if (!TelemetryOptOut) {
  name: 'pid-754599a0-0a6f-424a-b4c5-1b12be198ae8-${uniqueString(resourceGroup().id, PrivateCloudName, Location)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../BrownField/Addons/CUAID/customerUsageAttribution/cuaIdResourceGroup.bicep' = {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(resourceGroup().location)}'
  params: {}
}
