# Connect Azure VMware Solution with a new Azure Virtual Network by creating and redeeming Authorization Key

This tutorial walks through the scenario of connecting Azure VMware Solution Private Cloud to a ***new*** Azure Virtual Network. To connect Azure VMware Solution Private Cloud to an ***existing*** Azure Virtual Network, refer to tutorial on [Connect Private Cloud to an existing VNet](../../Networking/AVS-to-VNet-ExistingVNet/readme.md).

## Prerequisites

* Steps as outlined in [Create Private Cloud](../../PrivateCloud/AVS-PrivateCloud/readme.md) or [Create Private Cloud with HCX](../../PrivateCloud/AVS-PrivateCloud-WithHCX/readme.md) section are completed.

* Be aware of the [limit on number of authorization keys](https://docs.microsoft.com/azure/expressroute/expressroute-faqs#can-i-link-to-more-than-one-virtual-network-to-an-expressroute-circuit) that can be generated per ExpressRoute circuit.

## Deployment Steps

* Update the parameter values in appropriate parameter file.

* Run one of the following scripts.

### Bicep

```azurecli-interactive
cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ExR-VNet-Deployment -c -f "VNetWithExR.deploy.json" -p "@VNetWithExR.deploy.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-ExR-VNet-Deployment -c -f "VNetWithExR.deploy.json" -p "@VNetWithExR.deploy.parameters.json"
```

## Post-deployment Steps

* Navigate to "Azure Monitor", click "Networks" and select "Network health" tab. Apply filter with `Type=ER and VPN Connections`. ER Connection with Azure VMware Solution should show "Available" under "Health" column.

## Next Steps

[Configure GlobalReach](../../Networking/AVS-to-OnPremises-ExpressRoute-GlobalReach/readme.md)
