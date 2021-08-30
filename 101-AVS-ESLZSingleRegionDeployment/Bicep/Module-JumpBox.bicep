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
param BastionSubnet string

module Subnet 'Module-JumpBox-Subnet.bicep' = {
  name: 'Jumpbox-Subnet'
  scope: resourceGroup(VNetResourceGroup)
  params:{
    VNetName: VNetName
    BastionSubnet: BastionSubnet
    JumpboxSubnet: JumpboxSubnet
  }
}

resource JumpboxResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  name: '${Prefix}-Jumpbox'
  location: Location
}

module Bastion 'Module-JumpBox-Bastion.bicep' = {
  name: 'ESLZDeploy-Jumpbox-Bastion'
  scope: JumpboxResourceGroup
  params:{
    Prefix: Prefix
    SubnetId: Subnet.outputs.BastionSubnetId
    Location: Location
  }
}

module VM 'Module-JumpBox-VM.bicep' = {
  name: 'ESLZDeploy-Jumpbox-VM'
  scope: JumpboxResourceGroup
  params: {
    Prefix: Prefix
    SubnetId: Subnet.outputs.JumpBoxSubnetId
    Location: Location
    Username: Username
    Password: Password
  }
}

output JumpboxResourceId string = VM.outputs.JumpboxResourceId
