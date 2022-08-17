param resourceGroups array = [
  'private_cloud_rg2'
  'networking_rg2'
  'operational_rg2'
  'jumpbox_rg2'
]

param resourceGroupLocation string = 'northeurope'

param resourceTags object = {
  'deploymentMethod': 'Bicep'
  'Can Be Deleted': 'yes'
  'Technology': 'AVS'
}

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = [for resourceGroup in resourceGroups: {
  name: resourceGroup
  location: resourceGroupLocation
  tags: resourceTags
}]


output deployedResourceGroups array = resourceGroups
