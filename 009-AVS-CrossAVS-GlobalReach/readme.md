# 009-AVS-CrossAVS-GlobalReach
Status: Awaiting PG Signoff

## Prerequisites

* Created two Azure VMware Solution private clouds using steps as described in [Create Private Cloud](../001-AVS-PrivateCloud/readme.md).

* Two private clouds must be in separate Azure regions. To connect, two private clouds in same region use, [AVS Interconnect](https://docs.microsoft.com/azure/azure-vmware/connect-multiple-private-clouds-same-region?WT.mc_id=Portal-VMCP).

* No IP overlap between two private clouds.

## Deployment Steps

* Update the parameter values in appropriate location.

### ARM

Run following command.

```powershell
cd 009-AVS-CrossAVS-GlobalReach/ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ExR-Deployment -c -f "CrossAVSGlobalReach.deploy.json" -p "@CrossAVSGlobalReach.parameters.json"
```

## Post-deployment Steps

* Navigate to Azure VMware Solution Private Cloud in Azure Portal. Under "Manage" tab, click "Connectivity". Navigate to "ExpressRoute Global Reach" menu. Ensure that under "On-prem cloud connections", you see state of connection as "Connected". Validate that correct subscription, resource group, expressroute circuit and authorization key are listed alongside the state.

## Next Steps

[Connect two Azure VMware Solution Private Clouds in the same Azure region](../010-AVS-CrossAVS-WithinRegion/readme.md)
