output "keys" {
  value = {
    for key, value in azapi_resource.hcx_keys : key => value.output.properties.activationKey
  }
}