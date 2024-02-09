# Know your Azure VMware Solution Private Cloud quota for any region

Very often, it is needed to know Azure VMware Solution SDDC quota. This is typically needed for capacity planning or DR planning activities. This workbook shows Azure VMware Solution SDDC quota for selected subscription and selected region. Quota is shown for multiple SKU types (e.g. AV36P, AV52, AV64, etc.).

## Prerequisites

* AVS Private Cloud up and running.

## Deployment Steps

* Run following script.

### ARM

```bash
cd ARM

az deployment group create -g <YOUR-RESOURCE-GROUP> -n <DEPLOYMENT-NAME> -c -f "AVSQuotaWorkbook.deploy.json"
```

## Post-deployment Steps

* Navigate to Azure Monitor in Azure Portal. Click "Workbooks" from left hand menu. On the right hand side pane, scroll to "Azure VMware Solution" section. You should see "AVS Quota Workbook". Open this workbook.

* When the workbook is opened, select the subscription from Subscription drop-down box. Select the Azure region you want to check quota for.

* Quota for that subscription and region is displayed in a table. A Map showing the region is also displayed below the table.

## Next Steps

[AVS Quota for multiple regions](../AVS-Workbook/avsquotaMultiRegion.md)
