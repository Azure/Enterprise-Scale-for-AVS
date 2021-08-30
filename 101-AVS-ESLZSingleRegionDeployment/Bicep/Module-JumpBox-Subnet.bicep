param VNetName string
param JumpboxSubnet string
param BastionSubnet string

resource VNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: VNetName
}

resource JumpBox 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'JumpBox'
  parent: VNet
  properties: {
    addressPrefix: JumpboxSubnet
  }
}

resource Bastion 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'AzureBastionSubnet'
  parent: VNet
  dependsOn: [
    JumpBox
  ]
  properties: {
    addressPrefix: BastionSubnet
  }
}

output JumpBoxSubnetId string = JumpBox.id
output BastionSubnetId string = Bastion.id
