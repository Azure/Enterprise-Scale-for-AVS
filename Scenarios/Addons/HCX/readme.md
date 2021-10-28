# Configure HCX on an existing Azure VMware Solution Private Cloud

Hybrid Cloud Extension (HCX) is the application mobility platform designed for migration across data centers and clouds. This tutorial walks through the scenario of enabling HCX add-on for Azure VMware Solution Private Cloud.

## Prerequisites

* AVS Private Cloud up and running.

* Understanding of the [prerequisites](https://docs.microsoft.com/azure/azure-vmware/install-vmware-hcx#prerequisites) for using HCX with Azure VMware Solution.

## Deployment Steps

* Update the parameter values in the parameters file.

* Run one of the following scripts. It may take up to 30 minutes to complete this installation.

### Bicep

```azurecli-interactive
cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-HCX-Deployment -c -f "HCX.bicep" -p "@HCX.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-HCX-Deployment -c -f "HCX.deploy.json" -p "@HCX.parameters.json"
```

### Azure CLI

```azurecli-interactive
cd AzureCLI

./deploy.sh
```

## Post-deployment Steps

* Navigate to Azure VMware Solution Private Cloud in Azure Portal. Under "Manage" tab, click "Addons". Navigate to "Migration using HCX" menu. Ensure that "HCX Cloud Manager IP" and "HCX key name" values are shown. Presence of these values indicate successful deployment of HCX add-on.

* [Download and deploy the VMware HCX Connector OVA](https://docs.microsoft.com/azure/azure-vmware/install-vmware-hcx#download-and-deploy-the-vmware-hcx-connector-ova) at the on-premise site.

* [Activate VMware HCX](https://docs.microsoft.com/azure/azure-vmware/install-vmware-hcx#activate-vmware-hcx) from Azure VMware Solution's HCX Manager interface.

## Next Steps

[Create a Private Cloud with HCX Preconfigured](../../PrivateCloud/AVS-PrivateCloud-WithHCX/readme.md)
