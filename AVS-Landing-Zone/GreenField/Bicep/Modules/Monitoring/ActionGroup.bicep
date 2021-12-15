param Prefix string
param ActionGroupEmails array = []

resource ActionGroup 'microsoft.insights/actionGroups@2019-06-01' = {
  name: '${Prefix}-ActionGroup'
  location: 'Global'
  properties:{
    enabled: true
    groupShortName: substring('avs${uniqueString(Prefix)}', 0, 12)
    emailReceivers: [for email in ActionGroupEmails: {
      emailAddress: email
      name: split(email, '@')[0]
      useCommonAlertSchema: false
    }]
  }
}

output ActionGroupResourceId string = ActionGroup.id
