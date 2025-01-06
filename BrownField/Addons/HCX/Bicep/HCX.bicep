@description('The name of the existing Private Cloud to setup HCX on')
param PrivateCloudName string

// Get a reference to the existing private cloud
resource PrivateCloud 'Microsoft.AVS/privateClouds@2023-03-01' existing = {
  name: PrivateCloudName
}

// Customer Usage Attribution Id
var varCuaid = 'ccdff80c-722d-42b7-8bd2-66aba33cba02'

// Set up HCX
resource HCX 'Microsoft.AVS/privateClouds/addons@2023-03-01' = {
  name: 'hcx'
  parent: PrivateCloud
  properties: {
    addonType: 'HCX'
    // At the moment only HCX Advanced can be programatically deployed
    offer: 'VMware MaaS Cloud Provider (Enterprise)'
  }
}

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../BrownField/Addons/CUAID/customerUsageAttribution/cuaIdResourceGroup.bicep' = {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(resourceGroup().location)}'
  params: {}
}
