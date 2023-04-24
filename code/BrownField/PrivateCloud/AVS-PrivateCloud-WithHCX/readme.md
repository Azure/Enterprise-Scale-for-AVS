# Create Azure VMware Solution Private Cloud with HCX

Azure VMware Solution provides private cloud environment with vSphere cluster built from dedicated bare-metal Azure infrastructure. This tutorial walks through the process of provisioning the private cloud resource with HCX enabled.

## Prerequisites

Ensure to check following prerequisites before starting the deployment process.

* Azure VMware Solution host quota is approved for the Azure subscription.

* Azure Account associated with the user or service principal has contributor permissions on Azure subscription.

* Do not allow standing access to user or service principal to be used for initiating deployment. Use [Azure Active Directory Privileged Identity Management (PIM)](https://docs.microsoft.com/azure/active-directory/privileged-identity-management/pim-configure) to request Just-In-Time access for starting the deployment process.

## Deployment Steps

* Update the parameter values in appropriate parameter file. 

* Deploy the AVS private cloud using one of the following ways. It may take up to 3-4 hours to create Azure VMware Solution Private Cloud. Additionally, up to 30 minutes are needed to complete HCX installation.

### Bicep

```azurecli-interactive

cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-HCX-Deployment -c -f "PrivateCloudWithHCX.bicep" -p "@PrivateCloudWithHCX.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-HCX-Deployment -c -f "PrivateCloudWithHCX.deploy.json" -p "@PrivateCloudWithHCX.parameters.json"
```

## Post-deployment Steps

* Ensure that status of deployment is "Succeeded" by navigating to "Deployment" tab of the Azure Resource Group used for starting the deployment.

* Complete additional prerequisites as described in [Configure HCX](../../Addons/HCX/readme.md##post-deployment-steps).

## Next Steps

[Connect two Azure VMware Solution Private Clouds across different Azure regions](../../Networking/AVS-to-AVS-CrossRegion-GlobalReach/readme.md)
