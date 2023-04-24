#deploy the hcx addon
resource "azapi_resource" "hcx_addon" {
  type = "Microsoft.AVS/privateClouds/addons@2021-12-01"
  #Resource Name must match the addonType
  name      = "HCX"
  parent_id = azurerm_vmware_private_cloud.privatecloud.id
  body = jsonencode({
    properties = {
      addonType = "HCX"
      offer     = "VMware MaaS Cloud Provider"
    }
  })

  #adding lifecycle block to handle replacement issue with parent_id
  lifecycle {
    ignore_changes = [
      parent_id
    ]
  }

  depends_on = [
    azurerm_vmware_private_cloud.privatecloud
  ]
}

#adding sleep wait to handle lag in hcx registration for keys
resource "time_sleep" "wait_120_seconds" {
  depends_on = [azapi_resource.hcx_addon]

  create_duration = "120s"
}

#create the hcx key(s)
resource "azapi_resource" "hcx_keys" {
  for_each = toset(var.hcx_key_names)

  type                   = "Microsoft.AVS/privateClouds/hcxEnterpriseSites@2022-05-01"
  name                   = each.key
  parent_id              = azurerm_vmware_private_cloud.privatecloud.id
  response_export_values = ["*"]

  depends_on = [
    time_sleep.wait_120_seconds,
    azapi_resource.hcx_addon
  ]

  lifecycle {
    ignore_changes = [
      parent_id
    ]
  }
}

output "hcx_keys" {
  value = {
    for key, value in azapi_resource.hcx_keys : key => jsondecode(value.output).properties.activationKey
  }
}





