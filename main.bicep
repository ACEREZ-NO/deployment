var location = 'australiaeast'
var logAnalyticsWorkspaceResourceId = '/subscriptions/9c4fddcd-e800-4363-82dd-b0acd9b2a961/resourcegroups/rg-sec-prod-sentinel-aue-001/providers/microsoft.operationalinsights/workspaces/law-sec-prod-sentinel-aue-001'
var nsgs = [
  {
    name: 'alz-id-nsg-001'
    subscriptionId: '3d3ece30-66e5-42b6-a17e-4f20ec51344a'
    resourceGroup: 'alz-id-rg-001'
    networkWatcherResourceGroup: 'NetworkWatcherRG'
  }
  {
    name: 'alz-tst-nsg-001'
    subscriptionId: '0b6bba99-c2d7-4f8b-b9d2-a0b54c6d046f'
    resourceGroup: 'alz_tst_rg_001'
    networkWatcherResourceGroup: 'NetworkWatcherRG'
  }
  {
    name: 'alz-prd-nsg-001'
    subscriptionId: 'ed616b0a-1d77-4cc0-92d6-2d62ff6dd4d0'
    resourceGroup: 'alz-prd-rg-001'
    networkWatcherResourceGroup: 'NetworkWatcherRG'
  }
  {
    name: 'alz-sse-nsg-001'
    subscriptionId: '526fbe7f-5cad-4530-84c7-4896c68c022a'
    resourceGroup: 'alz-sse-rg-001'
    networkWatcherResourceGroup: 'NetworkWatcherRG'
  }
  {
    name: 'nsg-AzureBastionSubnet-australiaeast'
    subscriptionId: 'ce582519-c8e5-4709-a977-d72319f224a1'
    resourceGroup: 'rg-alz-connectivity'
    networkWatcherResourceGroup: 'NetworkWatcherRG'
  }
]

resource flowLogStorage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'nsgflow${uniqueString(resourceGroup().id)}'
  location: location
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

module flowLogBasic 'flowlog-basic.bicep' = [for nsg in nsgs: {
  name: 'flowLogBasic-${nsg.name}'
  scope: resourceGroup(nsg.subscriptionId, nsg.networkWatcherResourceGroup)
  params: {
    location: location
    nsgName: nsg.name
    nsgResourceGroup: nsg.resourceGroup
    nsgSubscriptionId: nsg.subscriptionId
    flowLogStorageId: flowLogStorage.id
  }
}]
