targetScope = 'subscription'

param DeployMetricAlerts bool
param DeployServiceHealth bool
param DeployDashboard bool
param Location string
param AlertEmails string
param PrivateCloudResourceGroup string
param PrivateCloudName string
param PrivateCloudResourceId string

resource OperationalResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: PrivateCloudResourceGroup
}

module ActionGroup 'Monitoring/ActionGroup.bicep' = if ((DeployMetricAlerts) || (DeployServiceHealth)) {
  scope: OperationalResourceGroup
  name: '${deployment().name}-ActionGroup'
  params: {
    Prefix : PrivateCloudName
    ActionGroupEmails: AlertEmails
  }
}

module PrimaryMetricAlerts 'Monitoring/MetricAlerts.bicep' = if (DeployMetricAlerts) {
  scope: OperationalResourceGroup
  name: '${deployment().name}-MetricAlerts'
  params: {
    ActionGroupResourceId: ActionGroup.outputs.ActionGroupResourceId
    AlertPrefix: PrivateCloudName
    PrivateCloudResourceId: PrivateCloudResourceId
  }
}

module ServiceHealth 'Monitoring/ServiceHealth.bicep' = if (DeployServiceHealth) {
  scope: OperationalResourceGroup
  name: '${deployment().name}-ServiceHealth'
  params: {
    ActionGroupResourceId: ActionGroup.outputs.ActionGroupResourceId
    AlertPrefix: PrivateCloudName
    PrivateCloudResourceId: PrivateCloudResourceId
  }
}

module Dashboard 'Monitoring/Dashboard.bicep' =  if (DeployDashboard) {
  scope: OperationalResourceGroup
  name: '${deployment().name}-Dashboard'
  params:{
    PrivateCloudName : PrivateCloudName
    Location: Location
    PrivateCloudResourceId: PrivateCloudResourceId
  }
}
