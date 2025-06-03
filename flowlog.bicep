param location string
param nsgName string
param logAnalyticsWorkspaceResourceId string
param flowLogStorageId string

var logAnalyticsWorkspaceGUID = '7b58efd2-834a-4a8c-900e-b5c15082c3fa'

resource networkWatcher 'Microsoft.Network/networkWatchers@2022-07-01' existing = {
  name: 'NetworkWatcher_australiaeast'
}

resource flowLog 'Microsoft.Network/networkWatchers/flowLogs@2022-07-01' = {
  name: '${nsgName}-flowlog'
  parent: networkWatcher
  location: location
  properties: {
    targetResourceId: resourceId('alz_tst_rg_001', 'Microsoft.Network/networkSecurityGroups', nsgName)
    storageId: flowLogStorageId
    enabled: true
    format: {
      type: 'JSON'
      version: 2
    }
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceId: logAnalyticsWorkspaceGUID
        workspaceRegion: location
        workspaceResourceId: logAnalyticsWorkspaceResourceId
        trafficAnalyticsInterval: 10
      }
    }
  }
}
