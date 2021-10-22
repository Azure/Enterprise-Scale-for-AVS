# 008-AVS-PrivateCloudWithHCX
Status: Awaiting PG Signoff

## Prerequisites

* Completed steps as described in [Configure GlobalReach](../005-AVS-GlobalReach/readme.md).

* Understanding of the [prerequisites](https://docs.microsoft.com/azure/azure-vmware/install-vmware-hcx#prerequisites) for using HCX with Azure VMware Solution.

* Completed additional prerequisites as described in [Create Private Cloud](../001-AVS-PrivateCloud/readme.md#prerequisites).

## Deployment Steps

* Update the parameter values in appropriate location. It may take upto 2 hours to create Azure VMware Solution Private Cloud. Additionally, upto 30 mins are needed to complete HCX installation.

### ARM

Run following command.

```powershell
cd 008-AVS-PrivateCloudWithHCX/ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-HCX-Deployment -c -f "PrivateCloudWithHCX.deploy.json" -p "@PrivateCloudWithHCX.parameters.json"
```

## Post-deployment Steps

* Ensure that status of deployment is "Succeeded" by navigating to "Deployment" tab of the Azure Resource Group used for starting the deployment.

* Complete additional prerequisites as described in [Configure HCX](../008-AVS-HCX/readme.md##post-deployment-steps).

## Next Steps

[Connect two Azure VMware Solution Private Clouds across different Azure regions](../009-AVS-CrossAVS-GlobalReach/readme.md)
