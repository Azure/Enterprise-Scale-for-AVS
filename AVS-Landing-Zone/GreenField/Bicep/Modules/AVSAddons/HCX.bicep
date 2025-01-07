param PrivateCloudName string

resource PrivateCloud 'Microsoft.AVS/privateClouds@2023-03-01' existing = {
  name: PrivateCloudName
}

resource HCX 'Microsoft.AVS/privateClouds/addons@2023-03-01' = {
  name: 'hcx'
  parent: PrivateCloud
  properties: {
    addonType: 'HCX'
    offer: 'VMware MaaS Cloud Provider (Enterprise)'
  }
}
