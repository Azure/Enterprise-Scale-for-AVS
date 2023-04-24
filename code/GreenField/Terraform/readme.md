# Terraform Implementation

This folder contains all the modules required to run the AVS Greenfield deployment. As per the ARM and Bicep implementations, the following resources are deployed:

- AVS Private Cloud
- Azure Virtual Network
- Jumpbox
- Bastion
- Virtual Network Gateway

Note: The HCX and SRM addons are not supported via Terraform at this time, once this is made available we will add this in as optional features. In the meantime, these will need to be enabled post deployment via the other supported methods (Portal, PowerShell, CLI, Bicep, ARM)

## Terraform Module Structure

The AVS Terraform modules are all written as individual modules each having a specific function. This is to improve readability and ease of customization if required. Variables have been created in all modules for consistency, all changes to defaults are to be changed from the terraform.tfvars file. The structure is as follows:

| Module Name         | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| main.tf             | This module contains the Terraform provider settings and version. It also contains some optional settings to setup a Terraform backend in an Azure Storage account |
| resourcegroups.tf   | This module deploys the 3 resource groups to be used         |
| privatecloud.tf     | This module creates the AVS Private Cloud, the passwords are set at creation time by the random_password function |
| network.tf          | This module creates the Virtual Network and subnets to be used |
| gateway.tf          | This module creates a virtual network gateway in the Gateway Subnet |
| vnetgwconnection.tf | This module creates the ExpressRoute connection between AVS and Virtual network created above, using the virtual network gateway |
| bastion.tf          | This module created the Bastion host to be used              |
| jumpbox.tf          | This will created the jumpbox in the virtual network. The Windows image is hardcoded and can be changed here if required |
| variables.tf        | Variables have been created in all modules for various properties and names, these are placeholders and are not required to be changed unless there is a need to. See below |
| terraform.tfvars    | This file contains all variables to be changed from the defaults, you are only required to change these as per your requirements |



# Deployment Steps

1. Clone this repository onto either the Azure Cloud Shell or your local machine *(Prerequisite: Ensure Terraform is installed on your local machine and setup prior to next steps)*
2. Modify the `terraform.tfvars` file to define the desired names, location, networking, and other variables
3. Before deploying, confirm the correct subscription is selected using the following command:

```
az account show
```

4. Change directory to the Terraform folder

```
cd .\Enterprise-Scale-for-AVS-Fork\AVS-Landing-Zone\GreenField\Terraform\
```

1. Run `terraform init` to initialize this directory
2. Run `terraform plan` to view the planned deployment
3. Run `terraform apply` to confirm the deployment

# Confirming Deployment

Private cloud deployment takes around 3-4 hours. Once the deployment has completed it is important to check that the deployment succeeded & the AVS Private Cloud status is "Succeeded". If the Private Cloud fails to deploy, you may need to [raise a support ticket](https://docs.microsoft.com/en-us/azure/azure-vmware/fix-deployment-failures).