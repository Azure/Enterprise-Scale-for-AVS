### General 

* Description: This module creates a new Azure Bastion instance in an existing VNet.  The existing VNet requires that an appropriately sized AzureBastionSubnet exists and is used for the deployment. Resource ID inputs are usually outputs from other modules, but can be input as the full resource ID string.

* The module leverages variables for naming and common values to be modified as part of the deployment.

* A tfvars template file has been included for use if implementing this module as a standalone deployment.

