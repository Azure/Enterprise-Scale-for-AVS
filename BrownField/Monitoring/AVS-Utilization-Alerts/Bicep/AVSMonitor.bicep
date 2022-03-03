@description('Name of the action group to be created')
param ActionGroupName string = 'AVSAlerts'

@description('Prefix to use for alert creation')
param AlertPrefix string = 'AVSAlert'

@description('Email addresses to be added to the action group. Use the format ["name1@domain.com","name2@domain.com"].')
param ActionGroupEmails array = []

@description('The existing Private Cloud full resource id')
param PrivateCloudResourceId string

// Customer Usage Attribution Id
var varCuaid = '6f7b68e9-1179-4853-9dfe-1a4f793b9893'

// Create an action group to be used by the alerts
resource ActionGroup 'microsoft.insights/actionGroups@2019-06-01' = {
  name: ActionGroupName
  location: 'Global'
  properties:{
    enabled: true
    groupShortName: substring('avs${uniqueString(ActionGroupName)}', 0, 12)
    emailReceivers: [for email in ActionGroupEmails: {
      emailAddress: email
      name: split(email, '@')[0]
      useCommonAlertSchema: false
    }]
  }
}

// Define the alerts that will be created as resources
var Alerts = [
  {
    Name: 'CPU'
    Description: 'CPU Usage per Cluster'
    Metric: 'EffectiveCpuAverage'
    SplitDimension: 'clustername'
    Threshold: 80
    Severity: 2
  }
  {
    Name: 'Memory'
    Description: 'Memory Usage per Cluster'
    Metric: 'UsageAverage'
    SplitDimension: 'clustername'
    Threshold: 80
    Severity: 2
  }
  {
    Name: 'Storage'
    Description: 'Storage Usage per Datastore'
    Metric: 'DiskUsedPercentage'
    SplitDimension: 'dsname'
    Threshold: 70
    Severity: 2
  }
  {
    Name: 'StorageCritical'
    Description: 'Storage Usage per Datastore'
    Metric: 'DiskUsedPercentage'
    SplitDimension: 'dsname'
    Threshold: 75
    Severity: 0
  }
]

// Deploy service health alerts
resource ServiceHealthAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: '${AlertPrefix}-ServiceHealth'
  location: 'Global'
  properties: {
    description: 'Service Health Alerts'
    condition:{
      allOf: [
        {
          field: 'category'
          equals: 'ServiceHealth'
        }
        {
          field: 'properties.impactedServices[*].ServiceName'
          containsAny: [
            'Azure VMware Solution'
          ]
        }
        {
          field: 'properties.impactedServices[*].ImpactedRegions[*].RegionName'
          containsAny: [
            reference(PrivateCloudResourceId, '2021-06-01', 'Full').location
            'Global'
          ]
        }
      ]
    }
    scopes: [
      subscription().id
    ]
    enabled: true
    actions: {
      actionGroups: [
        {
          actionGroupId: ActionGroup.id
        }
      ]
    }
  }
}

// Loop through the alerts above and create them
resource MetricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = [for Alert in Alerts: {
  name: '${AlertPrefix}-${Alert.Name}'
  location: 'Global'
  properties: {
    description: Alert.Description
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf:[
        {
          name: 'Metric1'
          operator: 'GreaterThan'
          threshold: Alert.Threshold
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
          metricName: Alert.Metric
          dimensions: [
            {
              name: Alert.SplitDimension
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
        }
      ]
    }
    scopes: [
      PrivateCloudResourceId
    ]
    severity: Alert.Severity
    evaluationFrequency: 'PT5M'
    windowSize: 'PT30M'
    autoMitigate: true
    enabled: true
    actions: [
      {
        actionGroupId: ActionGroup.id
      }
    ]
  }
}]

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../BrownField/Addons/CUAID/customerUsageAttribution/cuaIdResourceGroup.bicep' = {
  #disable-next-line no-loc-expr-outside-params
  name: 'pid-${varCuaid}-${uniqueString(resourceGroup().location)}'
  params: {}
}
