// Consolidated AVS JumpBox Deployment with dual-mode modules
@description('Location for all resources')
param location string = resourceGroup().location

@description('Virtual network name')
param vnetName string = 'jumpbox-vnet'

@description('Address space for the virtual network')
param vnetAddressPrefix string = 'x.y.z.0/24'

@description('Name for the VM subnet')
param vmSubnetName string = 'VMSubnet'

@description('Address prefix for the VM subnet')
param vmSubnetPrefix string = 'x.y.z.0/27'

@description('Address prefix for the Bastion subnet')
param bastionSubnetPrefix string = 'x.y.z.32/27'

@description('Address prefix for the Gateway subnet')
param gatewaySubnetPrefix string = 'x.y.z.64/27'

@description('Name for the Jump Box VM')
param vmName string = 'jumpboxvm'

@description('VM Size')
param vmSize string = 'Standard_B4ms'

@description('Size of the data disk in GB')
param dataDiskSizeGB int = 100

@description('Admin username for the VM')
param adminUsername string = '<CHANGE-ME>'

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
