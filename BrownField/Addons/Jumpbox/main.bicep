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
module bastionPublicIp 'br/public:avm/res/network/public-ip-address:0.8.0' = {
  name: 'bastionPublicIpDeployment'
  params: {
    name: '${vnetName}-bastion-pip'
    location: location
    tags: tags
    publicIPAllocationMethod: 'Static'
    skuName: 'Standard'
    skuTier: 'Regional'
  }
}

module gatewayPublicIp 'br/public:avm/res/network/public-ip-address:0.8.0' = {
  name: 'gatewayPublicIpDeployment'
  params: {
    name: '${vnetName}-ergw-pip'
    location: location
    tags: tags
    publicIPAllocationMethod: 'Static'
    skuName: 'Standard'
    skuTier: 'Regional'
  }
}

// Pre-deploy NSG at the beginning to allow for parallelism
module vmNsg 'br/public:avm/res/network/network-security-group:0.5.1' = {
  name: 'vmNsgDeployment'
  params: {
    name: '${vmName}-nsg'
    location: location
    tags: tags
    securityRules: [
      {
        name: 'AllowRDPFromVNet'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 1000
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
    ]
  }
}

// Deploy the virtual network with all subnets using AVM
module vnet 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'vnetDeployment'
  params: {
    name: vnetName
    location: location
    addressPrefixes: [
      vnetAddressPrefix
    ]
    subnets: [
      {
        name: vmSubnetName
        addressPrefix: vmSubnetPrefix
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
      {
        name: 'AzureBastionSubnet'
        addressPrefix: bastionSubnetPrefix
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Disabled'
      }
      {
        name: 'GatewaySubnet'
        addressPrefix: gatewaySubnetPrefix
      }
    ]
    tags: tags
  }
}

// Create NIC using AVM Network Interface module
module vmNic 'br/public:avm/res/network/network-interface:0.3.0' = {
  name: 'vmNicDeployment'
  params: {
    name: '${vmName}-nic'
    location: location
    ipConfigurations: [
      {
        name: 'ipconfig1'
        subnetResourceId: vnet.outputs.subnetResourceIds[0]  // VMSubnet is first in array
        privateIPAllocationMethod: 'Dynamic'
      }
    ]
    networkSecurityGroupResourceId: vmNsg.outputs.resourceId
    tags: tags
  }
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
    nicId: vmNic.outputs.resourceId  // Updated to use AVM NIC output
    dataDiskSizeGB: dataDiskSizeGB
    tags: tags
  }
}

// Deploy resources in parallel that depend on specific subnets
module bastionHost 'bastion.bicep' = {
  name: 'bastionDeployment'
  params: {
    bastionName: '${vnetName}-bastion'
    location: location
    subnetId: vnet.outputs.subnetResourceIds[1]  // AzureBastionSubnet is second in array
    publicIpId: bastionPublicIp.outputs.resourceId
    tags: tags
  }
}

module erGateway 'ergw.bicep' = {
  name: 'erGatewayDeployment'
  params: {
    gatewayName: '${vnetName}-ergw'
    location: location
    subnetId: vnet.outputs.subnetResourceIds[2]  // GatewaySubnet is third in array
    publicIpId: gatewayPublicIp.outputs.resourceId
    gatewaySku: 'Standard'
    tags: tags
  }
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
}

// Output section
output vnetId string = vnet.outputs.resourceId
output vmSubnetId string = vnet.outputs.subnetResourceIds[0]  // VMSubnet
output vmName string = jumpboxVm.outputs.vmName
output vmPrivateIP string = jumpboxVm.outputs.privateIPAddress
output vmManagedIdentityPrincipalId string = jumpboxVm.outputs.systemAssignedIdentityPrincipalId
output bastionSubnetId string = vnet.outputs.subnetResourceIds[1]  // AzureBastionSubnet
output bastionId string = bastionHost.outputs.bastionId
output gatewaySubnetId string = vnet.outputs.subnetResourceIds[2]  // GatewaySubnet
output erGatewayId string = erGateway.outputs.gatewayId
output erConnectionId string = !empty(expressRouteCircuitId) ? erConnection.outputs.connectionId : ''
output erConnectionName string = !empty(expressRouteCircuitId) ? erConnection.outputs.connectionName : ''
