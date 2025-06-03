param location string
param nsgName string
param nsgResourceGroup string
param nsgSubscriptionId string
param flowLogStorageId string

resource flowLog 'Microsoft.Network/networkWatchers/flowLogs@2022-07-01' = {
  name: '${nsgName}-flowlog'
  parent: resourceId('Microsoft.Network/networkWatchers', 'NetworkWatcher_australiaeast')
  location: location
  properties: {
    targetResourceId: resourceId(nsgSubscriptionId, nsgResourceGroup, 'Microsoft.Network/networkSecurityGroups', nsgName)
    storageId: flowLogStorageId
    enabled: true
    format: {
      type: 'JSON'
      version: 2
    }
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: false
      }
    }
  }
}
