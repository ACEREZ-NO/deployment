resource myStorageAccount1 'Microsoft.Storage/storageAccounts@2022-09-01' = {
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

resource myStorageAccount2 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'my2storage${uniqueString(resourceGroup().id)}'
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

resource nic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: 'alz-tst-vm-006-nic'
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
