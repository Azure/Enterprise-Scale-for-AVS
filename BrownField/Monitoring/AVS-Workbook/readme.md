# Configure Workbook

It is crucial to monitor the resource utilization in order to understand what is happening within your Private Cloud. This scenario gives you a basic dashboard template to monitor CPU, Memory, and Disk utilization within a specified Private Cloud.

## Note Preview Features

**Some features of this workbook (Resources and Virtual Machines Tab) require the Azure Arc Enabled VMware feature which is currently in preview and only available in East US and West Europe**

## Prerequisites

* AVS Private Cloud up and running.

## Deployment Steps

* Enable metric and log collection for your AVS Private Cloud

* Enable Azure activity log collection from your AVS Private Cloud to Log Analytics

* Enable SysLog collection from your AVS Private Cloud to Log Analytics

* Run the following script

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-Monitoring-Workbook -c -f "AVSWorkbook.deploy.json"
```

## Post-deployment Steps

* Navigate to the Azure Monitor Workbooks blade page in the Azure Portal. The workbook should appear under recently modified workbooks.

## Next Steps

[Configure Alerts](../AVS-Utilization-Alerts/)
[AVS Quota for a single region](../AVS-Workbook/avsquotaSingleRegion.md)
[AVS Quota for multiple regions](../AVS-Workbook/avsquotaMultiRegion.md)

## Screenshots

Summary View
![image](https://user-images.githubusercontent.com/50588165/186952640-4083c8c9-ef10-4147-ab0e-6e62716afbc2.png)

VM View
![image](https://user-images.githubusercontent.com/50588165/186345524-8db1a634-856f-4d8a-98a7-23641ab5ca7e.png)
