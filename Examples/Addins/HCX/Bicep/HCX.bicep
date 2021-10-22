@description('The name of the existing Private Cloud to setup HCX on')
param PrivateCloudName string

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
