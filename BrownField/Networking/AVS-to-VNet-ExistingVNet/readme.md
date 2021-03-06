# Connect Azure VMware Solution with an existing Azure Virtual Network by creating and redeeming Authorization Key

Azure VMware Solution Private cloud comes with a preconfigured dedicated ExpressRoute circuit. This circuit can be used to establish connectivity with Azure Virtual Network. Same circuit can also be used for establishing connectivity with on-premise site using GlobalReach. This tutorial will cover generating an ExpressRoute Authorization Key. This key will be redeemed to create connection with an existing Virtual Network ExpressRoute Gateway in Azure.

## Prerequisites

* Steps as outlined in [Create Private Cloud](../../PrivateCloud/AVS-PrivateCloud/readme.md) or [Create Private Cloud with HCX](../../PrivateCloud/AVS-PrivateCloud-WithHCX/readme.md) section are completed.

* Be aware of the [limit on number of authorization keys](https://docs.microsoft.com/azure/expressroute/expressroute-faqs#can-i-link-to-more-than-one-virtual-network-to-an-expressroute-circuit) that can be generated per ExpressRoute circuit.

## Deployment Steps

* Update the parameter values in appropriate parameter file.

* Run one of the following scripts.

### Bicep

```azurecli-interactive
cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ExR-Deployment -c -f "ExRConnection.bicep" -p "@ExRConnection.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ExR-Deployment -c -f "ExRConnection.deploy.json" -p "@ExRConnection.parameters.json"
```

### PowerShell

```azurepowershell-interactive
cd PowerShell

./Deploy-ExRConnection-GenerateAuthKey.ps1
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
    source = "../AVS-to-VNet-ExistingVNet/Terraform/"
    
    DeploymentResourceGroupName = "<resource group name where new expressroute connection will be deployed>"
    PrivateCloudName            = "<existing private cloud name>"
    PrivateCloudResourceGroup   = "<resource group where existing private cloud is deployed"
    Location                    = "<vnet deployment region>"
    GatewayName                 = "<name for the existing vnet gateway>"
}
```

## Post-deployment Steps

* Validate that Authorization Key is generated. This can be validated by either navigating to "Connectivity" menu under Private Cloud Azure Portal or by running equivalent CLI/Powershell command.

## Next Steps

[Connect Private Cloud to a new VNet](../../Networking/AVS-to-VNet-NewVNet/readme.md) OR

[Configure GlobalReach](../../Networking/AVS-to-OnPremises-ExpressRoute-GlobalReach/readme.md)