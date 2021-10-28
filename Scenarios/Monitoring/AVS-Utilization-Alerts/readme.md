# Configure Monitoring

It is crucial to monitor the resource utilization in order to take timely action. This tutorial walks through setting up Azure Monitor alerts for Azure VMware Solution Private Cloud. Action owners will receive email notifications if utilization metrics exceeds set threshold.

## Prerequisites

* AVS Private Cloud up and running.

* A list of email address(es) who will receive Alerts from Azure VMware Solution Private Cloud.

## Deployment Steps

* Update the parameter values in appropriate parameter file.

* Run one of the following scripts.

### Bicep

```azurecli-interactive
cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-Monitoring-Deployment -c -f "AVSMonitor.bicep" -p "@AVSMonitor.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-Monitoring-Deployment -c -f "AVSMonitor.deploy.json" -p "@AVSMonitor.parameters.json"
```

## Post-deployment Steps

* Navigate to Azure Monitor service in Azure Portal. Click "Alerts" tab and navigate to "Manage alert rules". Newly created alert - *AVSAlert* - should be listed with status as "Enabled".

## Next Steps

[Configure SRM](../../Addons/SRM/readme.md)
