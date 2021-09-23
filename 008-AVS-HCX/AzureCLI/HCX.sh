RESOURCE_GROUP="ExampleResourceGroup"
PRIVATECLOUD_NAME="ExamplePrivateCloud"

# Deploy HCX Advanced
az vmware addon hcx create --resource-group $RESOURCE_GROUP --private-cloud $PRIVATECLOUD_NAME --offer "VMware MaaS Cloud Provider"