output "keys" {
  value = {
    for key, value in azapi_resource.hcx_keys : key => jsondecode(value.output).properties.activationKey
  }
}