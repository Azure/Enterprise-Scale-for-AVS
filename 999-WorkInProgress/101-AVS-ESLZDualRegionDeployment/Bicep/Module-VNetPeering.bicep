targetScope = 'subscription'

param PrimaryVNetName string
param PrimaryNetworkResourceGroup string
param SecondaryVNetName string
param SecondaryNetworkResourceGroup string

resource PrimaryVNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: PrimaryVNetName
  scope: resourceGroup(PrimaryNetworkResourceGroup)
}

resource SecondaryVNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: SecondaryVNetName
  scope: resourceGroup(SecondaryNetworkResourceGroup)
}

module PrimaryToSecondaryPeering 'Module-VNetPeering-Peer.bicep' = {
  name: 'PrimaryToSecondaryPeering'
  scope: resourceGroup(PrimaryNetworkResourceGroup)
  params: {
    RemoteVNetId: SecondaryVNet.id
    RemoteVNetName: SecondaryVNetName
    VNetName: PrimaryVNetName
  }
}

module SecondaryToPrimaryPeering 'Module-VNetPeering-Peer.bicep' = {
  name: 'SecondaryToPrimaryPeering'
  scope: resourceGroup(SecondaryNetworkResourceGroup)
  params: {
    RemoteVNetId: PrimaryVNet.id
    RemoteVNetName: PrimaryVNetName
    VNetName: SecondaryVNetName
  }
}
