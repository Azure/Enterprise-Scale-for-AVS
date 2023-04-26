createResourceGroup    = false # Create (true) or reuse (false) resourceGroup
resourceGroupName      = "<Resource Group Name>"
region                 = "<dashboard deployment region>"
dashboardName          = "AVS Dashboard"
privateCloudResourceId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/<Resource Group Name>/providers/Microsoft.AVS/privateClouds/<Private Cloud Name>"
#if the primary AVS connection is to an ExpressRoute Gateway in a hub spoke architecture then provide the Resource ID of the connection resource, otherwise leave this as an empty string
exRConnectionResourceId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/<Resource Group Name>/providers/Microsoft.Network/connections/<Connection Name>"
#If the primary AVS connection is to an ExpressRoute Gateway in a VWAN hub then provide the resource ID of the ExpressRoute Gateway
#vwanExrGatewayResourceId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/<Resource Group Name>/providers/Microsoft.Network/expressRouteGateways/<ExpressRoute Gateway Name>"