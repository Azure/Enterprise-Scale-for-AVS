# AVS to On-Premises Express Route via Global Reach
Status: Awaiting PG Signoff

In this step we will create the Express Route Global reach connection link. ExpressRoute Global Reach is required to connect AVS to AVS in a different region, and On-premises environments to AVS.

## Prerequisites

* Completed steps as described in [Create Virtual Network Gateway](../004-AVS-ExRConnection-NewVNet/readme.md) section.

* An on-premise ExpressRoute Circuit ID with which GlobalReach connection is to be established with.

## Deployment Steps

* Update the parameter values in appropriate location.

### ARM

Run following command.

```powershell
cd 005-AVS-GlobalReach/ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ExR-GlobalReach-Deployment -c -f "AVSGlobalReach.deploy.json" -p "@AVSGlobalReach.parameters.json"
```

## Post-deployment Steps

* Navigate to the on-premise ExpressRoute circuit's "Private Peering" section under ExpressRoute Configuration tab. GlobalReach connection should be listed there.

## Next Steps

[Configure Monitoring](../006-AVS-Monitor-Utilization/readme.md)
