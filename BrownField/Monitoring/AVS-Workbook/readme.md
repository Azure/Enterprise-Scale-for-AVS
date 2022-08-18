# Configure Workbook

It is crucial to monitor the resource utilization in order to understand what is happening within your Private Cloud. This scenario gives you a basic dashboard template to monitor CPU, Memory, and Disk utilization within a specified Private Cloud.

## Prerequisites

* AVS Private Cloud up and running.

* (Optional) An Express Route Gateway

## Deployment Steps

* Enable metric and log collection for AVS

* Enable Azure actity log collection to Log Analytics

* Run one of the following scripts.

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-Monitoring-Workbook -c -f "AVSWorkbook.deploy.json"
```

## Post-deployment Steps

* Navigate to the Azure Monitor Workbooks blade page in the Azure Portal. The workbook should appear under recently modified workbooks.

## Next Steps

[Configure Alerts](../AVS-Utilization-Alerts/)
