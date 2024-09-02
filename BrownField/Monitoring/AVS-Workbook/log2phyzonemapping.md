# Know logical to pyisical zone mapping for Azure VMware Solution Private Cloud

In some scenarios, such as deploying Azure NetApp Files (ANF) or Pure Block Cloud Store for Azure VMware Solution, it is essential that Azure VMware Solution private cloud and those services are deployed in same *physical* availability zone. This script helps to provide a simple output to customers to view logical to physical zone mapping associated with their Azure VMware Solution private cloud subscription. This information can then be used to ensure that Azure services are deployed in same *physical* zone as that of Azure VMware Solution private cloud as appropriate.

## Prerequisites

* Azure subscription to be used for private cloud depployment or already running private cloud.

## Deployment Steps

* Run following script.

### CLI

```bash
az account set -s <YOUR-SUBSCRIPTION-ID>

cd CLI

./log2phy.sh

# to run the script for a specific subscription, use following commands
./log2phy.sh [subscription-id]
```

### Azure Cloud Shell

* Login to shell.azure.com. Start a bash shell.

* Copy the contents from log2phy.sh file and paste it into shell window. Hit enter.

* Script starts to run for each region.

* When finished, Logical to physical zone mapping is shown for each location associated with subscription.

## Post-deployment Steps

* Use the logical to physical zone mapping information for deployment of other Azure services in same availability zone as Azure VMware SOlution private cloud as appropriate.

## Next Steps

[Configure Workbook](../AVS-Workbook/readme.md)
