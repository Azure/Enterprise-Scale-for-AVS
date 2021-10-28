@description('Name of the action group to be created')
param ActionGroupName string = 'AVSAlerts'

@description('Prefix to use for alert creation')
param AlertPrefix string = 'AVSAlert'

@description('Email adresses that should be added to the action group')
param ActionGroupEmails array = []

@description('The existing Private Cloud full resource id')
param PrivateCloudResourceId string

// Create an action group to be used by the alerts
resource ActionGroup 'microsoft.insights/actionGroups@2019-06-01' = {
  name: ActionGroupName
  location: 'Global'
  properties:{
    enabled: true
    groupShortName: ActionGroupName
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
            reference(PrivateCloudResourceId).location
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
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    autoMitigate: true
    enabled: true
    actions: [
      {
        actionGroupId: ActionGroup.id
      }
    ]
  }
}]
