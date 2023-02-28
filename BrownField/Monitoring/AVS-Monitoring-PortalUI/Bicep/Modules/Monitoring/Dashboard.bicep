param Location string
param PrivateCloudName string
param PrivateCloudResourceId string

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

var PrivateCloudDiskUsedMetric = {
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
                  id: PrivateCloudResourceId
                }
                name: 'UsedLatest'
                aggregationType: 4
                namespace: 'microsoft.avs/privateclouds'
                metricVisualization: {
                  displayName: 'Datastore Disk Used'
                }
              }
            ]
            title: 'Private Cloud Avg Datastore Disk Used'
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
            timespan: {
              relative: {
                duration: 86400000
              }
              showUTCTime: false
              grain: 1
            }
          }
        }
      }
    ]
  }
}

resource Dashboard 'Microsoft.Portal/dashboards@2019-01-01-preview' = {
  name: '${PrivateCloudName}-Dashboard'
  location: Location
  properties: {
    lenses: {
      '0': {
        order: 0
        parts: {
          '0': DashboardHeading
          '1': PrivateCloudLink
          '2': PrivateCloudCPUMetric
          '3': PrivateCloudMemoryMetric
          '4': PrivateCloudDiskMetric
          '5': PrivateCloudDiskUsedMetric
        }
      }
    }
  }
  tags:{
    'hidden-title': 'AVS-Dashboard'
  }
}
