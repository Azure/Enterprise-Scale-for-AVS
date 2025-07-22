# Update the certificates for a private cloud

This script will update the LDAPs certificates for vcenter using the built-in run command. 

## Prerequisites

1. An AVS Private Cloud containing at least one cluster.

1. A vm with the system managed identity enabled 

1. RBAC permissions for the system managed identity on the private cloud that will be updated.

1. The name of the domain, subscription, resource group name and sddc name for the parameter values.

## During the deployment

* Run the script and supply the parameters for your environment.  You can also edit the script and set the parameters statically if desired.

### PowerShell

```azurepowershell-interactive
.\update-IdentitySourceCertificates.ps1 -SubscriptionID "00000000-000-0000-0000-000000000000" -PrivateCloudResourceGroup AVS-RG -PrivateCloudName MYAVSPRIVATECLOUD  -DomainName "test.local"
```
## Post-deployment steps

In the Azure Portal, navigate to your AVS Private Cloud, select the "Run Command" menu item and then the "Run Execution Status" tab. Confirm that the "update-IdentitySourceCertificates" command has been successfully executed on your private cloud.