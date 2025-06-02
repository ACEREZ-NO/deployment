resource myStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'mystorage${uniqueString(resourceGroup().id)}'
  location: 'australiaeast'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Disabled'
  }
}

resource myStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'anotherstorage${uniqueString(resourceGroup().id)}'
  location: 'australiaeast'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Disabled'
  }
}
