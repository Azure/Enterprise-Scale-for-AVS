# Connect Azure VMware Solution with Azure Virtual Network by redeeming Authorization Key

This tutorial walks through scenario of using the Authorization Key from Azure VMware Solution ExpressRoute circuit and redeeming it on Azure Virtual Network ExpressRoute Gateway. There are two additional tutorials which ***create as well as redeem*** an Authorization Key on either an [existing](../../Networking/AVS-to-VNet-ExistingVNet/readme.md) or [new](../../Networking/AVS-to-VNet-NewVNet/readme.md) Azure Virtual Network.

## Prerequisites

* Steps as outlined in [Create Azure VMware Solution Private Cloud](../../PrivateCloud/AVS-PrivateCloud/readme.md)  OR [Create Azure VMware Solution Private Cloud with HCX](../../PrivateCloud/AVS-PrivateCloud-WithHCX/readme.md).

* An existing Azure Virtual Network Gateway of Type ExpressRoute.

* Be aware of egress costs if Azure VMware Solution ExpressRoute and Virtual Network are in different Azure regions.

## During the deployment

* Update the parameter values in appropriate parameter file.

* Run one of the following script.

### Bicep

```azurecli-interactive
cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ExR-Connection-Deployment -c -f "ExRConnection.bicep" -p "@ExRConnection.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ExR-Connection-Deployment -c -f "ExRConnection.deploy.json" -p "@ExRConnection.parameters.json"
```

### PowerShell

```azurepowershell-interactive
cd PowerShell

./Deploy-ExRConnection-SeparateAuthKey.ps1
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
module "ExpressRoute-To-Vnet" {
    source = "../ExpressRoute-To-Vnet/Terraform/"
    
    resourceGroupNameVnetGateway  = "<enter Vnet Gateway RG name here>"
    resourceGroupNameExpressRoute = "<enter expressRoute circuit RG name here>"
    gatewayName                   = "<enter name of existing vnet gateway here>"
    expressRouteName              = "<enter name of existing ExpressRoute circuit here>"
    connectionName                = "<enter name for the new connection being created>"
    expressRouteAuthorizationKey  = "<enter existing ExpressRoute Authorization Key>"
}
```

## Post-deployment steps

In the Azure Portal, navigate to the "Connections" menu for the Virtual Network Gateway and verify the "Status" of the connection is showing as "Succeeded".

## Next Steps

[Connect Private Cloud to a new VNet](../../Networking/AVS-to-VNet-NewVNet/readme.md) OR

[Connect Private Cloud to an existing VNet](../../Networking/AVS-to-VNet-ExistingVNet/readme.md)
