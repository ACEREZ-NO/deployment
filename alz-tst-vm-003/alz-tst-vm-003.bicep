param adminUsername string = 'alz-admin'
param virtualMachines_alz_tst_vm_003_name string = 'alz-tst-vm-003'
param networkInterfaces_alz_tst_vm_003416_z1_externalid string = '/subscriptions/0b6bba99-c2d7-4f8b-b9d2-a0b54c6d046f/resourceGroups/alz_tst_rg_001/providers/Microsoft.Network/networkInterfaces/alz-tst-vm-003416_z1'
param adminPassword string = 'Password123'

resource virtualMachines_alz_tst_vm_003_name_resource 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: virtualMachines_alz_tst_vm_003_name
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
      computerName: virtualMachines_alz_tst_vm_003_name
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
          id: networkInterfaces_alz_tst_vm_003416_z1_externalid
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
  }
}
