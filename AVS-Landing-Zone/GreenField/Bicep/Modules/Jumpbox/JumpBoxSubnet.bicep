param VNetName string
param Location string
param JumpboxSubnet string
param BastionSubnet string

resource VNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: VNetName
}

resource NSGJumpBox 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'JumpBoxNSG'
  location: Location
  properties: {
    securityRules: [
      {
        name: 'AllowAllInbond'
        properties: {
          protocol: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          direction: 'Inbound'
          priority: 4000
          sourcePortRange: '*'
          destinationPortRange: '*'
        }
      }
      {
        name: 'AllowAllOutbound'
        properties: {
          protocol: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          direction: 'Outbound'
          priority: 4000
          sourcePortRange: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

resource JumpBox 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'JumpBox'
  parent: VNet
  properties: {
    addressPrefix: JumpboxSubnet
    networkSecurityGroup: {
      id: NSGJumpBox.id
    }
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
