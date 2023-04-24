# Create Azure VMware Solution Private Cloud

Azure VMware Solution provides private cloud environment with vSphere cluster built from dedicated bare-metal Azure infrastructure. This is the first tutorial to walk through the process of provisioning the private cloud resource.

## Prerequisites

Ensure to check following prerequisites before starting the deployment process.

* Azure VMware Solution host quota is approved for the Azure subscription.

* Azure Account associated with the user or service principal has contributor permissions on Azure subscription.

* Do not allow standing access to user or service principal to be used for initiating deployment. Use [Azure Active Directory Privileged Identity Management (PIM)](https://docs.microsoft.com/azure/active-directory/privileged-identity-management/pim-configure) to request Just-In-Time access for starting the deployment process.

## Deployment Steps

* Update the parameter values in appropriate parameter file.

* Deploy the AVS private cloud using one of the following ways. It may take up to 3-4 hours to create Azure VMware Solution Private Cloud.

### Bicep

```azurecli-interactive
az group create -n AVS-Step-By-Step-RG -l SoutheastAsia

cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-SDDC-Deployment -f ./PrivateCloud.bicep -p "@PrivateCloud.parameters.json" -c

```

### ARM

```powershell
az group create -n AVS-Step-By-Step-RG -l SoutheastAsia

cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-SDDC-Deployment -c -f "PrivateCloud.deploy.json" -p "@PrivateCloud.parameters.json"
```

### Azure CLI

```azurecli-interactive
az group create -n AVS-Step-By-Step-RG -l SoutheastAsia

cd AzureCLI

./deploy.sh
```

### PowerShell

```azurepowershell-interactive
cd PowerShell

./Deploy-PrivateCloud.ps1

```

Depending upon the region and size of the cluster, deployment process may take up to 4 hours.

## Post-deployment Steps

Ensure that status of deployment is "Succeeded" by navigating to the "Deployment" tab of the Azure Resource Group used for initiating the deployment.

## Next Steps

[Connect Azure VMware Solution with Azure Virtual Network by redeeming Authorization Key](../../Networking/ExpressRoute-to-VNet/readme.md) OR

[Connect Azure VMware Solution with a new Azure Virtual Network by creating and redeeming Authorization Key](../../Networking/AVS-to-VNet-NewVNet/readme.md) OR

[Connect Azure VMware Solution with an existing Azure Virtual Network by creating and redeeming Authorization Key](../../Networking/AVS-to-VNet-ExistingVNet/readme.md) OR

[Create a Private Cloud with HCX Preconfigured](../AVS-PrivateCloud-WithHCX/readme.md)
