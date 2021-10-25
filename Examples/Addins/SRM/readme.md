# SRM AddIn Deployment for AVS
Status: Testing

Site Recovery Manager (SRM) is the disaster recovery solution by VMware. In this step, you need to provide the SRM license key to enable the SRM addon for AVS private cloud which will install the SRM plugin and vSphere Replication appliances in the vCenter.

## Prerequisites

* AVS Private Cloud up and running

* [SRM license key](https://docs.microsoft.com/azure/azure-vmware/disaster-recovery-using-vmware-site-recovery-manager#srm-licenses) obtained from VMware.

* [Other prerequisites](https://docs.microsoft.com/azure/azure-vmware/disaster-recovery-using-vmware-site-recovery-manager#prerequisites) as applicable for supported scenarios with Azure VMware Solution.

## Deployment Steps

* Update the parameter values in appropriate location.

* Run one of the following script.

### Bicep

```azurecli-interactive
cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-SRM-Deployment -c -f "SRM.bicep" -p "@SRM.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-SRM-Deployment -c -f "SRM.deploy.json" -p "@SRM.parameters.json"
```

### Azure CLI

```azurecli-interactive
cd AzureCLI

./deploy.sh
```

## Post-deployment Steps

* Navigate to Azure VMware Solution Private Cloud in Azure Portal. Under "Manage" tab, click "Add-ons". Navigate to "Disaster recovery" menu. Ensure that "Uninstall VMware Site Recovery Manager (SRM)" and "Uninstall vSphere Replication" buttons are enabled. Enabled buttons indicate successful deployment of SRM add-on.

* Complete site pairing as per [Configure site pairing in vCenter](https://docs.microsoft.com/azure/azure-vmware/disaster-recovery-using-vmware-site-recovery-manager#configure-site-pairing-in-vcenter) guidance.

## Next Steps

[Configure HCX on an existing Azure VMware Solution Private Cloud](../../Addins/HCX/readme.md)
