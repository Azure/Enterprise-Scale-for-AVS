### General 

* Description: This module creates a new AVS stretch cluster and initial expressroute authorization keys for each zone. It exports the expressroute artifacts (authorization key, expressroute ID, and private peering ID) as a list with the primary site having the 0 index and the secondary site the 1 index.  Because the stretch cluster functionality has yet to be released for the AzureRM provider, this configuration provisions the cluster using the AzAPI provider.

* The module leverages variables for naming and common values to be modified as part of the deployment.

* A tfvars template file has been included for use if implementing this module as a standalone deployment.

