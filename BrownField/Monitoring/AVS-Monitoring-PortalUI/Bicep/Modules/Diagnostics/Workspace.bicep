param Prefix string
param Location string


resource Workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${Prefix}-Workspace'
  location: Location
}

output WorkspaceId string = Workspace.id
