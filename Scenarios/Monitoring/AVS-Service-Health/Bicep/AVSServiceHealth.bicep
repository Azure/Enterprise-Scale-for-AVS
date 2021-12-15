@description('Email adresses that should be added to the action group')
param ActionGroupEmails array = []

@description('The existing Private Cloud full resource id')
param PrivateCloudResourceId string

@description('Optional, the tags that should be applied to all resources. This should be in a json object format, eg: {"tag1":"value1","tag2":"value2"}')
param Tags object = {}

var suffix = uniqueString(PrivateCloudResourceId)

// Create an action group to be used by the service health alert
resource ActionGroup 'microsoft.insights/actionGroups@2019-06-01' = {
  name: 'AVS-ServiceHealth-${suffix}'
  location: 'Global'
  properties:{
    enabled: true
    groupShortName: substring('avs${suffix}', 0, 12)
    emailReceivers: [for email in ActionGroupEmails: {
      emailAddress: email
      name: split(email, '@')[0]
      useCommonAlertSchema: false
    }]
  }
  tags: Tags
}

// Deploy service health alerts
resource ServiceHealthAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: 'AVS-ServiceHealth-${suffix}'
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
