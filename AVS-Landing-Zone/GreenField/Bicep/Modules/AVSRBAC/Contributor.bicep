param PrivateCloudName string
param JumpboxSAMIPrincipalId string 

resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-06-01' existing = {
  name: PrivateCloudName
}

var contributorRoleDefinitionId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource JumpboxVMasAVSPrivateCloudContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(PrivateCloud.id, resourceGroup().id, contributorRoleDefinitionId)
  scope: PrivateCloud
  properties: {
    description: 'Jumpbox VM Contributor role assignment on AVS Private Cloud'
    principalId: JumpboxSAMIPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions',contributorRoleDefinitionId )
  }
}
