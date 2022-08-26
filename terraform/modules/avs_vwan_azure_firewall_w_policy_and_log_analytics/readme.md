### General 

* Description: This module creates an Azure Firewall configured for deployment in a VWAN hub. It includes a dedicated log analytics workspace with a diagnostic configuration for sending the firewall logs to the dedicated workspace. Resource ID inputs are usually outputs from other modules, but can be input as the full resource ID string.

* The module leverages variables for naming and common values to be modified as part of the deployment.

* A tfvars template file has been included for use if implementing this module as a standalone deployment.

