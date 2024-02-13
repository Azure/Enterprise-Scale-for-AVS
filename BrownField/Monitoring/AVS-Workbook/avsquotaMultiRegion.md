# Know your Azure VMware Solution Private Cloud quota for all regions

Very often, it is needed to know Azure VMware Solution SDDC quota across all regions. This is typically needed for capacity planning or DR planning activities. This script displays Azure VMware Solution SDDC quota for selected subscription and for all Azure region. Quota is shown for multiple SKU types (e.g. AV36P, AV52, AV64, etc.).

## Prerequisites

* AVS Private Cloud up and running.

## Deployment Steps

* Run following script. It may take few minutes to complete the execution. As script runs for a region, the region name is displayed in the console window.

### CLI

```bash
az account set -s <YOUR-SUBSCRIPTION-ID>

cd CLI

./deploy.sh
```

### Azure Cloud Shell

* Login to shell.azure.com. Start a bash shell.

* Copy the contents from deploy.sh file and paste it into shell window. Hit enter.

* Script starts to run for each region.

* When finished Azure VMware Solution Quota is shown for each region and for each SKU.

## Post-deployment Steps

* Copy the contents from shell and paste it into Excel for further processing.

## Next Steps

[Configure Workbook](../AVS-Workbook/readme.md)
