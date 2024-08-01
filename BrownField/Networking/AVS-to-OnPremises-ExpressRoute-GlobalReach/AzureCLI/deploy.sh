RESOURCE_GROUP="<Resource Group where the new globalReach resource will be created>"

PRIVATECLOUD_NAME="<The name of the existing Private Cloud that should be used for the connection>"
PRIVATECLOUD_ADDRESSBLOCK="x.y.z.0/22"

GLOBALREACH_NAME="<ExampleGlobalReach>"
EXR_RESOURCEID="<The Express Route ID to create the connection to>"
EXR_AUTHKEY="<The Express Route Authorization Key to be redeemed by the connection. In the format 00000000-0000-0000-0000-000000000000>"

az vmware global-reach-connection create --name $GLOBALREACH_NAME \
                                            --private-cloud $PRIVATECLOUD_NAME \
                                            --resource-group $RESOURCE_GROUP \
                                            --peer-express-route-circuit $EXR_RESOURCEID \
                                            --authorization-key $EXR_AUTHKEY