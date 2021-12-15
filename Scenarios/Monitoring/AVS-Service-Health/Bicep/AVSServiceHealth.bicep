@description('Email adresses that should be added to the action group. This should either be a single email, or a comma separated list: abc@example.com,def@example.com')
param ActionGroupEmails string = ''

@description('The existing Private Cloud full resource id')
param PrivateCloudResourceId string

var suffix = uniqueString(PrivateCloudResourceId)

var formattedEmails = empty(trim(ActionGroupEmails)) ? [] : split(ActionGroupEmails, ',')

// Create an action group to be used by the service health alert
resource ActionGroup 'microsoft.insights/actionGroups@2019-06-01' = {
  name: 'AVS-ServiceHealth-${suffix}'
  location: 'Global'
  properties:{
    enabled: true
    groupShortName: substring('avs${suffix}', 0, 12)
    emailReceivers: [for email in formattedEmails: {
      emailAddress: trim(email)
      name: trim(split(email, '@')[0])
      useCommonAlertSchema: false
    }]
  }
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
}
