# Terraform Implementation

This folder contains Terraform modules which deploy an end-to-end sample environment. This will be used most frequently for demonstration or lab purposes. It is expected that users will have a strong understanding of Terraform concepts and will make any necessary modifications to fit their environment when using these modules. AVS Landing Zone concepts can be explored in more detail via the [official documentation page](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/azure-vmware/ready). 

## Terraform Folder Structure

This folder contains subfolders for each sample module.  A summary of each scenario follows.

| Folder Name         | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| [avs_vpn_hub_and_on_prem_csr_nva](./avs_vpn_hub_and_on_prem_csr_nva/)  | This sample deploys an AVS environment connected to a VPN hub as well as an Azure Vnet with a Cisco CSR to mimic a customer premise configuration. It then builds connections between the CSR and the VPN hub to allow for demonstrating end-to-end connectivity with a VPN hub. |


# Deployment Steps

1. Clone this repository onto the machine that will be used for development. *(Prerequisite: Ensure Terraform is installed and setup on your build machine prior to completing the next steps.  It is not recommended to use cloud shell for AVS deployments as they are long running and the cloud shell may timeout prior to completion requiring the use of terraform import to sync the remote state.)* 
2. Modify the values in the `main.tf` file to values for your deployment when using this module as a root module. *(Note: To simplify naming, locals are used within most child modules for resource name definitions and are configured to use a prefix value with a randomly generated suffix for uniqueness.  If custom naming is required then you will need to modify the locals in your module code.)*
3. If using a module in a custom module you can also copy the modules being used into that modules Terraform implementation.
4. Before deploying, confirm the correct subscription is selected using the following command:

```
az account show
```

5. Change directory to the root Terraform module folder for your deployment


1. Run `terraform init` to initialize this directory
2. Run `terraform plan` to view the planned deployment
3. Run `terraform apply` to confirm the deployment

# Confirming Deployment

Private cloud deployment takes around 3-4 hours. Once the deployment has completed it is important to check that the deployment succeeded & the AVS Private Cloud status is "Succeeded". If the Private Cloud fails to deploy, you may need to [raise a support ticket](https://docs.microsoft.com/en-us/azure/azure-vmware/fix-deployment-failures).