#if vwan exists output the vwan id from the data provider, otherwise output from the new vwan
output "vwan_id" {
  value = (var.vwan_already_exists ? data.azurerm_virtual_wan.vwan.id : azurerm_virtual_wan.vwan[0].id)
}