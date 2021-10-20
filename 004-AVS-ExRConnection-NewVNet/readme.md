# 004-AVS-ExRConnection-NewVNet
Status: Awaiting PG Signoff

## Prerequisites

* Completed steps as described in [Redeem Auth Key](../003-AVS-ExRConnection-SeperateAuthKey/readme.md) section.

## Deployment Steps

* Update the parameter values in appropriate location.

### ARM

Run following command.

```powershell
cd 004-AVS-ExRConnection-NewVNet/ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ExR-VNet-Deployment -c -f "VNetWithExR.deploy.json" -p "@VNetWithExR.deploy.parameters.json"
```

## Post-deployment Steps

* Navigate to "Azure Monitor", click "Networks" and select "Network health" tab. Apply filter with `Type=ER and VPN Connections`. ER Connection with Azure VMware Solution should show "Available" under "Health" column.

## Next Steps

[Configure GlobalReach](../005-AVS-GlobalReach/readme.md)
