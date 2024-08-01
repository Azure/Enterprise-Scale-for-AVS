RESOURCE_GROUP="<Name of the Resource Group>"
LOCATION=""

PRIVATECLOUD_NAME="<Name of the Private Cloud"
PRIVATECLOUD_ADDRESSBLOCK="x.y.z.0/22"
PRIVATECLOUD_CLUSTERSIZE = 3
PRIVATECLOUD_SKU = "AV36P"

az vmware private-cloud create --name $PRIVATECLOUD_NAME \
                                --resource-group $RESOURCE_GROUP \
                                --location $LOCATION \
                                --cluster-size $PRIVATECLOUD_CLUSTERSIZE \
                                --network-block $PRIVATECLOUD_ADDRESSBLOCK \
                                --sku $PRIVATECLOUD_SKU