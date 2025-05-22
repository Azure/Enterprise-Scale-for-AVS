# Deploy a JumpBox for connecting with Azure VMware Solution SDDC

After an Azure VMware Solution SDDC is deployed, very often a secure workstation is needed to access it. Guidance provided below helps to set up such a secure workstation or jumpbox.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FAddons%2FJumpbox%2Fazuredeploy.json)

## Introduction

The AVS JumpBox deployment creates a secure Windows virtual machine with the necessary networking components to connect to and manage your Azure VMware Solution (AVS) Private Cloud. This deployment includes:

* A Windows Server VM with 4 vCPUs and 8GB memory (B-series burstable VM)
* Auto-shutdown at 7PM UTC daily to save costs
* Virtual network with VM, Bastion, and Gateway subnets
* Azure Bastion for secure access to the VM (no public IP on the VM)
* ExpressRoute Gateway for connecting to AVS Private Cloud

## Prerequisites

Before you begin, you need:

* An Azure subscription with `Contributor` or `Owner` permissions on the resource group that hosts AVS SDDC
* Azure VMware Solution (AVS) Private Cloud
* AVS ExpressRoute circuit ID and Authorization/Redemption key
* For Bicep deployment: Azure CLI with Bicep extension installed or Azure PowerShell module (Az) version 5.6.0 or higher

## Deployment Steps

1. Update the key parameter values in `main.parameters.json` file:
   * `jumpboxAdminPassword` (will be prompted during deployment if not provided)
   * `expressRouteCircuitId` and `expressRouteAuthKey` for AVS SDDC (needed for AVS connectivity)

2. Choose one of the following deployment methods:

**Using Azure Portal:**
   * Click the "Deploy to Azure" button at the top of this README
   * Enter the required parameters
   * Review and create the deployment

**Using Azure CLI:**
```azurecli-interactive
# Login to Azure with specific tenant
az login --tenant "YourTenantId.onmicrosoft.com"

# Set the subscription context
az account set --subscription "YourSubscriptionNameOrId"

# Deploy using Bicep to your existing resource group that hosts AVS SDDC
az deployment group create -g "YourExistingResourceGroup" -n JumpboxDeployment -f ./main.bicep -p "@main.parameters.json" -c

# Or deploy using ARM template
az deployment group create -g "YourExistingResourceGroup" -n JumpboxDeployment -f ./azuredeploy.json -p "@main.parameters.json" -c
```

**Using PowerShell:**
```powershell
# Login to Azure with specific tenant
Connect-AzAccount -Tenant "YourTenantId.onmicrosoft.com"

# Set the subscription context
Set-AzContext -Subscription "YourSubscriptionNameOrId"

# Deploy using Bicep to your existing resource group that hosts AVS SDDC
New-AzResourceGroupDeployment -ResourceGroupName "YourExistingResourceGroup" -Name "JumpboxDeployment" -TemplateFile "main.bicep" -TemplateParameterFile "main.parameters.json" -jumpboxAdminPassword (ConvertTo-SecureString -String "YourComplexPassword123!" -AsPlainText -Force)

# Or deploy using ARM template
New-AzResourceGroupDeployment -ResourceGroupName "YourExistingResourceGroup" -Name "JumpboxDeployment" -TemplateFile "azuredeploy.json" -TemplateParameterFile "main.parameters.json" -jumpboxAdminPassword (ConvertTo-SecureString -String "YourComplexPassword123!" -AsPlainText -Force)
```

The deployment may take approximately 20-30 minutes to complete.

## Post-deployment Steps

1. Verify the deployment status is "Succeeded" in the Azure Portal
2. Access the VM via Azure Bastion in the Azure portal:
   - Navigate to the jumpbox VM in the Azure Portal
   - Click on "Connect" and select "Bastion"
   - Enter the admin credentials you configured during deployment
3. Optional - Initialize and format the 100GB data disk:
   - Open Disk Management in the VM
   - Initialize the disk and create a new volume
4. For AVS connectivity:
   - Open the browser on jumpbox
   - Copy the vCenter Web Client URL from AVS --> VMware Credentials
   - Hit enter

## Next Steps

After successfully deploying and configuring your AVS jumpbox, you can:

[Configure HCX on an existing Azure VMware Solution Private Cloud](../../Addons/HCX/readme.md)

