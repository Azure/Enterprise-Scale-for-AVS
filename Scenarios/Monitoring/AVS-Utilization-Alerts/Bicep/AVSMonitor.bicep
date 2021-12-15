@description('Name of the action group to be created')
param ActionGroupName string = 'AVSAlerts'

@description('Prefix to use for alert creation')
param AlertPrefix string = 'AVSAlert'

@description('Email adresses that should be added to the action group')
param ActionGroupEmails array = []

@description('The existing Private Cloud full resource id')
param PrivateCloudResourceId string

@description('Optional, the tags that should be applied to all resources. This should be in a json object format, eg: {"tag1":"value1","tag2":"value2"}')
param Tags object = {}

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
  tags: Tags
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
  tags: Tags
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
  tags: Tags
}]
