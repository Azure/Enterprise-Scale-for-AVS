param PrivateCloudName string
param PrivateCloudResourceGroup string = resourceGroup().name
param PrivateCloudSubscriptionId string = subscription().id

param Location string = resourceGroup().location
param VWanName string
param VWanAddressSpace string

resource VWan 'Microsoft.Network/virtualWans@2021-02-01' = {
  name: VWanName
  location: Location
  properties: {
    type: 'Standard'
  }
}

resource VWanHub 'Microsoft.Network/virtualHubs@2021-02-01' = {
  name: '${VWan.name}-${Location}'
  location: Location
  properties: {
    addressPrefix: VWanAddressSpace
    sku: 'Standard'
    virtualWan: {
      id: VWan.id
    }
  }
}

resource VWanHubExR 'Microsoft.Network/expressRouteGateways@2021-02-01' = {
  name: '${VWanHub.name}-er-gw'
  location: Location
  properties: {
    virtualHub: {
      id: VWanHub.id
    }
    autoScaleConfiguration: {
      bounds: {
        min: 1
      }
    }
  }
}

module AVSAuthorization 'Module-AVSAuthorization.bicep' = {
  name: 'AVSAuthorization'
  params: {
    ConnectionName: VWanHub.name
    PrivateCloudName: PrivateCloudName
  }
  scope: resourceGroup(PrivateCloudSubscriptionId, PrivateCloudResourceGroup)
}
