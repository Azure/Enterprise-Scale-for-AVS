param Prefix string
param Location string
param PrivateCloudResourceId string
param ExRConnectionResourceId string

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
          content: '# ${Prefix}-SDDC Private Cloud Metrics'
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
    colSpan: 6
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

resource Dashboard 'Microsoft.Portal/dashboards@2019-01-01-preview' = {
  name: '${Prefix}-Dashboard'
  location: Location
  properties: {
    lenses: {
      '0': {
        order: 0
        parts: {
          '0': DashboardHeading
          '1': PrivateCloudLink
          '2': PrivateCloudDiskMetric
          '3': PrivateCloudCPUMetric
          '4': PrivateCloudMemoryMetric
          '5': ExpressRouteConnectionsMetric
        }
      }
    }
  }
  tags:{
    'hidden-title': '${Prefix}-Dashboard'
  }
}
