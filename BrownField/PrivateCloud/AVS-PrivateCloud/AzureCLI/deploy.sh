RESOURCE_GROUP="ExampleResourceGroup"
LOCATION="Central US"

PRIVATECLOUD_NAME="ExamplePrivateCloud"
PRIVATECLOUD_ADDRESSBLOCK="10.0.0.0/22"
PRIVATECLOUD_CLUSTERSIZE = 3
PRIVATECLOUD_SKU = "AV36P"

az vmware private-cloud create --name $PRIVATECLOUD_NAME \
                                --resource-group $RESOURCE_GROUP \
                                --location $LOCATION \
                                --cluster-size $PRIVATECLOUD_CLUSTERSIZE \
                                --network-block $PRIVATECLOUD_ADDRESSBLOCK \
                                --sku $PRIVATECLOUD_SKU