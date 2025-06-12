# Deploy a JumpBox for connecting with Azure VMware Solution SDDC

After an Azure VMware Solution SDDC is deployed, very often a secure workstation is needed to access it. Guidance provided below helps to set up such a secure workstation or jumpbox.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FAddons%2FJumpbox%2Fazuredeploy.json)

## Introduction

The AVS JumpBox deployment creates a secure Windows virtual machine with the necessary networking components to connect to and manage your Azure VMware Solution (AVS) Private Cloud. This deployment uses [**Azure Verified Modules (AVM)**](https://azure.github.io/Azure-Verified-Modules/) for improved maintainability and best practices.

### What's Included:

* **Windows Server 2019 VM** with Standard_B4ms size (4 vCPUs, 16GB memory)
* **100GB data disk** for additional storage
* **System-assigned Managed Identity** for secure access to Azure resources
* **Auto-shutdown at 6PM UTC** daily to save costs
* **Virtual network** with VM, Bastion, and Gateway subnets
* **Azure Bastion (Standard SKU)** for secure access to the VM (no public IP on the VM)
* **ExpressRoute Gateway (Standard SKU)** for high-performance connectivity
* **ExpressRoute Connection** for connecting to AVS Private Cloud
* **Network Security Group** with RDP access rules

## Prerequisites

Before you begin, you need:

* An Azure subscription with `Contributor` or higher permissions on the resource group that hosts AVS SDDC
* Azure VMware Solution (AVS) Private Cloud
* AVS ExpressRoute circuit ID and Authorization/Redemption key
* For Bicep deployment: Azure CLI with Bicep extension installed (v0.28.1 or higher) or Azure PowerShell module (Az) version 5.6.0 or higher

## Template Information

This deployment uses **Azure Verified Modules (AVM)** for enhanced reliability:

| Component | AVM Module | Version |
|-----------|------------|---------|
| Virtual Network | `avm/res/network/virtual-network` | 0.7.0 |
| Virtual Machine | `avm/res/compute/virtual-machine` | 0.15.0 |
| Public IP Address | `avm/res/network/public-ip-address` | 0.8.0 |
| Network Security Group | `avm/res/network/network-security-group` | 0.5.1 |
| Bastion Host | `avm/res/network/bastion-host` | 0.6.1 |
| Virtual Network Gateway | `avm/res/network/virtual-network-gateway` | 0.4.0 |
| Connection | `avm/res/network/connection` | 0.1.0 |

## Deployment Steps

1. Update the key parameter values in `main.parameters.json` file:
   * **Network addresses**: Replace all `x.y.z.` placeholders with your actual network ranges:
     - `vnetAddressPrefix`: Replace `x.y.z.0/24` with your VNet address space (e.g., `10.1.0.0/24`)
     - `vmSubnetPrefix`: Replace `x.y.z.0/27` with your VM subnet (e.g., `10.1.0.0/27`)
     - `bastionSubnetPrefix`: Replace `x.y.z.32/27` with your Bastion subnet (e.g., `10.1.0.32/27`)
     - `gatewaySubnetPrefix`: Replace `x.y.z.64/27` with your Gateway subnet (e.g., `10.1.0.64/27`)
   * **Admin username**: Replace `<CHANGE-ME>` with your desired admin username
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

# Preview changes with What-If (recommended)
az deployment group what-if -g "YourExistingResourceGroup" --template-file main.bicep --parameters "@main.parameters.json"

# Method 1: Deploy with password prompt (most secure)
echo "You will be prompted for the jumpbox admin password..."
read -s -p "Enter jumpbox admin password: " JUMPBOX_PASSWORD
az deployment group create -g "YourExistingResourceGroup" -n JumpboxDeployment -f ./main.bicep -p "@main.parameters.json" --parameters jumpboxAdminPassword="$JUMPBOX_PASSWORD" -c

# Method 2: Deploy using compiled ARM template with prompt
read -s -p "Enter jumpbox admin password: " JUMPBOX_PASSWORD
az deployment group create -g "YourExistingResourceGroup" -n JumpboxDeployment -f ./main.json -p "@main.parameters.json" --parameters jumpboxAdminPassword="$JUMPBOX_PASSWORD" -c

# Method 3: Deploy with inline password (less secure - for testing only)
az deployment group create -g "YourExistingResourceGroup" -n JumpboxDeployment -f ./main.bicep -p "@main.parameters.json" --parameters jumpboxAdminPassword="YourComplexPassword123!" -c
```

**Using PowerShell:**
```powershell
# Login to Azure with specific tenant
Connect-AzAccount -Tenant "YourTenantId.onmicrosoft.com"

# Set the subscription context
Set-AzContext -Subscription "YourSubscriptionNameOrId"

# Preview changes with What-If (recommended)
New-AzResourceGroupDeployment -ResourceGroupName "YourExistingResourceGroup" -TemplateFile "main.bicep" -TemplateParameterFile "main.parameters.json" -WhatIf

# Method 1: Deploy with secure password prompt (most secure)
$securePassword = Read-Host -AsSecureString -Prompt "Enter jumpbox admin password"
New-AzResourceGroupDeployment -ResourceGroupName "YourExistingResourceGroup" -Name "JumpboxDeployment" -TemplateFile "main.bicep" -TemplateParameterFile "main.parameters.json" -jumpboxAdminPassword $securePassword

# Method 2: Deploy with inline secure string conversion (for automation)
New-AzResourceGroupDeployment -ResourceGroupName "YourExistingResourceGroup" -Name "JumpboxDeployment" -TemplateFile "main.bicep" -TemplateParameterFile "main.parameters.json" -jumpboxAdminPassword (ConvertTo-SecureString -String "YourComplexPassword123!" -AsPlainText -Force)

# Method 3: Deploy using compiled ARM template
New-AzResourceGroupDeployment -ResourceGroupName "YourExistingResourceGroup" -Name "JumpboxDeployment" -TemplateFile "main.json" -TemplateParameterFile "main.parameters.json" -jumpboxAdminPassword (ConvertTo-SecureString -String "YourComplexPassword123!" -AsPlainText -Force)
```

The deployment may take approximately 20-30 minutes to complete.

## What Gets Deployed

The template creates the following resources using Azure Verified Modules:

| Resource Type | Resource Name | Purpose |
|---------------|---------------|---------|
| Virtual Network | `{vnetName}` | Network infrastructure with 3 subnets |
| Virtual Machine | `{vmName}` | Windows Server 2019 jumpbox |
| Public IP Address | `{vnetName}-bastion-pip` | Static IP for Bastion |
| Network Security Group | `{vmName}-nsg` | Security rules for VM access |
| Bastion Host | `{vnetName}-bastion` | Secure remote access |
| Virtual Network Gateway | `{vnetName}-ergw` | ExpressRoute connectivity |
| Connection | `{vnetName}-er-connection` | AVS ExpressRoute connection |
| Auto-shutdown Schedule | `shutdown-computevm-{vmName}` | Cost optimization |

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

* **Configure HCX**: [Configure HCX on an existing Azure VMware Solution Private Cloud](../../Addons/HCX/readme.md)
* **Monitor your deployment**: The VM includes system-assigned managed identity for Azure monitoring integration
* **Cost optimization**: Auto-shutdown is configured for 6PM UTC daily - adjust the schedule in Azure portal if needed
* **Network connectivity**: Verify ExpressRoute connection status in the Azure portal under Virtual Network Gateway

**Support:**
For issues with Azure Verified Modules, check the [AVM GitHub repository](https://github.com/Azure/bicep-registry-modules)

