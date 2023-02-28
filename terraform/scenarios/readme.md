# Terraform Implementation

This folder contains Terraform modules which deploy a set of AVS network and/or operational scenarios. It is expected that users will have a strong understanding of Terraform concepts and will make any necessary modifications to fit their environment when using these modules. AVS Landing Zone concepts can be explored in more detail via the [official documentation page](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/azure-vmware/ready). 

## Terraform Folder Structure

This folder contains subfolders for each scenario module.  A summary of each scenario follows.

| Folder Name         | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| [avs_brownfield_existing_vwan_hub](./avs_brownfield_existing_vwan_hub/)  | This scenario deploys an AVS private cloud and connects it to your existing VWAN hub. It also includes sample operational dashboards and alerts. |
| [avs_greenfield_new_vpn_hub](./avs_greenfield_new_vpn_hub/)  | This scenario deploys a hub Vnet with VPN and ExpressRoute virtual network gateways, and then deploys an AVS private cloud and connects it to the new hub. It also includes sample operational dashboards and alerts. |
| [avs_greenfield_new_vwan_secure_hub_with_vpn_and_expressroute](./avs_greenfield_new_vwan_secure_hub_with_vpn_and_expressroute/)     | This scenario creates a new VWAN secure hub with vpn and expressroute gateways. It includes an Azure Firewall with accompanying log analytics workspace, and implements some test firewall rules to allow connectivity to the internet. It includes a spoke Vnet containing a Jumpserver and Azure Bastion for testing connectivity. |



# Deployment Steps

1. Clone this repository onto the machine that will be used for development. *(Prerequisite: Ensure Terraform is installed and setup on your build machine prior to completing the next steps.  It is not recommended to use cloud shell for AVS deployments as they are long running and the cloud shell may timeout prior to completion requiring the use of terraform import to sync the remote state.)* 
2. Modify the `*.tfvars.sample` file to define values configured as variables within the module and remove the .sample extension if using this module as a root module. *(Note: To simplify naming, locals are used within most modules for resource name definitions and are configured to use a prefix value with a randomly generated suffix for uniqueness.  If custom naming is required then you will need to modify the locals in your module code.)*
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