#Prefix to define the name of resource groups, resources etc
#Max chaacter limit of the prefix is 7
prefix = "AVS"

#Region to deploy the AVS Private Cloud and associated components
region = "northeurope"

#AVS requires a /22 CIDR range, this must not overlap with other networks to be used with AVS
avs-networkblock = "10.1.0.0/22"
avs-sku = "AV36"
avs-hostcount = 3

#Input the Jumpbox local username, password and SKU of your choice
adminusername = "replace me"
adminpassword = "replace me"
jumpboxsku = "Standard_D2as_v4"

#Virtual network address space and required subnets, can be any CIDR range
vnetaddressspace = "192.168.1.0/24"
gatewaysubnet = "192.168.1.0/27"
azurebastionsubnet = "192.168.1.32/27"
jumpboxsubnet = "192.168.1.128/25"
