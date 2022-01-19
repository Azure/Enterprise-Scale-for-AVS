param VNetName string
param JumpboxSubnet string
param BastionSubnet string

resource VNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: VNetName
}

resource Jumpbox 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'Jumpbox'
  parent: VNet
  properties: {
    addressPrefix: JumpboxSubnet
  }
}

resource Bastion 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'AzureBastionSubnet'
  parent: VNet
  dependsOn: [
    Jumpbox
  ]
  properties: {
    addressPrefix: BastionSubnet
  }
}

output JumpboxSubnetId string = Jumpbox.id
output BastionSubnetId string = Bastion.id
