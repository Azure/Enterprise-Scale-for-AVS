# Configure GlobalReach

This tutorial walk through scenario of creating ExpressRoute GlobalReach connection. This connection is needed to connect Azure VMware Solution Private Cloud to either on-premise location or another Azure VMware Solution Private Cloud running in a different Azure region.

## Prerequisites

* Completed steps as described in [Connect Private Cloud to a new VNet](../../Networking/AVS-to-VNet-NewVNet/readme.md) OR [Connect Private Cloud to an existing VNet](../../Networking/AVS-to-VNet-ExistingVNet/readme.md) section.

* An on-premise ExpressRoute Circuit ID with which GlobalReach connection is to be established with.

## Deployment Steps

* Update the parameter values in appropriate parameter file.

* Run one of the following script.

### Bicep

```azurecli-interactive
cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-GlobalReach-Deployment -c -f "AVSGlobalReach.bicep" -p "@AVSGlobalReach.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-GlobalReach-Deployment -c -f "AVSGlobalReach.deploy.json" -p "@AVSGlobalReach.parameters.json"
```

### Azure CLI

```azurecli-interactive
cd AzureCLI

./deploy.sh
```

## Post-deployment Steps

* Navigate to the on-premise ExpressRoute circuit's "Private Peering" section under ExpressRoute Configuration tab. GlobalReach connection should be listed there.

## Next Steps

[Configure Monitoring](../../Monitoring/AVS-Utilization-Alerts/readme.md)
