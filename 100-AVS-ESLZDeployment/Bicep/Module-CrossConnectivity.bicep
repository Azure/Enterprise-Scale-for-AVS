targetScope = 'subscription'

param PrimaryPrefix string
param PrimaryPrivateCloudName string
param PrimaryPrivateCloudResourceGroup string
param PrimaryVNetName string
param PrimaryGatewayName string
param PrimaryNetworkResourceGroup string

param SecondaryPrefix string
param SecondaryPrivateCloudName string
param SecondaryPrivateCloudResourceGroup string
param SecondaryVNetName string
param SecondaryGatewayName string
param SecondaryNetworkResourceGroup string

module CrossAVSGlobalReach 'Module-CrossAVSGlobalReach.bicep' = {
  name: 'GlobalReach'
  params: {
    PrimaryPrivateCloudName: PrimaryPrivateCloudName
    PrimaryPrivateCloudResourceGroup: PrimaryPrivateCloudResourceGroup
    SecondaryPrivateCloudName: SecondaryPrivateCloudName
    SecondaryPrivateCloudResourceGroup: SecondaryPrivateCloudResourceGroup
  }
}

module PrimaryAVSToSecondaryVNet 'Module-AVSExRVNetConnection.bicep' = {
  name: 'PrimaryAVSToSecondaryVNet'
  params: {
    AVSPrefix: PrimaryPrefix
    PrivateCloudName: PrimaryPrivateCloudName
    PrivateCloudResourceGroup: PrimaryPrivateCloudResourceGroup
    VNetPrefix: SecondaryPrefix
    GatewayName: SecondaryGatewayName
    NetworkResourceGroup: SecondaryNetworkResourceGroup
  }
}

module SecondaryAVSToPrimaryVNet 'Module-AVSExRVNetConnection.bicep' = {
  name: 'SecondaryAVSToPrimaryVNet'
  params: {
    AVSPrefix: SecondaryPrefix
    PrivateCloudName: SecondaryPrivateCloudName
    PrivateCloudResourceGroup: SecondaryPrivateCloudResourceGroup
    VNetPrefix: PrimaryPrefix
    GatewayName: PrimaryGatewayName
    NetworkResourceGroup: PrimaryNetworkResourceGroup
  }
}

module VNetPeering 'Module-VNetPeering.bicep' = {
  name: 'VNetPeering'
  params: {
    PrimaryVNetName: PrimaryVNetName
    PrimaryNetworkResourceGroup: PrimaryNetworkResourceGroup
    SecondaryVNetName: SecondaryVNetName
    SecondaryNetworkResourceGroup: SecondaryNetworkResourceGroup
  }
}
