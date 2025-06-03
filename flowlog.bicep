param location string
param nsgName string
param logAnalyticsWorkspaceResourceId string
param flowLogStorageId string

resource networkWatcher 'Microsoft.Network/networkWatchers@2022-07-01' existing = {
  name: 'NetworkWatcher_australiaeast'
}

resource flowLog 'Microsoft.Network/networkWatchers/flowLogs@2022-07-01' = {
  name: '${nsgName}-flowlog'
  parent: networkWatcher
  location: location
  properties: {
    targetResourceId: resourceId('Microsoft.Network/networkSecurityGroups', nsgName)
    storageId: flowLogStorageId
    enabled: true
    format: {
      type: 'JSON'
      version: 2
    }
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceId: logAnalyticsWorkspaceResourceId
        workspaceRegion: location
        workspaceResourceId: logAnalyticsWorkspaceResourceId
        trafficAnalyticsInterval: 10
      }
    }
  }
}
