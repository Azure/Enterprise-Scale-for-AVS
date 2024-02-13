param Location string
param NewWorkspaceName string
@sys.description('Tags to be applied to resources')
param tags object


resource Workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: NewWorkspaceName
  location: Location
  tags: tags
}

output WorkspaceId string = Workspace.id
