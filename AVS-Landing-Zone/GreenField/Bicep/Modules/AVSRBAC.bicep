targetScope = 'subscription'

param PrivateCloudName string
param PrivateCloudResourceGroup string
param JumpboxSAMIPrincipalId string

module ContributorRBAC 'AVSRBAC/Contributor.bicep' = {
  name: '${deployment().name}-Contributor-RBAC'
  scope: resourceGroup(PrivateCloudResourceGroup)
  params: {
    PrivateCloudName: PrivateCloudName
    JumpboxSAMIPrincipalId: JumpboxSAMIPrincipalId
  }
}
