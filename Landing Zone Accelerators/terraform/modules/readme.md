# Terraform Implementation

This folder contains Terraform modules which are used as building blocks for more complex scenario and sample modules. Each module contains sensible defaults for use in AVS related deployments in support of AVS Landing Zone aligned configurations. AVS Landing Zone concepts can be explored in more detail via the [official documentation page](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/azure-vmware/ready). 

## Terraform Folder Structure

This folder contains subfolders for each building block module.  A summary of the modules follows.

| Folder Name         | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| [avs_azure_firewall_internet_outbound_rules](./avs_azure_firewall_internet_outbound_rules/)  | This module creates firewall rules allowing outbound access for testing. |
| [avs_azure_firewall_w_log_analytics](./avs_azure_firewall_w_log_analytics/) | This modules creates an azure firewall, default firewall policy, and log analytics workspace for the firewall logs. |
| [avs_bastion_simple](./avs_bastion_simple/) | This module deploys a basic bastion implementation for use in accessing a jump VM for connectivity validation and testing. |
| [avs_deploy_vmware_modules_with_tf_vm](./avs_deploy_vmware_modules_with_tf_vm/) | This module deploys an ubuntu 18.04 linux vm and automatically downloads and executes a terraform module from Github on a target AVS private cloud.  This is useful for incorporating AVS NSX and Vsphere tasks in larger Terraform modules. See the module readme for specific details.
| [avs_expressroute_gateway](./avs_expressroute_gateway/) | This module deploys an expressroute gateway in a hub vnet and configures an expressroute connection to an AVS private cloud. |
| [avs_jumpbox](./avs_jumpbox/) | This module deploys a jump vm for testing.  It generates a random password and stores it in the deployment keyvault for login purposes. |
| [avs_key_vault](./avs_key_vault/) | This modules deploys a key vault for storage of any secrets in the deployment.  It also creates an access policy for the deployment principal. |
| [avs_nva_cisco_1000v_vpn_config_one_node](./avs_nva_cisco_1000v_vpn_config_one_node/) | This is a test module which deploys an unlicensed Cisco CSR with a VPN config for VPN testing. |
| [avs_private_cloud_single_management_cluster_no_internet_conn](./avs_private_cloud_single_management_cluster_no_internet_conn/) | This module deploys an AVS private cloud and an expressroute authorization key. It does not include the internet connectivity option|
| [avs_routeserver](./avs_routeserver/) | This module deploys an Azure Route Server resource and configures Branch-to-Branch connectivity to be enabled. | 
| [avs_service_health](./avs_service_health/) | This module deploys the default service health alerts and dashboards for AVS. |
| [avs_test_quad_0_nva_frr](./avs_test_quad_0_nva_frr/) | This module deploys a CentOS linux VM and configures it to run Free Range Routing configured to advertise a 0.0.0.0/0 route via BGP using the provided ASN number redirecting traffic to a target IP.  This can be used in combination with Azure firewall to mimic deploy a BGP enabled security appliance in a Vnet Hub. |
| [avs_test_spoke_with_jump_vm](./avs_test_spoke_with_jump_vm/) | This module is a composite module that combines bastion and jumpbox modules from this folder, deploys them into a new spoke vnet and creates a peering relationship between the spoke and a hub. |
| [avs_test_vpn_nva_one_node](./avs_test_vpn_nva_one_node/) | This module is a composite module that combines the Cisco CSR, bastion, keyvault, and jumpbox modules as well as creating new route table and route resources in a new VNet for mimicing an on-prem implementation. |
| [avs_vnet_variable_subnets](./avs_vnet_variable_subnets/) | This module creates a new Vnet resource with a subnets configured from an input map. |
| [avs_vmware_composite_create_vm_and_network_segment](./avs_vmware_composite_create_vm_and_network_segment/) | This module creates a new DHCP enabled T1 Gateway and network Segment in NSX and then deploys a new content library, downloads the photon image, and deploys a VM using that image. It calls several of the VMware modules below. |
| [avs_vmware_create_new_segment_w_dhcp](./avs_vmware_create_new_segment_w_dhcp/) | This module creates a new DHCP enabled Network segment in NSX and attaches it to a T1 gateway. |
| [avs_vmware_create_new_t1_gateway_w_dhcp](./avs_vmware_create_new_t1_gateway_w_dhcp/) | This module creates a new DHCP enabled T1 gateway in NSX the default T0 gateway. |
| [avs_vmware_create_test_vm](./avs_vmware_create_test_vm/) | This module creates a new content library, imports the Photon OVF, and deploys a new test virtual machine using that OVF. |
| [avs_vpn_create_local_gateways_and_connections_active_active_w_bgp](./avs_vpn_create_local_gateways_and_connections_active_active_w_bgp/) | This module currently builds the connections for a VPN hub to the cisco CSR test environment. It currently only hosts a single connection, but can be updated to be active-active in the future. |
| [avs_vpn_gateway](./avs_vpn_gateway/) | This module deploys a VPN gateway configured to be active/active with an ASN of 65515. |
| [avs_vwan](./avs_vwan/) | This module deploys a new VWAN resource or retrieves data for an existing VWAN resource. |
| [avs_vwan_azure_firewall_w_policy_and_log_analytics](./avs_vwan_azure_firewall_w_policy_and_log_analytics/) | This module deploys a VWAN based Azure Firewall, default firewall policy, and log analytics workspace for the firewall logs. |
| [avs_vwan_hub_express_route_gateway_and_vpn_gateway](./avs_vwan_hub_express_route_gateway_and_vpn_gateway/) | This modules deploys a VWAN Hub with expressRoute and VPN gateways. It configures the default route table if required for a secure hub. |
| [avs_vwan_vnet_spoke](./avs_vwan_vnet_spoke/) | This module deploys a spoke vnet and subnets using an input map.  It then creates a VWAN hub connection for the spoke. |



# Deployment Steps

Individual modules within this directory can be used to create elements of an AVS configuration. If you want to deploy these individually, then you can copy the module folder into your implementation or deploy it directly using the provided .tfvars samples.

1. Clone this repository onto the machine that will be used for development. *(Prerequisite: Ensure Terraform is installed and setup on your build machine prior to completing the next steps.  It is not recommended to use cloud shell for AVS deployments as they are long running and the cloud shell may timeout prior to completion requiring the use of terraform import to sync the remote state.)* 
2. Modify the values in the `*.tfvars.sample` file to values for your deployment when using this module as a root module. 
3. If using a module in a custom module you can also copy the modules being used into that modules Terraform implementation.
4. Before deploying, confirm the correct subscription is selected using the following command:

```
az account show
```

5. Change directory to the root Terraform module folder for your deployement


1. Run `terraform init` to initialize this directory
2. Run `terraform plan` to view the planned deployment
3. Run `terraform apply` to confirm the deployment

# Confirming Deployment

Private cloud deployment takes around 3-4 hours. Once the deployment has completed it is important to check that the deployment succeeded & the AVS Private Cloud status is "Succeeded". If the Private Cloud fails to deploy, you may need to [raise a support ticket](https://docs.microsoft.com/en-us/azure/azure-vmware/fix-deployment-failures).