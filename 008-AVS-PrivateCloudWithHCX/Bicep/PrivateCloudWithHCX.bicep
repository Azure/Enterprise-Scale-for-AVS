param PrivateCloudName string
param NetworkBlock string
param ManagementClusterSize int = 3
param Location string = resourceGroup().location
param InternetEnabled bool = false
param HCXEnterprise bool = false

resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' = {
  name: PrivateCloudName
  sku: {
    name: 'AV36'
  }
  location: Location
  properties: {
    networkBlock: NetworkBlock
    internet: InternetEnabled ? 'Enabled' : 'Disabled'
    managementCluster: {
      clusterSize: ManagementClusterSize
    }
  }
}

resource HCX 'Microsoft.AVS/privateClouds/addons@2021-06-01' = {
  name: 'hcx'
  parent: PrivateCloud
  properties: {
    addonType: 'HCX'
    offer: HCXEnterprise ? 'VMware MaaS Cloud Provider (Enterprise)' : 'VMware MaaS Cloud Provider'
  }
}
