@description('The name of the dashboard to create')
@minLength(1)
@maxLength(64)
param DashboardName string = 'AVS Dashboard'

@description('Location for this resource, is deployed to the resource group region by default')
param Location string = resourceGroup().location

@description('The full resource ID of the Private Cloud you want displayed on this dashboard')
param PrivateCloudResourceId string

@description('Optional, The full resource ID of the Express Route Connection used by AVS that you want displayed on this dashboard. Can be left empty to remove this metric')
param ExRConnectionResourceId string = ''

@description('Opt-out of deployment telemetry')
param TelemetryOptOut bool = false

var DashboardHeading = {
  position: {
    colSpan: 6
    rowSpan: 1
    x: 0
    y: 0
  }
  metadata: {
    type: 'Extension/HubsExtension/PartType/MarkdownPart'
    inputs: []
    settings: {
      content: {
        settings:{
          content: '# AVS Private Cloud Metrics'
          title: ''
          subtitle: ''
          markdownSource: 1
        }
      }
    }
  }
}

var PrivateCloudLink = {
  position: {
    colSpan: 2
    rowSpan: 1
    x: 6
    y: 0
  }
  metadata:{
    type: 'Extension/HubsExtension/PartType/ResourcePart'
    asset: {
      idInputName: 'id'
    }
    inputs: [
      {
        name: 'id'
        value: PrivateCloudResourceId
      }
    ]
  }
}

var PrivateCloudCPUMetric = {
  position: {
    colSpan: 6
    rowSpan: 4
    x: 0
    y: 1
  }
  metadata: {
    type: 'Extension/HubsExtension/PartType/MonitorChartPart'
    inputs: [
      {
        name: 'options'
        value: {
          chart: {
            metrics: [
              {
                resourceMetadata: {
                  id: PrivateCloudResourceId
                }
                name: 'EffectiveCpuAverage'
                aggregationType: 4
                namespace: 'microsoft.avs/privateclouds'
                metricVisualization: {
                  displayName: 'Percentage CPU'
                }
              }
            ]
            title: 'Percentage CPU by Cluster Name'
            titleKind: 1
            visualization: {
              chartType: 2
              legendVisualization: {
                isVisible: true
                position: 2
                hideSubtitle: false
              }
              axisVisualization: {
                x: {
                  isVisible: true
                  axisType: 2
                }
                y: {
                  isVisible: true
                  axisType: 1
                }
              }
            }
            grouping: {
              dimension: 'clustername'
              sort: 2
              top: 10
            }
          }
        }
      }
    ]
  }
}

var PrivateCloudDiskMetric = {
  position: {
    colSpan: 6
    rowSpan: 4
    x: 6
    y: 1
  }
  metadata: {
    type: 'Extension/HubsExtension/PartType/MonitorChartPart'
    inputs: [
      {
        name: 'options'
        value: {
          chart: {
            metrics: [
              {
                resourceMetadata: {
                  id: PrivateCloudResourceId
                }
                name: 'DiskUsedPercentage'
                aggregationType: 4
                namespace: 'microsoft.avs/privateclouds'
                metricVisualization: {
                  displayName: ' Percentage Datastore Disk Used'
                }
              }
            ]
            title: 'Percentage Datastore Disk Used by Datastore'
            titleKind: 1
            visualization: {
              chartType: 2
              legendVisualization: {
                isVisible: true
                position: 2
                hideSubtitle: false
              }
              axisVisualization: {
                x: {
                  isVisible: true
                  axisType: 2
                }
                y: {
                  isVisible: true
                  axisType: 1
                }
              }
            }
            grouping: {
              dimension: 'dsname'
              sort: 2
              top: 10
            }
          }
        }
      }
    ]
  }
}

var PrivateCloudMemoryMetric = {
  position: {
    colSpan: 6
    rowSpan: 4
    x: 0
    y: 5
  }
  metadata: {
    type: 'Extension/HubsExtension/PartType/MonitorChartPart'
    inputs: [
      {
        name: 'options'
        value: {
          chart: {
            metrics: [
              {
                resourceMetadata: {
                  id: PrivateCloudResourceId
                }
                name: 'UsageAverage'
                aggregationType: 4
                namespace: 'microsoft.avs/privateclouds'
                metricVisualization: {
                  displayName: 'Average Memory Usage'
                }
              }
            ]
            title: 'Average Memory Usage by Cluster Name'
            titleKind: 1
            visualization: {
              chartType: 2
              legendVisualization: {
                isVisible: true
                position: 2
                hideSubtitle: false
              }
              axisVisualization: {
                x: {
                  isVisible: true
                  axisType: 2
                }
                y: {
                  isVisible: true
                  axisType: 1
                }
              }
            }
            grouping: {
              dimension: 'clustername'
              sort: 2
              top: 10
            }
          }
        }
      }
    ]
  }
}

var ExpressRouteConnectionsMetric = {
  position: {
    colSpan: 6
    rowSpan: 4
    x: 6
    y: 5
  }
  metadata: {
    type: 'Extension/HubsExtension/PartType/MonitorChartPart'
    inputs: [
      {
        name: 'options'
        value: {
          chart: {
            metrics: [
              {
                resourceMetadata: {
                  id: ExRConnectionResourceId
                }
                name: 'BitsInPerSecond'
                aggregationType: 4
                namespace: 'microsoft.network/connections'
                metricVisualization: {
                  displayName: 'BitsInPerSecond'
                }
              }
              {
                resourceMetadata: {
                  id: ExRConnectionResourceId
                }
                name: 'BitsOutPerSecond'
                aggregationType: 4
                namespace: 'microsoft.network/connections'
                metricVisualization: {
                  displayName: 'BitsOutPerSecond'
                }
              }
            ]
            title: 'Private Cloud to VNet Utilization'
            titleKind: 1
            visualization: {
              chartType: 2
              legendVisualization: {
                isVisible: true
                position: 2
                hideSubtitle: false
              }
              axisVisualization: {
                x: {
                  isVisible: true
                  axisType: 2
                }
                y: {
                  isVisible: true
                  axisType: 1
                }
              }
            }
            grouping: {
              dimension: 'dsname'
              sort: 2
              top: 10
            }
          }
        }
      }
    ]
  }
}

var PartsIncludingExRConnection = {
  '0': DashboardHeading
  '1': PrivateCloudLink
  '2': PrivateCloudDiskMetric
  '3': PrivateCloudCPUMetric
  '4': PrivateCloudMemoryMetric
  '5': ExpressRouteConnectionsMetric
}

var PartsExcludingExRConnection = {
  '0': DashboardHeading
  '1': PrivateCloudLink
  '2': PrivateCloudDiskMetric
  '3': PrivateCloudCPUMetric
  '4': PrivateCloudMemoryMetric
}

resource Dashboard 'Microsoft.Portal/dashboards@2019-01-01-preview' = {
  name: 'AVSDashboard-${uniqueString(DashboardName)}'
  location: Location
  properties: {
    lenses: {
      '0': {
        order: 0
        parts: empty(ExRConnectionResourceId) ? PartsExcludingExRConnection : PartsIncludingExRConnection
      }
    }
  }
  tags:{
    'hidden-title': DashboardName
  }
}

resource Telemetry 'Microsoft.Resources/deployments@2021-04-01' = if (!TelemetryOptOut) {
  name: 'pid-754599a0-0a6f-424a-b4c5-1b12be198ae8-${uniqueString(resourceGroup().id, Location)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}
