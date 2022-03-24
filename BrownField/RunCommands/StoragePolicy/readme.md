# Apply a storage policy to a set of AVS virtual machines

This tutorial shows how to leverage the AVS built-in command "Set-VMStoragePolicy" to apply a (pre-existing) storage policy to a set of Virtual Machines.

## Prerequisites

* An AVS Private Cloud containing at least one cluster.

* A set of AVS virtual machines.

* The name of the storage policy to be applied to virtual machines.

## During the deployment

* Run the following script.

### PowerShell

```azurepowershell-interactive
cd PowerShell

.\setStoragePolicy.ps1 -PrivateCloudName MYAVSPRIVATECLOUD -PrivateCloudResourceGroup AVS-RG -StoragePolicyName "Thin Provision" -VmNames 'VmProd1','VmTest1','VmTest2'
```
## Post-deployment steps

In the Azure Portal, navigate to your AVS Private Cloud, select the "Run Command" menu item and then the "Run Execution Status" tab. Confirm that the "Set-VMStoragePolicy" command has been successfully executed for all the virtual machines.
