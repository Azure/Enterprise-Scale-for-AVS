param PrivateCloudName string
param HCXEnterprise bool = false

resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' existing = {
  name: PrivateCloudName
}

resource HCX 'Microsoft.AVS/privateClouds/addons@2021-06-01' = {
  name: 'hcx'
  parent: PrivateCloud
  properties: {
    addonType: 'HCX'
    offer: HCXEnterprise ? 'VMware MaaS Cloud Provider (Enterprise)' : 'VMware MaaS Cloud Provider'
  }
}
