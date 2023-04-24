### General 

* Description: This module creates a new Azure Firewall instance in an existing VNet with an associated Log Analytics workspace and a Diagnostics configuration for sending firewall logs to the Log Analytics workspace. The deployment also creates an initial firewall policy, but does not populate any rules within the policy. The existing VNet requires that an appropriately sized AzureFirewallSubnet exists and is used for the deployment. Resource ID inputs are usually outputs from other modules, but can be input as the full resource ID string.

* The module leverages variables for naming and common values to be modified as part of the deployment.

* A tfvars template file has been included for use if implementing this module as a standalone deployment.

