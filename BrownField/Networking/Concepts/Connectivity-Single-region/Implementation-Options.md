# Connectivity Options for Azure VMware Solution

Enterprise-scale for Azure VMware Solution is a consistent set of design considerations for establishing connectivity to, from, and within the software defined data center. This page covers reference architectures based upon the most common scenarios to consider when designing for network-at-scale. While this is not an exhaustive list of design patterns, the diagrams are examples on how to achieve commonly used traffic patterns. Take advantage of the best practices described in landing zone connectivity design area to build a strong topology. You can then extend the foundation by implementing processes related to network security, and traffic monitoring.

The following decision tree shows the various options for landing on a network topology.  
 
![flow.png](./images/flow.png)

**Start with the Azure VMware Solution Azure landing zone accelerator:** If your business requirements call for a rich initial implementation of landing zones with fully integrated governance, security, and operations from the start. If you need to, you can modify using Infrastructure-as-Code (IaC) to set up and configure an environment per your requirements. For IaC, your organization will require skills in Azure Resource Manager templates and GitHub.

[!CAUTION]
The best practices used for customizing will ultimately be aligned with the [Azure landing zone](./index.md). However, there's added investment in time and effort which might be justified to fit specific business requirements.

# Implementation Options 

## Azure VMware Solution Connectivity Options 
Below is an automated method to establish connectivity

| Deploy                                                       | Description                                                  | Deploy                                                       | More Info                                                    |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Connect Azure VMware Solution to a new virtual network                         | This example will create a new virtual network, new gateway in desired resource group and will connect this new network to Azure VMware Solution private cloud |[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FNetworking%2FAVS-to-VNet-NewVNet%2FARM%2FVNetWithExR.deploy.json) | [Link](Networking/AVS-to-VNet-NewVNet/readme.md) 


For additional options to connect to an existing Azure environment, see the full list of implementation options [here](https://github.com/Azure/Enterprise-Scale-for-AVS/blob/main/BrownField/readme.md)

## Reference Architectures (Non-functional - Links In Progress) ### 
| Quick Deploy                                                       | Description                                                  | Deploy                                                       | How To Guides                                                    |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
 | Azure VMware Solution Landing Zone - Secured vWAN Hub in Azure   | Transitivity from Azure VMware Solution to on-premises via Global Reach. Default route advertisement from Secured vWAN Hub with Azure Firewall | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://github.com/sblair01/Enterprise-Scale-for-AVS/tree/main/terraform/scenarios/avs_greenfield_new_vwan_secure_hub_with_vpn_and_expressroute) | [Link](../../Step-By-Step-Guides/Scenario-1/readme.md) | Azure VMware Solution Landing Zone - Hub & Spoke in Azure with Global Reach                          | This example connects Azure VMware Solution to on-premises with Global Reach, and creates a Hub network with  a VNET Gateway and Azure Bastion. Default Route advertisement from Azure VMware Solution.  |[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FNetworking%2FAVS-to-VNet-NewVNet%2FARM%2FVNetWithExR.deploy.json) | [Link](Networking/AVS-to-VNet-NewVNet/readme.md) 
| Azure VMware Solution Landing Zone - Hub & Spoke in Azure with VPN transitivity| This example will connect Azure VMware Solution private cloud to on-premises by connecting Azure VMware Solution ExpressRoute Gateway to on-premises VPN with Azure Route Server. Enables connectivity from Azure VMware Solution | [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FBrownField%2FNetworking%2FAVS-to-OnPremises-ExpressRoute-GlobalReach%2FARM%2FAVSGlobalReach.deploy.json) | [Link](Networking/AVS-to-OnPremises-ExpressRoute-GlobalReach/readme.md) |

## Additional Traffic Patterns
### Default Route Advertisement in Azure

If you have an existing firewall in Azure, this can be used to advertise the default route from Azure VMware Solution as long as it's
- BGP capable 
- Is peered to Azure Route Server

In this configuration, user is responsible for configuring high availability and resiliency around the device. For more information on this use case see [here](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-network-topology-connectivity#scenario-5-a-third-party-nva-in-the-hub-vnet-inspects-traffic-between-avs-and-the-internet-and-between-avs-and-azure-vnets)

Note: If you are in a region where Global Reach is unavailable, consider using a multi-vnet hub and transit implmenentation https://learn.microsoft.com/en-us/azure/azure-vmware/concepts-network-design-considerations#use-a-default-route-to-azure-vmware-solution-for-internet-traffic-inspection or [Route Intent](https://learn.microsoft.com/en-us/azure/virtual-wan/how-to-routing-policies)(Preview) policies in Azure VWAN

### Default Route Advertisement in Azure VMware Solution using 3rd party firewall (Not supported)
Third party firewall usage is possible in Azure VMware Solution, must be used with discretion:
- Firewall insertion can only occur at the tier 1 router. If you need to filter traffic East / West, 
- User is responsible for managing resiliency for each firewall 
 
The solution is not supported when used with Layer 2 Extension or Mobility Optimized Networking (MON) our using Gateway Firewall in AVS. 

For traffic filtering between on-premises and AVS, consider advertising the default route on-prem

### Azure VMware Solution to Azure VMware Solution communication
- Azure VMware Solution workloads on the same segment can talk natively to each other.
- Azure VMware Solution workloads across segments communicate by configuring NSX-T Data Center.
- Workloads in different SDDC's can talk using AnyConnect.
- For workload cross-region communication, use Global Reach. 
 
 For next steps on how to implement multi-regional connectivity, see [Multi-Region Connectivity](../Connectivity-Multi-region/dual-region-hub-spoke.md).
