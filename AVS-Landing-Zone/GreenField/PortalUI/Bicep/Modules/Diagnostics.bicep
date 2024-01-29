targetScope = 'subscription'

param Location string = ''
param LoggingResourceGroupName string = ''
param PrivateCloudName string = ''
param PrivateCloudResourceId string = ''
param EnableAVSLogsWorkspaceSetting bool = false
param NewWorkspaceName string = ''
param NewStorageAccountName string = ''
param DeployActivityLogDiagnostics bool = false
param EnableAVSLogsStorageSetting bool = false
param ExistingWorkspaceId string
param ExistingStorageAccountId string
param DeployWorkspace bool
param DeployStorageAccount bool
@sys.description('Tags to be applied to resources')
param tags object

var PrivateCloudResourceGroupName = split(PrivateCloudResourceId,'/')[4]

resource LoggingResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if ((DeployWorkspace) || (DeployStorageAccount)) {
  name: LoggingResourceGroupName
  location: Location
  tags: tags
}

resource PrivateCloudResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: PrivateCloudResourceGroupName
}

module Workspace 'Diagnostics/Workspace.bicep' = if ((DeployWorkspace)) {
  scope: LoggingResourceGroup
  name: '${deployment().name}-Workspace'
  params: {
    Location: Location
    NewWorkspaceName: NewWorkspaceName
    tags: tags
  }
}

module Storage 'Diagnostics/Storage.bicep' = if (DeployStorageAccount) {
  scope: LoggingResourceGroup
  name: '${deployment().name}-Storage'
  params: {
    Location: Location
    NewStorageAccountName: NewStorageAccountName
    tags: tags
  }
}

module AVSDiagnostics 'Diagnostics/AVSDiagnostics.bicep' = if ((EnableAVSLogsWorkspaceSetting) || (EnableAVSLogsStorageSetting)) {
  scope: PrivateCloudResourceGroup
  name: '${deployment().name}-AVSDiagnostics'
  params: {
    PrivateCloudName: PrivateCloudName
    Workspaceid: DeployWorkspace ? Workspace.outputs.WorkspaceId : ExistingWorkspaceId
    StorageAccountid : DeployStorageAccount ? Storage.outputs.StorageAccountid : ExistingStorageAccountId
    EnableAVSLogsWorkspaceSetting : EnableAVSLogsWorkspaceSetting
    EnableAVSLogsStorageSetting : EnableAVSLogsStorageSetting
  }
}

module ActivityLogDiagnostics 'Diagnostics/ActivityLogDiagnostics.bicep' = if (DeployActivityLogDiagnostics) {
  name: '${deployment().name}-ActivityLogDiagnostics'
  params: {
    WorkspaceId: (DeployWorkspace) ? Workspace.outputs.WorkspaceId : ExistingWorkspaceId
  }
}
