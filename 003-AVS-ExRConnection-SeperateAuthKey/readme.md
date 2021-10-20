# 003-AVS-ExRConnection-SeperateAuthKey
Status: Awaiting PG Signoff

## Prerequisites

* Steps as outlined in [Generate Auth Key](../002-AVS-ExRConnection-GenerateAuthKey/readme.md) section are completed.

* An existing Azure Virtual Network Gateway of Type ExpressRoute.

* Be aware of egress costs If Azure VMware Solution ExpressRoute and Virtual Network are in separate Azure regions.

## During the deployment

* Update the parameter values in appropriate location.

### ARM

Run following command.

```powershell
cd 003-AVS-ExRConnection-SeperateAuthKey/ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ExR-Connection-Deployment -c -f "ExRConnection.deploy.json" -p "@ExRConnection.parameters.json"
```

## Post-deployment steps

Navigate to "Connections" menu for the Virtual Network Gateway and verify the "Status" column of connection is showing "Succeeded".

## Next Steps

[Create Virtual Network Gateway](../004-AVS-ExRConnection-NewVNet/readme.md)
