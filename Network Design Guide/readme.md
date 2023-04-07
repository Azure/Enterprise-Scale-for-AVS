# AVS Landing Zone Accelerator Network Design Guide
This guide covers network design for Azure VMWare Solution (AVS). It encompasses four design areas, summarized below.

1. **Connectivity with on-premises datacenters**. Connectivity between AVS private clouds and on-prem sites supports a broad set of use cases, such as HCX migrations, hybrid applications, remote VSphere or NSX-T administration. AVS supports multiple options for hybrid connectivity, including Azure ExpressRoute circuits and internet-based IPSec VPNs. 

2. **Connectivity with Azure Virtual Networks**. AVS runs on bare-metal VMware VSphere clusters that can be connected to native Azure Virtual Networks (VNets) through Azure ExpressRoute. ExpressRoute connections between AVS private clouds and Azure VNET enable building applications that span the two environments or using “jump-box” virtual machines in Azure to log into VCenter Server and NSX-T Management console for administration purposes. 

3. **Inbound internet connectivity**. Inbound internet connectivity enables applications running on AVS to be exposed to the internet behind public IP addresses. Internet-facing applications are almost invariably published through security devices (application delivery controllers, web application firewalls, L3/L4 next-gen firewalls, …). Design decisions about inbound connectivity are primarily driven by the placement of such devices (in AVS or in Azure VNets). 

4. **Outbound internet connectivity**. Outbound internet connectivity is needed when applications running on AVS require access to public endpoints. Typical use cases include downloading software updates, consuming public web sites or APIs, internet browsing (for example, when AVS is used to run [VDI solutions](https://learn.microsoft.com/en-us/azure/azure-vmware/azure-vmware-solution-horizon)). AVS provides several options to implement outbound internet connectivity, which may or may not rely on Azure native resources. Security requirements (firewalling, forward proxying, …) typically drive design decisions in this area. 
AVS provides native functionalities to address the most common/basic requirements in each design area, with little or no dependence on customer-managed Azure-native resources. However, in enterprise scenarios, it is common for AVS to be part of a larger infrastructure that includes native Azure IaaS and PaaS services. In such cases, some out-of-the-box connectivity features provided AVS may be replaced by more advanced solutions based on Azure native resources, such as 1st party network services (Azure Firewall, Azure Application Gateway, …) or 3rd party NVAs.

Designing AVS network solutions is a complex endeavor. A solid understanding of [AVS networking basics](avs-networking-basics.md) is needed for an effective use of this guide.

## Design area prioritization
The four design areas are not independent of each other. Design decisions made for one area may limit the options available in other areas. It is recommended to tackle the four areas in the order they have been introduced in the previous section. 

![figure1](media/figure1.png) 
Figure 1. Design area prioritization recommended in this guide.

As shown in the flow chart of Figure 1, this guide advocates the following approach to network design for AVS.
1. Design connectivity with on-premises datacenters first. The key decisions for this area are (i) what connectivity service to leverage between on-prem sites and the edge of the Microsoft network (internet vs. Expressroute) and (ii) whether traffic should be routed directly to AVS (recommended) or through virtual devices running in Azure VNets. Read the [Design phase #1: Connectivity with on-prem sites article](onprem-connectivity.md) to learn what options AVS supports and how to choose one.

2. Identify the VNet connectivity option aligned to the design choices made in Phase #1. Determine which additional routing/security configuration may be needed in Azure VNets to incorporate requirements such as firewall inspection for traffic between AVS and Azure native VMs. Read the [Design phase #2: Azure VNet connectivity article](vnet-connectivity.md) to learn how design decisions for connectivity with on-prem sites influence the way an AVS private cloud connects to Azure VNets.

3. Decide how internet-facing applications running on AVS should be published (inbound internet connectivity). AVS allows using Azure Public IPs associated with either virtual appliances running in AVS, or virtual appliances running in an Azure VNet. Both options can be used irrespective of the decisions made for connectivity with on-prem sites and Azure VNets in Phase #1 and Phase #2. Read the [Design phase #3: Internet inbound connectivity article](internet-inbound-connectivity.md) to learn what options for inbound internet connectivity AVS supports, and how to choose one.

4. Decide how AVS workloads will connect to the internet (outbound internet connectivity). This design decision may be constrained by the choices made for outbound internet connectivity (Phase #3). If [Azure Public IPs to the NSX-T edge]() are used for inbound connectivity, then they must be used for outbound connections too. If not, more options exist. Read the [Design phase #4: Internet outbound connectivity article](internet-outbound-connectivity.md) to learn about supported options and how to choose one.

## Next Steps
- Go to the next section to learn about [AVS Networking Basics](avs-networking-basics.md).
- Go to [Design Phase #1: Connectivity with on-prem sites](onprem-connectivity.md)
- Go to [Design Phase #2: Azure VNet connectivity](vnet-connectivity.md)
- Go to [Design Phase #3: Internet inbound connectivity](internet-inbound-connectivity.md)
- Go to [Design Phase #4: Internet outbound connectivity](internet-outbound-connectivity.md)