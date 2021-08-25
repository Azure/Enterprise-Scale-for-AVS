RESOURCE_GROUP="ExampleResourceGroup"
LOCATION="Central US"

PRIVATECLOUD_NAME="ExamplePrivateCloud"
PRIVATECLOUD_ADDRESSBLOCK="10.0.0.0/22"

az vmware private-cloud create --name $PRIVATECLOUD_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --cluster-size 3 --network-block $PRIVATECLOUD_ADDRESSBLOCK --sku AV36