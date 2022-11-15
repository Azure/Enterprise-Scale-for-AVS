param Location string

var storageaccountname = 'avs${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageaccountname
  location: Location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

output StorageAccountName string = storageAccount.name
output StorageAccountid string = storageAccount.id
