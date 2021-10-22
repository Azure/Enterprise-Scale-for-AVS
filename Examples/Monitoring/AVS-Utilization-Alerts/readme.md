# AVS Utilization Alerts
Status: Awaiting PG Signoff

It is crucial to monitor the resource utilization in order to take timely action. In this step we are enabling and setting up Azure Monitor alerts for AVS private cloud. Email notifications will be triggered to action owners if utilization hit beyond set threshold.

## Prerequisites

* Completed steps as described in [Configure GlobalReach](../005-AVS-GlobalReach/readme.md).

* A list of email address(es) who will receive Alerts from Azure VMware Solution Private Cloud.

## Deployment Steps

* Update the parameter values in appropriate location.

### ARM

Run following command.

```powershell
cd 006-AVS-Monitor-Utilization/ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-Monitoring-Deployment -c -f "AVSMonitor.deploy.json" -p "@AVSMonitor.parameters.json"
```

## Post-deployment Steps

* Navigate to Azure Monitor service in Azure Portal. Click "Alerts" tab and navigate to "Manage alert rules". Newly created alert - *AVSAlert* - should be listed with status as "Enabled".

## Next Steps

[Configure SRM](../007-AVS-SRM/readme.md)
