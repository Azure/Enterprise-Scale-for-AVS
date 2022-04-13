param Prefix string
param SubnetId string
param Location string

resource BastionPIP 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
  name: '${Prefix}-bastion-pip'
  location: Location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2020-05-01' = {
  name: '${Prefix}-bastion'
  location: Location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: SubnetId
          }
          publicIPAddress: {
            id: BastionPIP.id
          }
        }
      }
    ]
  }
}
