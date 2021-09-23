RESOURCE_GROUP="ExampleResourceGroup"

PRIVATECLOUD_NAME="ExamplePrivateCloud"
PRIVATECLOUD_ADDRESSBLOCK="10.0.0.0/22"

GLOBALREACH_NAME="ExampleGlobalReach"
EXR_RESOURCEID="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/tntXX-cust-p01-centralus/providers/Microsoft.Network/expressRouteCircuits/tntXX-cust-p01-centralus-er"
EXR_AUTHKEY="00000000-0000-0000-0000-000000000000"

az vmware global-reach-connection create --name $GLOBALREACH_NAME \
                                            --private-cloud $PRIVATECLOUD_NAME \
                                            --resource-group $RESOURCE_GROUP \
                                            --peer-express-route-circuit $EXR_RESOURCEID \
                                            --authorization-key $EXR_AUTHKEY