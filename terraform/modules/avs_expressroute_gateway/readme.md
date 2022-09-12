### General 

* Description: This module creates a new ExpressRoute gateway in an existing VNet and then creates the AVS expressRoute connection using a previously generated ExpressRoute authorization key.  The existing VNet requires that an appropriately sized GatewaySubnet exists and is used for the deployment. Resource ID inputs are usually outputs from other modules, but can be input as the full resource ID string.

* The module leverages variables for naming and common values to be modified as part of the deployment.

* A tfvars template file has been included for use if implementing this module as a standalone deployment.

