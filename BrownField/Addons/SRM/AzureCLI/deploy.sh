RESOURCE_GROUP=""
PRIVATECLOUD_NAME=""

SRM_KEY=""
VR_INSTANCES=1

# Deploy SRM
az vmware addon srm create --resource-group $RESOURCE_GROUP --private-cloud $PRIVATECLOUD_NAME --license-key $SRM_KEY

# Deploy vSphere Replication
az vmware addon vr create --resource-group $RESOURCE_GROUP --private-cloud $PRIVATECLOUD_NAME --vrs-count $VR_INSTANCES