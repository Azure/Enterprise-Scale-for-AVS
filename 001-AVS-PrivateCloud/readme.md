# 001-AVS-PrivateCloud
Status: Awaiting PG Signoff

## Prerequisites

Ensure to check following prerequisites before starting the deployment process.

* Azure VMware Solution host quota is approved for the Azure subscription.

* Azure Account associated with the user or service principal has contributor permissions on Azure subscription.

* Do not allow standing access to user or service principal to be used for initiating deployment. Use [Azure Active Directory Privileged Identity Management (PIM)](https://docs.microsoft.com/azure/active-directory/privileged-identity-management/pim-configure) to request Just-In-Time access for starting the deployment process.

## Deployment Steps

* Update the parameter values in appropriate location.

Run one of the following command.

### Bicep

```azurecli-interactive
az group create -n AVS-Step-By-Step-RG -l SoutheastAsia

cd 001-AVS-PrivateCloud/AzureCLI

az deployment group create -g AVS-Step-By-Step-RG -f ./PrivateCloud.bicep -p "@PrivateCloud.parameters.json" -c

```

### ARM

```powershell
az group create -n AVS-Step-By-Step-RG -l SoutheastAsia

cd 001-AVS-PrivateCloud/ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-VPC-Deployment -c -f "PrivateCloud.deploy.json" -p "@PrivateCloud.parameters.json"
```

### Azure CLI

```azurecli-interactive
az group create -n AVS-Step-By-Step-RG -l SoutheastAsia

cd 001-AVS-PrivateCloud/AzureCLI

./deploy.sh
```

Depending upon the region and size of the cluster, deployment process may take upto 2 hours.

## Post-deployment Steps

Ensure that status of deployment is "Succeeded" by navigating to "Deployment" tab of the Azure Resource Group used for starting the deployment.

## Next Steps

[Generate Auth Key](../002-AVS-ExRConnection-GenerateAuthKey/readme.md)
