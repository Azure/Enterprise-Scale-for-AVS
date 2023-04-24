### General 

* Description: This module creates a new Route Server instance for inclusion with AVS VPN scenarios. It enables the branch-to-branch feature on the Route Server instance. The deployment requires an existing VNet with an appropriately sized AzureRouteServer. Resource ID inputs are usually outputs from other modules, but can be input as the full resource ID string.

* The module leverages variables for naming and common values to be modified as part of the deployment.

* A tfvars template file has been included for use if implementing this module as a standalone deployment.

