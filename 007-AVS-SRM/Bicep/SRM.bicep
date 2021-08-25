param PrivateCloudName string
param SRMLicenseKey string = ''

resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' existing = {
  name: PrivateCloudName
}

resource SRM 'Microsoft.AVS/privateClouds/addons@2021-06-01' = {
  name: 'srm'
  parent: PrivateCloud
  properties: {
    licenseKey: SRMLicenseKey
    addonType: 'SRM'
  }
}
