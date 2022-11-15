targetScope = 'subscription'

param Location string = ''
param Prefix string = ''
param PrivateCloudName string = ''
param PrivateCloudResourceId string = ''
param DeployAVSLogsWorkspace bool = false
param DeployActivityLogDiagnostics bool = false
param DeployAVSLogsStorage bool = false
param ExistingWorkspaceId string
param ExistingStorageAccountId string
param StorageRetentionDays int
param DeployWorkspace bool
param DeployStorageAccount bool


var PrivateCloudResourceGroupName = split(PrivateCloudResourceId,'/')[4]

resource OperationalResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${Prefix}-Operational'
  location: Location
}

resource PrivateCloudResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: PrivateCloudResourceGroupName
}

module Workspace 'Diagnostics/Workspace.bicep' = if ((DeployWorkspace)) {
  scope: OperationalResourceGroup
  name: '${deployment().name}-Workspace'
  params: {
    Location: Location
    Prefix: Prefix
  }
}

module Storage 'Diagnostics/Storage.bicep' = if (DeployStorageAccount) {
  scope: OperationalResourceGroup
  name: '${deployment().name}-Storage'
  params: {
    Location: Location
  }
}

module AVSDiagnostics 'Diagnostics/AVSDiagnostics.bicep' = if ((DeployAVSLogsWorkspace) || (DeployAVSLogsStorage)) {
  scope: PrivateCloudResourceGroup
  name: '${deployment().name}-AVSDiagnostics'
  params: {
    PrivateCloudName: PrivateCloudName
    Workspaceid: DeployWorkspace ? Workspace.outputs.WorkspaceId : ExistingWorkspaceId
    StorageAccountid : DeployStorageAccount ? Storage.outputs.StorageAccountid : ExistingStorageAccountId
    DeployAVSLogsWorkspace : DeployAVSLogsWorkspace
    DeployAVSLogsStorage : DeployAVSLogsStorage
    StorageRetentionDays : StorageRetentionDays
  }
}

module ActivityLogDiagnostics 'Diagnostics/ActivityLogDiagnostics.bicep' = if (DeployActivityLogDiagnostics) {
  name: '${deployment().name}-ActivityLogDiagnostics'
  params: {
    WorkspaceId: DeployWorkspace ? Workspace.outputs.WorkspaceId : ExistingWorkspaceId
  }
}
