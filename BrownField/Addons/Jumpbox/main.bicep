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

@description('Admin password for the VM - provided at deployment time')
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

// Pre-deploy Public IP for Bastion at the beginning to allow for parallelism
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

// Note: Gateway Public IP is now handled by the AVM Virtual Network Gateway module

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

// Deploy the jumpbox VM using AVM Virtual Machine module
module jumpboxVm 'br/public:avm/res/compute/virtual-machine:0.15.0' = {
  name: 'jumpboxVmDeployment'
  params: {
    name: vmName
    location: location
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: jumpboxAdminPassword
    osType: 'Windows'
    zone: 0
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2019-Datacenter'
      version: 'latest'
    }
    osDisk: {
      diskSizeGB: 128
      caching: 'ReadWrite'
      createOption: 'FromImage'
      managedDisk: {
        storageAccountType: 'Standard_LRS'
      }
    }
    dataDisks: [
      {        
        diskSizeGB: dataDiskSizeGB
        lun: 0
        caching: 'None'
        createOption: 'Empty'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }      
      }
    ]
    nicConfigurations: [
      {
        nicSuffix: '-nic'
        deleteOption: 'Delete'
        enableAcceleratedNetworking: false  // Explicitly disable for Standard_B4ms
        ipConfigurations: [
          {
            name: 'ipconfig1'
            subnetResourceId: vnet.outputs.subnetResourceIds[0]  // VMSubnet
            privateIPAllocationMethod: 'Dynamic'
          }
        ]
        networkSecurityGroupResourceId: vmNsg.outputs.resourceId
      }
    ]
    managedIdentities: {
      systemAssigned: true
    }
    bootDiagnostics: true
    tags: tags
  }
}

// Deploy Bastion Host using AVM module
module bastionHost 'br/public:avm/res/network/bastion-host:0.6.1' = {
  name: 'bastionDeployment'
  params: {
    name: '${vnetName}-bastion'
    location: location
    virtualNetworkResourceId: vnet.outputs.resourceId
    bastionSubnetPublicIpResourceId: bastionPublicIp.outputs.resourceId
    skuName: 'Standard'
    tags: tags
  }
}

// Deploy ExpressRoute Gateway using AVM Virtual Network Gateway module
module erGateway 'br/public:avm/res/network/virtual-network-gateway:0.4.0' = {
  name: 'erGatewayDeployment'
  params: {
    name: '${vnetName}-ergw'
    location: location
    gatewayType: 'ExpressRoute'
    vNetResourceId: vnet.outputs.resourceId
    clusterSettings: {
      clusterMode: 'activePassiveNoBgp'
    }
    skuName: 'Standard'
    gatewayPipName: '${vnetName}-ergw-pip' // Use existing if not create new public IP
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
    targetResourceId: jumpboxVm.outputs.resourceId
  }
}

// ExpressRoute Connection using AVM Connection module
module erConnection 'br/public:avm/res/network/connection:0.1.4' = if (!empty(expressRouteCircuitId) && !empty(expressRouteAuthKey)) {
  name: 'erConnectionDeployment'
  params: {
    name: '${vnetName}-er-connection'
    location: location
    connectionType: 'ExpressRoute'
    virtualNetworkGateway1: {
      id: erGateway.outputs.resourceId
    }
    peer: {
      id: expressRouteCircuitId
    }
    authorizationKey: expressRouteAuthKey
    routingWeight: 0
    tags: tags
  }
}

// Output section
output vnetId string = vnet.outputs.resourceId
output vmSubnetId string = vnet.outputs.subnetResourceIds[0]  // VMSubnet
output vmName string = jumpboxVm.outputs.name
output vmPrivateIP string = '' // Private IP not available from AVM VM module outputs
output vmManagedIdentityPrincipalId string = jumpboxVm.outputs.systemAssignedMIPrincipalId!
output bastionSubnetId string = vnet.outputs.subnetResourceIds[1]  // AzureBastionSubnet
output bastionId string = bastionHost.outputs.resourceId
output gatewaySubnetId string = vnet.outputs.subnetResourceIds[2]  // GatewaySubnet
output erGatewayId string = erGateway.outputs.resourceId
output erConnectionId string = !empty(expressRouteCircuitId) ? erConnection.outputs.resourceId : ''
output erConnectionName string = !empty(expressRouteCircuitId) ? erConnection.outputs.name : ''
