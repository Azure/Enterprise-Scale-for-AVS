# Connect Azure VMware Solution to an Azure NetApp Files datastore with a new Azure Virtual Network by creating and redeeming Authorization Key

This tutorial walks through the scenario of connecting Azure VMware Solution Private Cloud to an Azure NetApp Files datastore with a ***new*** Azure Virtual Network. 

## Prerequisites

* Steps as outlined in [Create Private Cloud](../../PrivateCloud/AVS-PrivateCloud/readme.md) or [Create Private Cloud with HCX](../../PrivateCloud/AVS-PrivateCloud-WithHCX/readme.md) section are completed.

* Be aware of the [limit on number of authorization keys](https://docs.microsoft.com/azure/expressroute/expressroute-faqs#can-i-link-to-more-than-one-virtual-network-to-an-expressroute-circuit) that can be generated per ExpressRoute circuit.

* **Be aware of the costs associated with [Azure NetApp Files](https://azure.microsoft.com/pricing/details/netapp/) and the ExpressRoute gateway using the 'Ultra Performance' SKU.**

## Deployment Steps

* Update the parameter values in appropriate parameter file.

* Run one of the following scripts.

### Bicep

```azurecli-interactive
cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ANF-datastore-Deployment -c -f "ANFdatastoreWithNewVNet.bicep" -p "@ANFdatastoreWithNewVNet.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ANF-datastore-Deployment -c -f "ANFdatastoreWithNewVNet.deploy.json" -p "@ANFdatastoreWithNewVNet.parameters.json"
```

### Terraform
* If deploying stand-alone, update the sample .tfvars.sample file in the Terraform directory with the deployment values, remove the .sample extension, and run the terraform workflow that fits your environment.
```terraform
terraform init
terraform plan -var-file="AVS-to-ANFdatastore-NewVNet.tfvars"
terraform apply -var-file="AVS-to-ANFdatastore-NewVNet.tfvars"
```
* If deploying as a module within a larger implementation, use a module block similar to the following sample and follow your organization's Terraform workflow:
```terraform
module "AVS-to-ANFdatastore-NewVnet" {
    source = "../AVS-to-ANFdatastore-NewVNet/Terraform/"
    
    DeploymentResourceGroupName    = "<resource group name where new vnet and gateway will be deployed>"
    PrivateCloudName               = "<existing private cloud name>"
    PrivateCloudResourceGroup      = "<resource group where existing private cloud is deployed"
    PrivateCloudSubscriptionId     = "<private cloud subscription id value (not full resource id)>"
    Location                       = "<vnet deployment region>"
    VNetName                       = "<new vnet name>"
    VNetAddressSpaceCIDR           = ["<CIDR for new vnet>",]
    VNetGatewaySubnetCIDR          = ["<CIDR for gateway subnet>",]
    VNetANFDelegatedSubnetCIDR     = ["<CIDR for gateway subnet>",]
    GatewayName                    = "<name for new vnet gateway>"
    GatewaySku                     = "UltraPerformance"
    netappAccountName              = "NetAppAccount-AVSdatastore"
    netappCapacityPoolName         = "CapacityPool-AVSdatastore"
    netappCapacityPoolServiceLevel = "Premium"
    netappCapacityPoolSize         = 4
    netappVolumeName               = "ANFdatastore001"
    netappVolumeSize               = 4398046511104
}
```
## Post-deployment Steps

* Navigate to "Azure Monitor", click "Networks" and select "Network health" tab. Apply filter with `Type=ER and VPN Connections`. ER Connection with Azure VMware Solution should show "Available" under "Health" column.

## Next Steps

[Understand Azure NetApp Files datastore best practices](https://learn.microsoft.com/azure/azure-vmware/attach-azure-netapp-files-to-azure-vmware-solution-hosts)
