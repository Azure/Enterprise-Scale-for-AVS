targetScope = 'subscription'

param Prefix string
param PrimaryLocation string
param AlertEmails array
param PrimaryPrivateCloudName string
param PrimaryPrivateCloudResourceId string
param JumpboxResourceId string
param VNetResourceId string
param ExRConnectionResourceId string

resource OperationalResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  name: '${Prefix}-Operational'
  location: PrimaryLocation
}

module ActionGroup 'Module-Operational-ActionGroup.bicep' = {
  scope: OperationalResourceGroup
  name: 'ESLZDeploy-Monitoring-ActionGroup'
  params: {
    Prefix: Prefix
    ActionGroupEmails: AlertEmails
  }
}

module PrimaryMetricAlerts 'Module-Operational-MetricAlerts.bicep' = {
  scope: OperationalResourceGroup
  name: 'ESLZDeploy-Monitoring-MetricAlerts'
  params: {
    ActionGroupResourceId: ActionGroup.outputs.ActionGroupResourceId
    AlertPrefix: PrimaryPrivateCloudName
    PrivateCloudResourceId: PrimaryPrivateCloudResourceId
  }
}

module Dashboard 'Module-Operational-Dashboard.bicep' = {
  scope: OperationalResourceGroup
  name: 'ESLZDeploy-Monitoring-Dashboard'
  params:{
    Prefix: Prefix
    Location: PrimaryLocation
    PrivateCloudResourceId: PrimaryPrivateCloudResourceId
    JumpboxResourceId: JumpboxResourceId
    ExRConnectionResourceId: ExRConnectionResourceId
    VNetResourceId: VNetResourceId
  }
}
