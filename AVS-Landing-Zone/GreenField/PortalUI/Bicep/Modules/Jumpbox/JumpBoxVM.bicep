param Prefix string
param SubnetId string
param Location string
param Username string
@secure()
param Password string
param VMSize string
param operatingSystemSKU string = ''
param BootstrapVM bool = false
param BootstrapPath string = ''
param BootstrapCommand string = ''

var Name = '${Prefix}-jumpbox'
var Hostname = 'avsjumpbox'

var osImageReference = {
  win2022: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2022-Datacenter'
    version: 'latest'
  }
  win2019: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2019-Datacenter'
    version: 'latest'
  }
  win11: {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-11'
    sku: 'win11-21h2-pron'
    version: 'latest'
  }
  win11ms: {
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-11'
    sku: 'win11-21h2-avd'
    version: 'latest'
  }
  ubuntu2004gen2: {
    publisher: 'canonical'
    offer: '0001-com-ubuntu-server-focal'
    sku: '20_04-lts-gen2'
    version: 'latest'
  }
}

resource Nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: Name
  location: Location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: SubnetId
          }
        }
      }
    ]
  }
}

resource VM 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: Name
  location: Location
  properties: {
    hardwareProfile: {
      vmSize: VMSize
    }
    osProfile: {
      computerName: Hostname
      adminUsername: Username
      adminPassword: Password
    }
    storageProfile: {
      imageReference: {
        publisher: osImageReference[operatingSystemSKU].publisher
        offer: osImageReference[operatingSystemSKU].offer
        sku: osImageReference[operatingSystemSKU].sku
        version: osImageReference[operatingSystemSKU].version
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: Nic.id
        }
      ]
    }
  }
}

resource Bootstrap 'Microsoft.Compute/virtualMachines/extensions@2015-06-15' = if(BootstrapVM) {
  name: '${VM.name}/CustomScriptExtension'
  location: Location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        BootstrapPath
      ]
      commandToExecute: BootstrapCommand
    }
  }
}

output JumpboxResourceId string = VM.id
