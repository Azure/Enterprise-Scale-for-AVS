# Connect two Azure VMware Solution Private Clouds across different Azure regions

This tutorial covers connecting two Azure VMware Solution Private Clouds in two different Azure regions via ExpressRoute GlobalReach.

## Prerequisites

* Previously created two Azure VMware Solution private clouds using steps as described in either [Create Private Cloud](../../PrivateCloud/AVS-PrivateCloud/readme.md) or
[Create Private Cloud with HCX](../../PrivateCloud/AVS-PrivateCloud-WithHCX/readme.md).

* The two Azure VMware Solution private clouds must be in separate Azure regions. To connect two Azure VMware Solution private clouds in the same region use the [Connect two Azure VMware Solution Private Clouds in the same Azure region](../AVS-to-AVS-SameRegion/readme.md) tutorial.

* No IP overlap between two private clouds.

## Deployment Steps

* Update the parameter values in appropriate parameter file.

* Run one of the following scripts.

### Bicep

```azurecli-interactive
cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-XR-GR-Deployment -c -f "CrossAVSGlobalReach.bicep" -p "@CrossAVSGlobalReach.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-XR-GR-Deployment -c -f "CrossAVSGlobalReach.deploy.json" -p "@CrossAVSGlobalReach.parameters.json"
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
module "AVS-to-AVS-CrossRegion-GlobalReach" {
    source = "../AVS-to-AVS-CrossRegion-GlobalReach/Terraform/"
    
    PrimaryPrivateCloudName            = "<Name of the existing primary private cloud that will contain the inter-private cloud link resource, must exist within this resource group>"
    SecondaryPrivateCloudName          = "<Name of the existing secondary private cloud that global reach will connect to>"
    PrimaryPrivateCloudResourceGroup   = "<Resource group name of the existing primary private cloud>"
    SecondaryPrivateCloudResourceGroup = "<Resource group name of the existing secondary private cloud>"
}
```
#### Key Notes - Terraform
* This terraform module deploys Azure resources that don't yet have an official AzureRM provider implementation. To work around this limitation, this terraform module calls an ARM template deployment using a previously created ARM template and injects the variable values as parameters. When implementing this, the module assumes the ARM template resides in the module folder for the file reference to work. This approach is effective for deployment, but has known issues when performing destroy operations. This module will be updated as new functionality is released, but destroy operations should be performed manually until the new functionality is available.  

## Post-deployment Steps

* Navigate to Azure VMware Solution Private Cloud in Azure Portal. Under "Manage" tab, click "Connectivity". Navigate to "ExpressRoute Global Reach" menu. Ensure that under "On-premises cloud connections", you see state of connection as "Connected". Validate that correct subscription, resource group, ExpressRoute circuit and authorization key are listed alongside the state.

## Next Steps

[Connect two Azure VMware Solution Private Clouds in the same Azure region](../AVS-to-AVS-SameRegion/readme.md)
