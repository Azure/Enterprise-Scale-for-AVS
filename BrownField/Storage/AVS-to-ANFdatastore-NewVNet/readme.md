# Connect Azure VMware Solution to an Azure NetApp Files datastore with a new Azure Virtual Network by creating and redeeming Authorization Key

This tutorial walks through the scenario of connecting Azure VMware Solution Private Cloud to and Azure NetApp Files datastore with a ***new*** Azure Virtual Network. 

## Prerequisites

* Steps as outlined in [Create Private Cloud](../../PrivateCloud/AVS-PrivateCloud/readme.md) or [Create Private Cloud with HCX](../../PrivateCloud/AVS-PrivateCloud-WithHCX/readme.md) section are completed.

* Be aware of the [limit on number of authorization keys](https://docs.microsoft.com/azure/expressroute/expressroute-faqs#can-i-link-to-more-than-one-virtual-network-to-an-expressroute-circuit) that can be generated per ExpressRoute circuit.

## Deployment Steps

* Update the parameter values in appropriate parameter file.

* Run one of the following scripts.

### Bicep

```azurecli-interactive
cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ExR-VNet-Deployment -c -f "VNetWithExR.deploy.json" -p "@VNetWithExR.deploy.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ExR-VNet-Deployment -c -f "VNetWithExR.deploy.json" -p "@VNetWithExR.deploy.parameters.json"
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
module "AVS-to-New-Vnet" {
    source = "../AVS-to-VNet-NewVNet/Terraform/"
    
    DeploymentResourceGroupName = "<resource group name where new vnet and gateway will be deployed>"
    PrivateCloudName            = "<existing private cloud name>"
    PrivateCloudResourceGroup   = "<resource group where existing private cloud is deployed"
    PrivateCloudSubscriptionId  = "<private cloud subscription id value (not full resource id)>"
    Location                    = "<vnet deployment region>"
    VNetName                    = "<new vnet name>"
    VNetAddressSpaceCIDR        = ["<CIDR for new vnet>",]
    VNetGatewaySubnetCIDR       = ["<CIDR for gateway subnet>",]
    GatewayName                 = "<name for new vnet gateway>"
    GatewaySku                  = "Standard"
}
```
## Post-deployment Steps

* Navigate to "Azure Monitor", click "Networks" and select "Network health" tab. Apply filter with `Type=ER and VPN Connections`. ER Connection with Azure VMware Solution should show "Available" under "Health" column.

## Next Steps

[Configure GlobalReach](../../Networking/AVS-to-OnPremises-ExpressRoute-GlobalReach/readme.md)
