param Location string
param NewWorkspaceName string


resource Workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: NewWorkspaceName
  location: Location
}

output WorkspaceId string = Workspace.id
