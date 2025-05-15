
resource nic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: 'alz-tst-vm-003416_z1'
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
