param AlertPrefix string
param ActionGroupResourceId string
param PrivateCloudResourceId string
param CPUUsageThreshold int
param MemoryUsageThreshold int
param StorageUsageThreshold int
param CPUCriticalThreshold int = 95
param MemoryCriticalThreshold int = 95
param StorageCriticalThreshold int = 75
param tags object

var Alerts = [
  {
    Name: 'CPU'
    Description: 'CPU Usage per Cluster'
    Metric: 'EffectiveCpuAverage'
    SplitDimension: 'clustername'
    Threshold: CPUUsageThreshold
    Severity: 2
  }
  {
    Name: 'Memory'
    Description: 'Memory Usage per Cluster'
    Metric: 'UsageAverage'
    SplitDimension: 'clustername'
    Threshold: MemoryUsageThreshold
    Severity: 2
  }
  {
    Name: 'Storage'
    Description: 'Storage Usage per Datastore'
    Metric: 'DiskUsedPercentage'
    SplitDimension: 'dsname'
    Threshold: StorageUsageThreshold
    Severity: 2
  }
  {
    Name: 'CPUCritical'
    Description: 'CPU Critical Usage per Cluster'
    Metric: 'EffectiveCpuAverage'
    SplitDimension: 'clustername'
    Threshold: CPUCriticalThreshold
    Severity: 0
  }
  {
    Name: 'MemoryCritical'
    Description: 'Memory Critical Usage per Cluster'
    Metric: 'UsageAverage'
    SplitDimension: 'clustername'
    Threshold: MemoryCriticalThreshold
    Severity: 0
  }
  {
    Name: 'StorageCritical'
    Description: 'Storage Critical Usage per Datastore'
    Metric: 'DiskUsedPercentage'
    SplitDimension: 'dsname'
    Threshold: StorageCriticalThreshold
    Severity: 0
  }
]

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
        actionGroupId: ActionGroupResourceId
      }
    ]
  }
  tags: tags
}]
