targetScope = 'subscription'

param Prefix string
param Location string
@secure()
param Username string
@secure()
param Password string
param VNetResourceGroup string
param VNetName string
param JumpboxSubnet string
param JumpboxSku string
param operatingSystemSKU string = ''
param HighPerformance bool
param BastionSubnet string
param BootstrapJumpboxVM bool = false
param BootstrapPath string
param BootstrapCommand string
param tags object

module Subnet 'JumpBox/JumpBoxSubnet.bicep' = {
  name: 'Jumpbox-Subnet'
  scope: resourceGroup(VNetResourceGroup)
  params:{
    VNetName: VNetName
    BastionSubnet: BastionSubnet
    JumpboxSubnet: JumpboxSubnet
  }
}

module Bastion 'JumpBox/Bastion.bicep' = {
  name: '${deployment().name}-Bastion'
  scope: resourceGroup(VNetResourceGroup)
  params:{
    Prefix: Prefix
    SubnetId: Subnet.outputs.BastionSubnetId
    Location: Location
    tags: tags
  }
}

module VM 'JumpBox/JumpBoxVM.bicep' = {
  name: '${deployment().name}-VM'
  scope: resourceGroup(VNetResourceGroup)
  params: {
    Prefix: Prefix
    SubnetId: Subnet.outputs.JumpBoxSubnetId
    Location: Location
    Username: Username
    Password: Password
    VMSize: JumpboxSku
    operatingSystemSKU: operatingSystemSKU
    HighPerformance: HighPerformance
    BootstrapVM: BootstrapJumpboxVM
    BootstrapPath: BootstrapPath
    BootstrapCommand: BootstrapCommand
    tags: tags
  }
}

output JumpboxResourceId string = VM.outputs.JumpboxResourceId
