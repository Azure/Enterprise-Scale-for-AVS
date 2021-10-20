# 002-AVS-ExRConnection-GenerateAuthKey
Status: Awaiting PG Signoff

## Prerequisites

* Steps as outlined in [Create Private Cloud](../001-AVS-PrivateCloud/readme.md) section are completed.

* Be aware of the [limit on number of authorization keys](https://docs.microsoft.com/azure/expressroute/expressroute-faqs#can-i-link-to-more-than-one-virtual-network-to-an-expressroute-circuit) that can be generated per ExpressRoute circuit.

## Deployment Steps

* Update the parameter values in appropriate location.

### ARM

Run following command.

```powershell
cd 002-AVS-ExRConnection-GenerateAuthKey/ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ExR-Deployment -c -f "ExRConnection.deploy.json" -p "@ExRConnection.parameters.json"
```

## Post-deployment Steps

* Validate that Authorization Key is generated. This can be validated by either navigating to "Connectivity" menu under Private Cloud Azure Portal or by running equivalent CLI/Powershell command.

## Next Steps

[Redeem Auth Key](../003-AVS-ExRConnection-SeperateAuthKey/readme.md)
