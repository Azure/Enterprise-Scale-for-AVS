#Prefix to define the name of resource groups, resources etc
#Max chaacter limit of the prefix is 7
prefix = "AVS"

#Region to deploy the AVS Private Cloud and associated components
region = ""

#AVS requires a /22 CIDR range, this must not overlap with other networks to be used with AVS
avs-networkblock = "x.y.z.0/22"
avs-sku          = "AV36"
avs-hostcount    = 3
hcx_key_names    = ["hcxsite1", "hcxsite2"]

#Input the Jumpbox local username, password and SKU of your choice

key_vault_name = ""
adminusername = ""
jumpboxsku    = "Standard_D2as_v4"

#Virtual network address space and required subnets, can be any CIDR range
vnetaddressspace   = "a.b.c.0/24"
gatewaysubnet      = "a.b.c.0/27"
azurebastionsubnet = "a.b.c.64/26"
jumpboxsubnet      = "a.b.c.128/25"
nsg_name           = ""

#Enable or Disable telemetry
telemetry_enabled = true
