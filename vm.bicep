var location = 'australiaeast'
var environment = 'Development' //// update if required ////
var logAnalyticsWorkspaceResourceId = '/subscriptions/9c4fddcd-e800-4363-82dd-b0acd9b2a961/resourcegroups/rg-sec-prod-sentinel-aue-001/providers/microsoft.operationalinsights/workspaces/law-sec-prod-sentinel-aue-001'

resource nic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: 'alz-tst-vm-007-nic' //// update /////
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '/subscriptions/0b6bba99-c2d7-4f8b-b9d2-a0b54c6d046f/resourceGroups/alz_tst_rg_001/providers/Microsoft.Network/virtualNetworks/alz-tst-vnet-001/subnets/TEST_0' //// update if required ////
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
param virtualMachineName string = 'alz-tst-vm-007' //// update ////
param networkInterfaceId string = '/subscriptions/0b6bba99-c2d7-4f8b-b9d2-a0b54c6d046f/resourceGroups/alz_tst_rg_001/providers/Microsoft.Network/networkInterfaces/alz-tst-vm-007-nic' //// update ////

resource virtualMachineName_resource 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: virtualMachineName
  location: location
  tags: {
    Environment: environment
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
      computerName: virtualMachineName
      adminUsername: adminUsername
	  adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'Manual'
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
          id: networkInterfaceId
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
  name: virtualMachineName
}

// Data Collection Rule
resource dcr 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  name: 'alz-tst-dcr' //// update if required ////
  location: location
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
  name: '${virtualMachineName}-dcra'
  scope: vm
  properties: {
    dataCollectionRuleId: dcr.id
  }
}

// Install Azure Monitor Agent extension
resource azureMonitorAgent 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  name: 'AzureMonitorWindowsAgent'
  parent: virtualMachineName_resource
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {}
  }
}
