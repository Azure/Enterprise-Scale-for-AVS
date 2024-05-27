#Prefix to define the name of resource groups, resources etc
#Max chaacter limit of the prefix is 7
prefix = "AVS"

#Region to deploy the AVS Private Cloud and associated components
region = "northeurope"

#AVS requires a /22 CIDR range, this must not overlap with other networks to be used with AVS
avs-networkblock = ""
avs-sku          = "AV36P"
avs-hostcount    = 3
hcx_key_names    = ["hcxsite1", "hcxsite2"]

#Input the Jumpbox local username, password and SKU of your choice
adminusername = ""
adminpassword = ""
jumpboxsku    = "Standard_D2as_v4"

#Virtual network address space and required subnets, can be any CIDR range
vnetaddressspace   = ""
gatewaysubnet      = ""
azurebastionsubnet = ""
jumpboxsubnet      = ""

#Enable or Disable telemetry
telemetry_enabled = true
