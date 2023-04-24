param PrivateCloudName string = ''
param Workspaceid string = ''
param StorageAccountid string = ''
param StorageRetentionDays int

param DeployAVSLogsWorkspace bool
param DeployAVSLogsStorage bool


resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-12-01' existing = {
  name: PrivateCloudName
}

resource LogAnalyticsDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ((DeployAVSLogsWorkspace)) {
  name: 'Logs-to-Workspace'
  scope: PrivateCloud
  properties: {
    workspaceId: Workspaceid
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    logs: [
      {
        category: 'VMwareSyslog'
        enabled: true
      }
    ]
  }
}

resource StorageAccountDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ((DeployAVSLogsStorage)) {
  name: 'Logs-to-StorageAccount'
  scope: PrivateCloud
  properties: {
    storageAccountId: StorageAccountid
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: StorageRetentionDays
          enabled: true
        }
      }
    ]
    logs: [
      {
        category: 'VMwareSyslog'
        enabled: true
        retentionPolicy: {
          days: StorageRetentionDays
          enabled: true
        }
      }
    ]
  }
}
