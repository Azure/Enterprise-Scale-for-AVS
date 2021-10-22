# 008-AVS-HCX
Status: Testing

Hybrid Cloud Extension (HCX) is the application mobility platform designed for migration across data centers and clouds. In this step we will enable the HCX add-on for AVS Private cloud which will deploy the HCX Advanced version. 

## Prerequisites

* Completed steps as described in [Configure GlobalReach](../005-AVS-GlobalReach/readme.md).

* Understanding of the [prerequisites](https://docs.microsoft.com/azure/azure-vmware/install-vmware-hcx#prerequisites) for using HCX with Azure VMware Solution.

## Deployment Steps

* Update the parameter values in appropriate location. It may take upto 30 mins to complete this installation.

### ARM

Run following command.

```powershell
cd 008-AVS-HCX/ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-HCX-Deployment -c -f "HCX.deploy.json" -p "@HCX.parameters.json"
```

## Post-deployment Steps

* Navigate to Azure VMware Solution Private Cloud in Azure Portal. Under "Manage" tab, click "Add-ons". Navigate to "Migration using HCX" menu. Ensure that "HCX Cloud Manager IP" and "HCX key name" values are shown. Presence of these values indicate successful deployment of HCX add-on.

* [Download and deploy the VMware HCX Connector OVA](https://docs.microsoft.com/azure/azure-vmware/install-vmware-hcx#download-and-deploy-the-vmware-hcx-connector-ova) at the on-premise site.

* [Activate VMware HCX](https://docs.microsoft.com/azure/azure-vmware/install-vmware-hcx#activate-vmware-hcx) from Azure VMware Solution's HCX Manager interface.

## Next Steps

[Create AVS Private Cloud with HCX add-on enabled](../008-AVS-PrivateCloudWithHCX/readme.md)
