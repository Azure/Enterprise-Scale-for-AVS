### General 

* Description: This module creates a vwan hub with expressRoute and VPN gateways and a flag to configure the firewall for a adding Azure firewall if desired. If the firewall flag is enabled, then a separate firewall resource will need to be deployed with it's resource ID passed to this module. Resource ID inputs are usually outputs from other modules, but can be input as the full resource ID string.

* The module leverages variables for naming and common values to be modified as part of the deployment.

* A tfvars template file has been included for use if implementing this module as a standalone deployment.

