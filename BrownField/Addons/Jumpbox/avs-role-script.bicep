@description('Principal ID of the managed identity to assign the role to')
param principalId string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Name for the deployment script resource')
param scriptName string = 'assign-avs-role'

@description('Contributor role definition ID')
param contributorRoleId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@description('Tags for all resources')
param tags object = {}

// Create user-assigned managed identity for the deployment script
resource scriptIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${scriptName}-identity'
  location: location
  tags: tags
}

// Assign User Access Administrator role to the deployment script's managed identity
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, scriptIdentity.id, 'UserAccessAdmin')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9') // User Access Administrator role
    principalId: scriptIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Deployment script that will find AVS Private Clouds and assign Contributor role
resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: scriptName
  location: location
  tags: tags
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${scriptIdentity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '7.0'
    retentionInterval: 'P1D'
    timeout: 'PT30M'
    cleanupPreference: 'OnSuccess'
    arguments: '-PrincipalId ${principalId} -ResourceGroupName "${resourceGroup().name}" -ContributorRoleDefinitionId "${contributorRoleId}" -ManagedIdentityName "${scriptIdentity.name}" -RoleAssignmentId "${roleAssignment.name}"'    scriptContent: '''
      param(
        [string] $PrincipalId,
        [string] $ResourceGroupName,
        [string] $ContributorRoleDefinitionId,
        [string] $ManagedIdentityName,
        [string] $RoleAssignmentId
      )

      # Sleep to allow role assignment to propagate
      Write-Output "Waiting for role assignment propagation..."
      Start-Sleep -Seconds 60

      # Find all AVS Private Clouds in the resource group
      Write-Output "Finding AVS Private Clouds in resource group $ResourceGroupName..."
      $avsPrivateClouds = Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType "Microsoft.AVS/privateClouds"
      
      if ($avsPrivateClouds.Count -eq 0) {
          Write-Output "No AVS Private Clouds found in resource group $ResourceGroupName"
          $DeploymentScriptOutputs = @{
              RoleAssignmentCreated = $false
              Message = "No AVS Private Clouds found in resource group $ResourceGroupName"
          }
          exit 0
      }
      
      $roleDefinitionId = "/subscriptions/$((Get-AzContext).Subscription.Id)/providers/Microsoft.Authorization/roleDefinitions/$ContributorRoleDefinitionId"
      
      foreach ($avsPrivateCloud in $avsPrivateClouds) {
          Write-Output "Found AVS Private Cloud: $($avsPrivateCloud.Name)"
          try {
              # Check if the role assignment already exists
              $existingAssignment = Get-AzRoleAssignment -ObjectId $PrincipalId -RoleDefinitionId $roleDefinitionId -Scope $avsPrivateCloud.ResourceId -ErrorAction SilentlyContinue
              
              if ($null -eq $existingAssignment) {
                  Write-Output "Assigning Contributor role to Principal ID $PrincipalId on AVS Private Cloud $($avsPrivateCloud.Name)..."
                  New-AzRoleAssignment -ObjectId $PrincipalId -RoleDefinitionId $ContributorRoleDefinitionId -Scope $avsPrivateCloud.ResourceId
                  Write-Output "Role assignment created successfully"
                  $DeploymentScriptOutputs = @{
                      RoleAssignmentCreated = $true
                      AVSPrivateCloudName = $avsPrivateCloud.Name
                      AVSPrivateCloudId = $avsPrivateCloud.ResourceId
                  }
              }
              else {
                  Write-Output "Role assignment already exists for Principal ID $PrincipalId on AVS Private Cloud $($avsPrivateCloud.Name)"
                  $DeploymentScriptOutputs = @{
                      RoleAssignmentCreated = $true
                      AVSPrivateCloudName = $avsPrivateCloud.Name
                      AVSPrivateCloudId = $avsPrivateCloud.ResourceId
                      Message = "Role assignment already exists"
                  }
              }
          }          catch {
              Write-Error "Error assigning role: $_"
              $DeploymentScriptOutputs = @{
                  RoleAssignmentCreated = $false
                  Error = $_.ToString()
              }
          }
      }

      # The cleanup of the deployment script itself is handled by the cleanupPreference property
      # This script runs with the deployment script's managed identity that has User Access Admin role
      # so it can remove its own role assignment
      
      # Let the script complete its primary task first before attempting cleanup
      Start-Sleep -Seconds 10
        try {
          Write-Output "Cleaning up role assignment $RoleAssignmentId..."
          # Need to remove the role assignment using its id
          $roleAssignmentId = "/subscriptions/$((Get-AzContext).Subscription.Id)/resourceGroups/$ResourceGroupName/providers/Microsoft.Authorization/roleAssignments/$RoleAssignmentId"
          Remove-AzRoleAssignment -RoleDefinitionName "User Access Administrator" -Scope "/subscriptions/$((Get-AzContext).Subscription.Id)/resourceGroups/$ResourceGroupName" -ObjectId (Get-AzUserAssignedIdentity -ResourceGroupName $ResourceGroupName -Name $ManagedIdentityName).PrincipalId -ErrorAction SilentlyContinue
          Write-Output "Role assignment cleanup completed"
      }
      catch {
          Write-Output "Note: Role assignment cleanup failed, but this won't affect the primary task: $_"
      }
    '''
  }  // The script depends on the role assignment existing, but Bicep will infer this automatically
}

output roleAssignmentCreated bool = deploymentScript.properties.outputs.?RoleAssignmentCreated ?? false
output avsPrivateCloudId string = deploymentScript.properties.outputs.?AVSPrivateCloudId ?? ''
output message string = deploymentScript.properties.outputs.?Message ?? 'Role assignment process completed'
