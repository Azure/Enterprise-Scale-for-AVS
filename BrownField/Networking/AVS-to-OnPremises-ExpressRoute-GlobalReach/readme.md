# Configure GlobalReach

This tutorial walk through scenario of creating ExpressRoute GlobalReach connection. This connection is needed to connect Azure VMware Solution Private Cloud to either on-premise location or another Azure VMware Solution Private Cloud running in a different Azure region.

## Prerequisites

* Completed steps as described in [Connect Private Cloud to a new VNet](../../Networking/AVS-to-VNet-NewVNet/readme.md) OR [Connect Private Cloud to an existing VNet](../../Networking/AVS-to-VNet-ExistingVNet/readme.md) section.

* An on-premise ExpressRoute Circuit ID with which GlobalReach connection is to be established with.

## Deployment Steps

* Update the parameter values in appropriate parameter file.

* Run one of the following script.

### Bicep

```azurecli-interactive
cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-GlobalReach-Deployment -c -f "AVSGlobalReach.bicep" -p "@AVSGlobalReach.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-GlobalReach-Deployment -c -f "AVSGlobalReach.deploy.json" -p "@AVSGlobalReach.parameters.json"
```

### Azure CLI

```azurecli-interactive
cd AzureCLI

./deploy.sh
```

### Terraform
* If deploying stand-alone, update the sample .tfvars.sample file in the Terraform directory with the deployment values, remove the .sample extension, and run the terraform workflow that fits your environment.
```terraform
terraform init
terraform plan
terraform apply
```
* If deploying as a module within a larger implementation, use a module block similar to the following sample and follow your organization's Terraform workflow:
```terraform
module "AVS-to-AVS-SameRegion" {
    source = "../AVS-to-AVS-SameRegion/Terraform/"
    
    ExpressRouteAuthorizationKey = "<The Express Route Authorization Key to be redeemed by the connection>"
    ExpressRouteId               = "<The Express Route ID to create the connection to>"
    PrivateCloudName             = "<The name of the existing Private Cloud that should be used for the connection>"
    DeploymentResourceGroupName  = "<Resource Group where the new globalReach resource will be created>"
}
```
#### Key Notes - Terraform
* This terraform module deploys Azure resources that don't yet have an official AzureRM provider implementation. To work around this limitation, this terraform module calls an ARM template deployment using a previously created ARM template and injects the variable values as parameters. When implementing this, the module assumes the ARM template resides in the module folder for the file reference to work. This approach is effective for deployment, but has known issues when performing destroy operations. This module will be updated as new functionality is released, but destroy operations should be performed manually until the new functionality is available.  

## Post-deployment Steps

* Navigate to the on-premise ExpressRoute circuit's "Private Peering" section under ExpressRoute Configuration tab. GlobalReach connection should be listed there.

## Next Steps

[Configure Monitoring](../../Monitoring/AVS-Utilization-Alerts/readme.md)
