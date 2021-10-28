# Connect two Azure VMware Solution Private Clouds across different Azure regions

This tutorial covers connecting two Azure VMware Solution Private Clouds in different Azure regions via ExpressRoute GlobalReach.

## Prerequisites

* Created two Azure VMware Solution private clouds using steps as described in either [Create Private Cloud](../../PrivateCloud/AVS-PrivateCloud/readme.md) or
[Create Private Cloud with HCX](../../PrivateCloud/AVS-PrivateCloud-WithHCX/readme.md).

* Two Azure VMware Solution private clouds must be in separate Azure regions. To connect, two Azure VMware Solution private clouds in same region use,  [Connect two Azure VMware Solution Private Clouds in the same Azure region](../AVS-to-AVS-SameRegion/readme.md) tutorial.

* No IP overlap between two private clouds.

## Deployment Steps

* Update the parameter values in appropriate parameter file.

* Run one of the following script.

### Bicep

```azurecli-interactive
cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-XR-GR-Deployment -c -f "CrossAVSGlobalReach.bicep" -p "@CrossAVSGlobalReach.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-XR-GR-Deployment -c -f "CrossAVSGlobalReach.deploy.json" -p "@CrossAVSGlobalReach.parameters.json"
```

## Post-deployment Steps

* Navigate to Azure VMware Solution Private Cloud in Azure Portal. Under "Manage" tab, click "Connectivity". Navigate to "ExpressRoute Global Reach" menu. Ensure that under "On-premises cloud connections", you see state of connection as "Connected". Validate that correct subscription, resource group, ExpressRoute circuit and authorization key are listed alongside the state.

## Next Steps

[Connect two Azure VMware Solution Private Clouds in the same Azure region](../AVS-to-AVS-SameRegion/readme.md)
