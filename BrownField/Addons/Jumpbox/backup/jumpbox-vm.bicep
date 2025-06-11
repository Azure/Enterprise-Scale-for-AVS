// Jumpbox VM without public IP - only accessible via Bastion
@description('Name of the virtual machine')
param vmName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Size of the virtual machine')
param vmSize string = 'Standard_B4ms'

@description('Admin username for the virtual machine')
param adminUsername string = '<CHANGE-ME>'

@description('Admin password for the virtual machine')
@secure()
param adminPassword string

@description('The Windows version for the VM')
@allowed([
  '2019-Datacenter'
  '2019-Datacenter-Core'
  '2019-datacenter-gensecond'
  '2022-datacenter'
  '2022-datacenter-azure-edition'
  '2022-datacenter-azure-edition-core'
  '2022-datacenter-core'
  '2022-datacenter-g2'
])
param OSVersion string = '2019-Datacenter'

@description('Virtual network name')
param virtualNetworkName string = ''

@description('Subnet name')
param subnetName string = ''

@description('Network interface ID - if provided, will use this NIC instead of creating one')
param nicId string = ''

@description('Network security group name')
param nsgName string = '${vmName}-nsg'

@description('Tags for the resources')
param tags object = {}

@description('Enable boot diagnostics')
param enableBootDiagnostics bool = true

@description('Storage account type for OS and data disks')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Premium_LRS'
  'StandardSSD_LRS'
  'Premium_ZRS'
  'StandardSSD_ZRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Size of the data disk in GB')
param dataDiskSizeGB int = 100

var networkInterfaceName = '${vmName}-nic'
var useProvidedNic = !empty(nicId)

// Network security group with RDP allowed only from within the VNet
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = if (!useProvidedNic) {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowRDPFromVNet'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
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

// Reference to existing VNet if we're not using a provided NIC
resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = if (!useProvidedNic) {
  name: virtualNetworkName
}

// Reference to existing Subnet if we're not using a provided NIC
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = if (!useProvidedNic) {
  parent: vnet
  name: subnetName
}

// Network interface without public IP
resource nic 'Microsoft.Network/networkInterfaces@2022-07-01' = if (!useProvidedNic) {
  name: networkInterfaceName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

// VM resource
resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: vmName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: storageAccountType
        }
      }
      dataDisks: [
        {
          diskSizeGB: dataDiskSizeGB
          lun: 0
          createOption: 'Empty'
          managedDisk: {
            storageAccountType: storageAccountType
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: useProvidedNic ? nicId : nic.id
        }
      ]
    }
    diagnosticsProfile: enableBootDiagnostics ? {
      bootDiagnostics: {
        enabled: true
      }
    } : null
  }
}

@description('The name of the VM')
output vmName string = vm.name

@description('The private IP address of the VM')
output privateIPAddress string = useProvidedNic ? '' : nic.properties.ipConfigurations[0].properties.privateIPAddress

@description('The VM resource ID')
output vmId string = vm.id

@description('The principal ID of the VM system-assigned managed identity')
output systemAssignedIdentityPrincipalId string = vm.identity.principalId
