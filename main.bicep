var location = 'australiaeast'
var logAnalyticsWorkspaceResourceId = '/subscriptions/9c4fddcd-e800-4363-82dd-b0acd9b2a961/resourcegroups/rg-sec-prod-sentinel-aue-001/providers/microsoft.operationalinsights/workspaces/law-sec-prod-sentinel-aue-001'
var logAnalyticsWorkspaceId = '/subscriptions/9c4fddcd-e800-4363-82dd-b0acd9b2a961/resourcegroups/rg-sec-prod-sentinel-aue-001/providers/microsoft.operationalinsights/workspaces/law-sec-prod-sentinel-aue-001'
var logAnalyticsRegion = 'australiaeast'
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
//  {
//    name: 'nsg-AzureBastionSubnet-australiaeast'
//    subscriptionId: 'ce582519-c8e5-4709-a977-d72319f224a1'
//    resourceGroup: 'rg-alz-connectivity'
//    networkWatcherResourceGroup: 'NetworkWatcherRG'
//  }
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

module flowLogAnalytics 'flowlog-analytics.bicep' = [for (nsg, i) in nsgs: {
  name: 'flowLogAnalytics-${nsg.name}'
  scope: resourceGroup(nsg.subscriptionId, nsg.networkWatcherResourceGroup)
  dependsOn: [flowLogBasic[i]]
  params: {
    location: location
    nsgName: nsg.name
    nsgResourceGroup: nsg.resourceGroup
    nsgSubscriptionId: nsg.subscriptionId
    flowLogStorageId: flowLogStorage.id
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    logAnalyticsRegion: logAnalyticsRegion
  }
}]

////////////////
// VM Section //
////////////////

resource nic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: 'alz-tst-vm-006-nic' //// update name /////
  location: 'australiaeast'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '/subscriptions/0b6bba99-c2d7-4f8b-b9d2-a0b54c6d046f/resourceGroups/alz_tst_rg_001/providers/Microsoft.Network/virtualNetworks/alz-tst-vnet-001/subnets/TEST_0'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

param adminUsername string
@secure()
param adminPassword string
param virtualMachines_alz_tst_vm_006_name string = 'alz-tst-vm-006'
param networkInterfaces_alz_tst_vm_006_nic_externalid string = '/subscriptions/0b6bba99-c2d7-4f8b-b9d2-a0b54c6d046f/resourceGroups/alz_tst_rg_001/providers/Microsoft.Network/networkInterfaces/alz-tst-vm-006-nic'

resource virtualMachines_alz_tst_vm_006_name_resource 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: virtualMachines_alz_tst_vm_006_name
  location: 'australiaeast'
  tags: {
    Environment: 'Development'
  }
  zones: [
    '1'
  ]
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/b771f123-b01d-44ea-a361-7bccdbe4ca46/resourcegroups/rg-alz-logging/providers/Microsoft.ManagedIdentity/userAssignedIdentities/alz-umi-identity': {}
    }
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition-smalldisk'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
      }
      dataDisks: []
      diskControllerType: 'SCSI'
    }
    osProfile: {
      computerName: virtualMachines_alz_tst_vm_006_name
      adminUsername: adminUsername
	  adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'AutomaticByPlatform'
          enableHotpatching: false
        }
      }
      secrets: []
      allowExtensionOperations: true
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
	networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_alz_tst_vm_006_nic_externalid
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
  }
}

// Reference to the VM resource
resource vm 'Microsoft.Compute/virtualMachines@2024-11-01' existing = {
  name: virtualMachines_alz_tst_vm_006_name
}

// Data Collection Rule
resource dcr 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  name: 'alz-tst-dcr'
  location: 'australiaeast'
  properties: {
    dataSources: {
      performanceCounters: [
        {
          name: 'cpuPerf'
          streams: ['Microsoft-Perf']
          samplingFrequencyInSeconds: 60
          counterSpecifiers: ['\\Processor(_Total)\\% Processor Time']
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name: 'logAnalyticsDest'
          workspaceResourceId: logAnalyticsWorkspaceResourceId
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Microsoft-Perf']
        destinations: ['logAnalyticsDest']
      }
    ]
  }
}

// Associate DCR with VM
resource dcra 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = {
  name: '${virtualMachines_alz_tst_vm_006_name}-dcra'
  scope: vm
  properties: {
    dataCollectionRuleId: dcr.id
  }
}

// Install Azure Monitor Agent extension
resource azureMonitorAgent 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  name: 'AzureMonitorWindowsAgent'
  parent: virtualMachines_alz_tst_vm_006_name_resource
  location: 'australiaeast'
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {}
  }

}

////////////////////
// END VM Section //
////////////////////

