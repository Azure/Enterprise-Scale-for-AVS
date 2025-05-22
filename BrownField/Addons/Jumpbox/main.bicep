// Consolidated AVS JumpBox Deployment with dual-mode modules
@description('Location for all resources')
param location string = resourceGroup().location

@description('Virtual network name')
param vnetName string = 'jumpbox-vnet'

@description('Address space for the virtual network')
param vnetAddressPrefix string = '10.0.0.0/24'

@description('Name for the VM subnet')
param vmSubnetName string = 'VMSubnet'

@description('Address prefix for the VM subnet')
param vmSubnetPrefix string = '10.0.0.0/27'

@description('Address prefix for the Bastion subnet')
param bastionSubnetPrefix string = '10.0.0.32/27'

@description('Address prefix for the Gateway subnet')
param gatewaySubnetPrefix string = '10.0.0.64/27'

@description('Name for the Jump Box VM')
param vmName string = 'jumpboxvm'

@description('VM Size')
param vmSize string = 'Standard_B4ms'

@description('Size of the data disk in GB')
param dataDiskSizeGB int = 100

@description('Admin username for the VM')
param adminUsername string = 'jumpboxadmin'

@description('Admin password for the VM')
@secure()
param jumpboxAdminPassword string

@description('Tags for all resources')
param tags object = {
  Environment: 'Jumpbox'
  Purpose: 'AVS Management'
}

@description('ExpressRoute circuit ID for AVS SDDC')
param expressRouteCircuitId string = ''

@description('Authorization key for the ExpressRoute circuit')
@secure()
param expressRouteAuthKey string = ''

// Pre-deploy Public IPs at the beginning to allow for parallelism
module bastionPublicIp 'publicip.bicep' = {
  name: 'bastionPublicIpDeployment'
  params: {
    name: '${vnetName}-bastion-pip'
    location: location
    tags: tags
  }
}

module gatewayPublicIp 'publicip.bicep' = {
  name: 'gatewayPublicIpDeployment'
  params: {
    name: '${vnetName}-ergw-pip'
    location: location
    tags: tags
  }
}

// Pre-deploy NSG at the beginning to allow for parallelism
module vmNsg 'nsg.bicep' = {
  name: 'vmNsgDeployment'
  params: {
    name: '${vmName}-nsg'
    location: location
    tags: tags
  }
}

// Deploy the virtual network
module vnet 'vnet.bicep' = {
  name: 'vnetDeployment'
  params: {
    vnetName: vnetName
    location: location
    vnetAddressPrefix: vnetAddressPrefix
    tags: tags
  }
}

// Deploy subnets sequentially to avoid parallel operations on the same VNET
module vmSubnet 'subnet-vm.bicep' = {
  name: 'vmSubnetDeployment'
  params: {    
    vnetName: vnetName
    subnetName: vmSubnetName
    subnetPrefix: vmSubnetPrefix
  }
  dependsOn: [
    vnet
  ]
}

module bastionSubnet 'subnet-bastion.bicep' = {
  name: 'bastionSubnetDeployment'
  params: {
    vnetName: vnetName
    subnetPrefix: bastionSubnetPrefix
  }
  dependsOn: [
    vnet
    vmSubnet
  ]
}

module gatewaySubnet 'subnet-gateway.bicep' = {
  name: 'gatewaySubnetDeployment'
  params: {
    vnetName: vnetName
    subnetPrefix: gatewaySubnetPrefix
  }
  dependsOn: [
    vnet
    bastionSubnet
  ]
}

// Create NIC as soon as VM subnet is available
module vmNic 'nic.bicep' = {
  name: 'vmNicDeployment'
  params: {
    name: '${vmName}-nic'
    location: location
    subnetId: vmSubnet.outputs.subnetId
    nsgId: vmNsg.outputs.nsgId
    tags: tags
  }
  dependsOn: [
    vmSubnet
    vmNsg
  ]
}

// Deploy the jumpbox VM using pre-deployed NIC
module jumpboxVm 'jumpbox-vm.bicep' = {
  name: 'jumpboxVmDeployment'
  params: {    
    vmName: vmName
    location: location
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: jumpboxAdminPassword
    nicId: vmNic.outputs.nicId
    dataDiskSizeGB: dataDiskSizeGB
    tags: tags
  }
  dependsOn: [
    vmNic
  ]
}

// Deploy resources in parallel that depend on specific subnets
module bastionHost 'bastion.bicep' = {
  name: 'bastionDeployment'
  params: {
    bastionName: '${vnetName}-bastion'
    location: location
    subnetId: bastionSubnet.outputs.subnetId
    publicIpId: bastionPublicIp.outputs.publicIpId
    tags: tags
  }
  dependsOn: [
    bastionSubnet
    bastionPublicIp
  ]
}

module erGateway 'ergw.bicep' = {
  name: 'erGatewayDeployment'
  params: {
    gatewayName: '${vnetName}-ergw'
    location: location
    subnetId: gatewaySubnet.outputs.subnetId
    publicIpId: gatewayPublicIp.outputs.publicIpId
    gatewaySku: 'Standard'
    tags: tags
  }
  dependsOn: [
    gatewaySubnet
    gatewayPublicIp
  ]
}

// Auto-shutdown configuration depends only on VM
resource autoShutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${vmName}'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '18:00' // 7PM BST (6PM UTC)
    }
    timeZoneId: 'UTC'
    notificationSettings: {
      status: 'Disabled'
      emailRecipient: ''
      notificationLocale: 'en'
    }
    targetResourceId: jumpboxVm.outputs.vmId
  }
  dependsOn: [
    jumpboxVm
  ]
}

// Create deployment script directly in main.bicep to avoid module parameter issues
resource vmRoleAssignmentIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${vmName}-role-script-identity'
  location: location
  tags: tags
}

resource vmRoleAssignmentRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, vmRoleAssignmentIdentity.id, 'UserAccessAdmin')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9') // User Access Administrator role
    principalId: vmRoleAssignmentIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource vmRoleAssignmentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${vmName}-avs-role-assignment'
  location: location
  tags: tags
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${vmRoleAssignmentIdentity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '7.0'
    retentionInterval: 'P1D'
    timeout: 'PT30M'
    arguments: '-PrincipalId ${jumpboxVm.outputs.systemAssignedIdentityPrincipalId} -ResourceGroupName "${resourceGroup().name}" -ContributorRoleDefinitionId "b24988ac-6180-42a0-ab88-20f7382dd24c"'
    scriptContent: '''
      param(
        [string] $PrincipalId,
        [string] $ResourceGroupName,
        [string] $ContributorRoleDefinitionId
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
          }
          catch {
              Write-Error "Error assigning role: $_"
              $DeploymentScriptOutputs = @{
                  RoleAssignmentCreated = $false
                  Error = $_.ToString()
              }
          }
      }
    '''
  }
  dependsOn: [
    vmRoleAssignmentRoleAssignment
    jumpboxVm
  ]
}

// ExpressRoute Connection depends only on the gateway
module erConnection 'er-connection.bicep' = if (!empty(expressRouteCircuitId) && !empty(expressRouteAuthKey)) {
  name: 'erConnectionDeployment'
  params: {
    connectionName: '${vnetName}-er-connection'
    location: location
    circuitId: expressRouteCircuitId
    authorizationKey: expressRouteAuthKey
    gatewayId: erGateway.outputs.gatewayId
    tags: tags
  }
  dependsOn: [
    erGateway
  ]
}

// Output section
output vnetId string = vnet.outputs.vnetId
output vmSubnetId string = vmSubnet.outputs.subnetId
output vmName string = jumpboxVm.outputs.vmName
output vmPrivateIP string = jumpboxVm.outputs.privateIPAddress
output vmManagedIdentityPrincipalId string = jumpboxVm.outputs.systemAssignedIdentityPrincipalId
output bastionSubnetId string = bastionSubnet.outputs.subnetId
output bastionId string = bastionHost.outputs.bastionId
output gatewaySubnetId string = gatewaySubnet.outputs.subnetId
output erGatewayId string = erGateway.outputs.gatewayId
output erConnectionId string = !empty(expressRouteCircuitId) && !empty(expressRouteAuthKey) ? erConnection.outputs.connectionId : ''
output erConnectionName string = !empty(expressRouteCircuitId) && !empty(expressRouteAuthKey) ? erConnection.outputs.connectionName : ''
