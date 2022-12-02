#get the existing private cloud details
data "azurerm_vmware_private_cloud" "hcx_private_cloud" {
  name                = var.private_cloud_name
  resource_group_name = var.private_cloud_resource_group
}

resource "azapi_resource" "hcx_addon_1" {
  type = "Microsoft.AVS/privateClouds/addons@2021-12-01"
  #Resource Name must match the addonType
  name = "HCX"
  parent_id = data.azurerm_vmware_private_cloud.hcx_private_cloud.id
  body = jsonencode({
    properties = {
      addonType = "HCX"
      offer     = "VMware MaaS Cloud Provider"    
    }
  })
}