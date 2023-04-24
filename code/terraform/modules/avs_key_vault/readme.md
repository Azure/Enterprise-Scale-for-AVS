### General 

* Description: This module creates a new Azure Key Vault with an initial access policy for the deployment user. There is also a sample within the code that can be uncommented to leverage a service principal instead of the deployment user.  The deployment uses data resources to get the deployment user and tenant details.

* The module leverages variables for naming and common values to be modified as part of the deployment.

* A tfvars template file has been included for use if implementing this module as a standalone deployment.

