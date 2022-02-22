@description('The name of the existing Private Cloud to setup SRM on')
param PrivateCloudName string

@description('The SRM license key to be used, can be left blank for a trial license')
param SRMLicenseKey string = ''

@description('Number of vSphere Replication servers to be deployed')
@minValue(1)
param ReplicationServerCount int = 1

// Customer Usage Attribution Id
var varCuaid = '754599a0-0a6f-424a-b4c5-1b12be198ae8'

// Get a reference to the existing private cloud
resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' existing = {
  name: PrivateCloudName
}

// Set up SRM
resource SRM 'Microsoft.AVS/privateClouds/addons@2021-06-01' = {
  name: 'srm'
  parent: PrivateCloud
  properties: {
    licenseKey: SRMLicenseKey
    addonType: 'SRM'
  }
}


// Set up the vSphere Replication servers
resource VR 'Microsoft.AVS/privateClouds/addons@2021-06-01' = {
  name: 'vr'
  parent: PrivateCloud
  properties: {
    vrsCount: ReplicationServerCount
    addonType: 'VR'
  }
  dependsOn: [
    SRM
  ]
}

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../BrownField/Addons/CUAID/customerUsageAttribution/cuaIdResourceGroup.bicep' = {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(resourceGroup().location)}'
  params: {}
}
