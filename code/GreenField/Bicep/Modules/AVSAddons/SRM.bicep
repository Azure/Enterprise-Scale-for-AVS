param PrivateCloudName string
param SRMLicenseKey string
@minValue(1)
@maxValue(10)
param VRServerCount int

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
    vrsCount: VRServerCount
    addonType: 'VR'
  }
  dependsOn: [
    SRM
  ]
}

