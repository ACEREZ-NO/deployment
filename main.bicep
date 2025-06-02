
resource myStorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'mystorageaccount'
  location: 'australiaeast'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
