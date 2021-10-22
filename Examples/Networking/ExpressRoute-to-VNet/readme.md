# 003-AVS-ExRConnection-SeperateAuthKey
Status: Awaiting PG Signoff

This step is required for network admins who do not have access to AVS to generate the Auth Key themselves but need to setup the connectivity with Onpremise location or Azure. You just need to provide the available Authorizaton key and ExR circuit ID in the template parameters to be redeemed by the virtual network connection.

## Prerequisites

* Steps as outlined in [Generate Auth Key](../002-AVS-ExRConnection-GenerateAuthKey/readme.md) section are completed.

* An existing Azure Virtual Network Gateway of Type ExpressRoute.

* Be aware of egress costs if Azure VMware Solution ExpressRoute and Virtual Network are in different Azure regions.

## During the deployment

* Update the parameter values in appropriate location.

### ARM

Run following command.

```powershell
cd 003-AVS-ExRConnection-SeperateAuthKey/ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ExR-Connection-Deployment -c -f "ExRConnection.deploy.json" -p "@ExRConnection.parameters.json"
```

## Post-deployment steps

In the Azure Portal navigate to the "Connections" menu for the Virtual Network Gateway and verify the "Status" of the connection is showing as "Succeeded".

## Next Steps

[Create Virtual Network Gateway](../004-AVS-ExRConnection-NewVNet/readme.md)
