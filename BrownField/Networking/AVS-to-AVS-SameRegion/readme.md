# Connect two Azure VMware Solution Private Clouds in the same Azure region

This tutorial covers [AVS Interconnect](https://docs.microsoft.com/azure/azure-vmware/connect-multiple-private-clouds-same-region?WT.mc_id=Portal-VMCP) . Two Azure VMware Solution private clouds in the ***same*** Azure region can be connected with AVS InterConnect.

## Prerequisites

* Created two Azure VMware Solution private clouds **in the same Azure regions** using steps as described in either [Create Azure VMware Solution Private Cloud](../../PrivateCloud/AVS-PrivateCloud/readme.md) or [Create Azure VMware Solution Private Cloud with HCX](../../PrivateCloud/AVS-PrivateCloud-WithHCX/readme.md).

* Two private clouds must be in the same Azure regions. To connect two private clouds in different Azure regions, use guidance available on [Connect two Azure VMware Solution Private Clouds across different Azure regions](../../Networking/AVS-to-AVS-CrossRegion-GlobalReach/readme.md).

* No IP overlap between two private clouds.

## Deployment Steps

* Update the parameter values in appropriate parameter file.

* Run one of the following scripts.

### Bicep

```azurecli-interactive
cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-InterConnect-Deployment -c -f "CrossAVSWithinRegion.deploy.json" -p "@CrossAVSWithinRegion.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-InterConnect-Deployment -c -f "CrossAVSWithinRegion.deploy.json" -p "@CrossAVSWithinRegion.parameters.json"
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
    
    PrimaryPrivateCloudName     = "<Name of the existing primary private cloud that will contain the inter-private cloud link resource, must exist within this resource group>"
    SecondaryPrivateCloudId     = "<Full resource id of the secondary private cloud, must be in the same region as the primary>"
    DeploymentResourceGroupName = "<Resource Group where the new globalReach resource will be created>"
}
```
#### Key Notes - Terraform
* This terraform module deploys Azure resources that don't yet have an official AzureRM provider implementation. To work around this limitation, this terraform module calls an ARM template deployment using a previously created ARM template and injects the variable values as parameters. When implementing this, the module assumes the ARM template resides in the module folder for the file reference to work. This approach is effective for deployment, but has known issues when performing destroy operations. This module will be updated as new functionality is released, but pending release destroy operations should be performed manually.  

## Post-deployment Steps

* Navigate to Azure VMware Solution Private Cloud in Azure Portal. Under "Manage" tab, click "Connectivity". Navigate to "AVS Interconnect" menu. Under "AVS Private cloud" column, verify if the other Azure VMware Solution private cloud is listed. Also, verify that correct state is listed under "Is source?" column.

## Next Steps

[Complete deployment of Azure VMware Solution](../../../AVS-Landing-Zone/GreenField/readme.md)
