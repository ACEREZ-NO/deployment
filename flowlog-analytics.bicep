param location string
param nsgName string
param nsgResourceGroup string
param nsgSubscriptionId string
param flowLogStorageId string
param logAnalyticsWorkspaceId string
param logAnalyticsRegion string

resource networkWatcher 'Microsoft.Network/networkWatchers@2022-07-01' existing = {
  name: 'NetworkWatcher_australiaeast'
}

resource flowLog 'Microsoft.Network/networkWatchers/flowLogs@2022-07-01' = {
  name: '${nsgName}-flowlog'
  parent: networkWatcher
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
        enabled: true
        workspaceId: logAnalyticsWorkspaceId
        workspaceRegion: logAnalyticsRegion
        trafficAnalyticsInterval: 10
      }
    }
  }
}
