# AVS to AVS: Same Region
Status: Awaiting PG Signoff

This step is required when you have two AVS private clouds in the same Azure region and you want to setup the connectivity between them. Here we will establish the connectivity by using AVS Interconnect.

## Prerequisites

* Created two Azure VMware Solution private clouds **in the same Azure regions** using steps as described in [Create Private Cloud](../../PrivateCloud/AVS-PrivateCloud/readme.md).

* Two private clouds must be in the same Azure regions. To connect, two private clouds in different Azure regions use guidance available on [Connect two Azure VMware Solution Private Clouds across different Azure regions](../AVS-to-AVS-CrossRegion-GlobalReach/readme.md).

* No IP overlap between two private clouds.

## Deployment Steps

* Update the parameter values in appropriate location.

### ARM

Run following command.

```powershell
cd 010-AVS-CrossAVS-WithinRegion/ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-HCX-Deployment -c -f "CrossAVSWithinRegion.deploy.json" -p "@CrossAVSWithinRegion.parameters.json"
```

## Post-deployment Steps

* Navigate to Azure VMware Solution Private Cloud in Azure Portal. Under "Manage" tab, click "Connectivity". Navigate to "AVS Interconnect" menu. Under "AVS Private cloud" column, verify if the other Azure VMware Solution private cloud is listed. Also, verify that correct state is listed under "Is source?" column.

## Next Steps

[Complete deployment of Azure VMware Solution](../../../AVS-Landing-Zone/SingleRegion/readme.md)
