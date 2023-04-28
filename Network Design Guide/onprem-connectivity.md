# Design phase #1: Connectivity with on-premises datacenters
Connectivity with on-premises datacenters is the most critical design area for Azure VMware Solution (AVS) networking. The key requirements that must be addressed are the following:
- `High throughput`: Migrations from on-premises vSphere environments and disaster recovery solutions require moving large volumes of data between on-premises sites and AVS private clouds.
- `Low latency`: Distributed applications may require low latency for connections between AVS virtual machines and on-premises systems.
- `Performance predictability`: Mission critical applications deployed on AVS may require connections to on-premises hosts to exhibit predictable throughput and latency, which can be achieved only by using dedicated connectivity services between on-premises sites and the edge of the Microsoft network (ExpressRoute).
This section describes the options supported by AVS for connectivity with on-premises sites, in order of decreasing ability to meet the key requirements listed above. An option should be discarded, and the next one considered, only if it conflicts with non-negotiable constraints that exist in a specific scenario, as shown in the flowchart below:
   
![figure6](media/figure6.png)
Figure 6. Design phase #1. How to select a hybrid connectivity option for AVS.

## ExpressRoute Global Reach
ExpressRoute Global Reach is the default hybrid connectivity option supported by AVS. It provides plain layer-3 connectivity between AVS and remote sites connected via a customer-managed ExpressRoute circuit, with minimal complexity. The customer-managed ExpressRoute circuit can be used to connect to Azure native services too. It is also possible to deploy a separate AVS circuit exclusively dedicated to AVS hybrid traffic. 
The figure below shows the network topology when Global Reach is used for hybrid connectivity.
 
![figure7](media/figure7.png)
Figure 7. Hybrid connectivity with ExpressRoute Global Reach. Traffic between AVS and on-premises sites does not transit through Azure VNets.
Detailed instructions on how to connect an AVS private cloud to a customer managed ExpressRoute circuit using Global Reach are available in [this article](https://learn.microsoft.com/azure/azure-vmware/tutorial-expressroute-global-reach-private-cloud). 

This option fully addresses the three key requirements listed above:  
- High throughput: ExpressRoute allows customers to connect to the edge of the Microsoft network from their premises over dedicated lines, and to provision the network capacity they need (up to 10 Gbps for provider-based ExpressRoute, or 100 Gbps for ExpressRoute Direct). 
- Low latency: Global Reach allows routing traffic directly from the edge of the Microsoft network to the network devices that provide access to the AVS vSphere clusters. Global Reach minimizes the number of network hops between on-premises sites and AVS private clouds.
- Predictable performance: When using ExpressRoute Global Reach, hybrid traffic is routed over links that will not experience congestion issues (up to the maximum provisioned capacity). Therefore, round-trip time (RTT) measured between AVS virtual machines and on-premises host remains constant over time.
Using Global Reach for hybrid AVS connectivity is not an option in scenarios where one or more of the following constraints apply.
  - ExpressRoute Global Reach is unavailable in the Azure region of the AVS private cloud and/or the ExpressRoute meet-me location of the customer-managed ExpressRoute circuit. This is an Azure limitation for which no workaround exists. Please refer to the [official documentation]( https://learn.microsoft.com/azure/expressroute/expressroute-global-reach#availability) for up-to-date information about Global Reach availability.
  - Non-negotiable network security requirements. If a firewall device cannot be deployed at the on-premises side of the customer-managed ExpressRoute circuit, using Global Reach exposes all AVS network segments, including management endpoints (vCenter Server and NSX-T Manager), to the entire network connected to the circuit. The most typical scenario where this constraint applies is customer-managed ExpressRoute circuits implemented on top of MPLS network services, as shown in the figure below.
 
![figure8](media/figure8.png)
Figure 8. ExpressRoute (ER) connectivity implemented on top of MPLS IPVPNs makes it impossible to deploy firewalls in a single location/facility to inspect all traffic to/from AVS (there is no customer-owned infrastructure at the ER peering location).  Typically, customers that use MPLS networks deploy firewall in large datacenters, not in all MPLS connected sites (which can be small branches/offices/stores/…).

## IPSec VPNs
If ExpressRoute Global Reach cannot be used, then connectivity between AVS private clouds and on-premises sites can be implemented by routing traffic through a “transit” VNet in Azure. The transit VNet is connected to the AVS private cloud through the AVS managed ExpressRoute circuit. As for connectivity between the transit VNet and the on-premises site, the lowest-complexity approach is using an IPSec VPN, covered in this section, and shown in the diagram below. The next section covers custom implementations for transit VNets with plain layer-3 connectivity to on-premises sites over the ExpressRoute “Private” peering.
 
![figure9](media/figure9.png)
Figure 9. The “IPSec VPN” connectivity option covered in this section. Traffic between AVS private clouds and on-premises sites is routed through a transit VNet in Azure. The transit VNet is connected to AVS through the private cloud’s managed ExpressRoute circuit and to the on-premises site through an IPSec tunnel, terminated, on the Azure side, by a VPN device hosted in the transit VNet. Different implementation options exist for the IPSec tunnel’s underlay, the VPN device and the transit VNet (including the network function that routes traffic between the VPN device and the ExpressRoute gateway.) These details are not shown in this picture.

Implementing IPSec connectivity between on-premises sites and transit VNets entails three design decisions:
1. Which connectivity service to use as the underlay for the IPSec tunnel. The available options are internet connectivity, ExpressRoute “Microsoft” peering and ExpressRoute “Private” peering.
2. Where to host the virtual devices that terminate the IPSec tunnel on the Azure side. The available options are using a customer-managed VNet or a Virtual WAN hub. 
3. Which virtual device terminates the IPSec tunnel on the Azure side. The choice of the device also determines the required Azure configuration to route traffic between the IPSec tunnel and the AVS managed circuit. The available options are native Azure VPN gateway or 3rd party IPSec NVAs, deployed in a customer-managed VNet or in a Virtual WAN hub.
The criteria that drive these design decisions are covered  next.

### IPSec tunnel underlay
This guide strongly advocates considering the three available options in the order they are presented below and moving to the next option on the list only after identifying solid technical reasons to discard the previous one.

**Internet connectivity**: With this option, an internet connection is used at the on-premises site to reach the edge of the Microsoft network and the public IP of a VPN device hosted in the transit VNet, which serves as the remote endpoint of the IPSec tunnel. Due to its low complexity and cost, internet connectivity should be always tested and assessed from a performance standpoint (achievable IPSec throughput – see the “IPSec bandwidth considerations” section below). It should be dismissed only when the observed performance is too low and/or not consistent over time.
 
![figure10](media/figure10.png)
Figure 10. Internet connection as the IPSec tunnel underlay.

**ExpressRoute “Microsoft” peering**: The ExpressRoute “Microsoft” peering provides layer-3 connectivity to public Azure endpoints over dedicated links with customer-defined bandwidth. Just like internet connections, it allows reaching the public IP of a VPN device hosted in the transit VNet, which serves as the remote endpoint of the IPSec tunnel. This option should be dismissed only when the [Microsoft peering’s routing requirements](https://learn.microsoft.com/azure/expressroute/expressroute-routing#ip-addresses-used-for-microsoft-peering) cannot be met. 
 
![figure11](media/figure11.png)
Figure 11. ExpressRoute “Microsoft” peering as the IPSec tunnel underlay.

**ExpressRoute “Private” peering**: The ExpressRoute “Private” peering provides layer-3 connectivity between an on-premises site’s network and Azure VNets over dedicated links with customer-defined bandwidth. As such, it allows establishing an IPSec tunnel from the on-premises site towards the private IP address of a VPN device hosted in the transit VNet. The ExpressRoute “Private” peering may introduce bandwidth limitations (due to the presence of the ExpressRoute Gateway in the transit VNet, which is in the data path unless [ExpressRoute FastPath]( https://learn.microsoft.com/azure/expressroute/about-fastpath) can be used) and requires more complex routing configuration on the on-premises side (see [this article]( https://learn.microsoft.com/azure/vpn-gateway/site-to-site-vpn-private-peering?toc=%2Fazure%2Fexpressroute%2Ftoc.json) for more details).
 
![figure12](media/figure12.png)
Figure 12. ExpressRoute “Private” peering as the IPSec tunnel underlay.

### Customer-managed VNet vs. Virtual WAN hub 
This design decision is driven by the characteristics of the pre-existing Azure environment (if any) and by the desired trade-off between management effort and ability to tailor the configuration to meet specific needs. As such, this guide does not advocate a preferred/recommended solution. The key considerations are listed below.
- Pre-existing Azure network infrastructure should be leveraged for AVS connectivity. If a customer-managed hub and spoke network is already present, then the IPSec termination devices should be deployed in the existing hub. If a hub and spoke network based on Virtual WAN is present, then it should be used for IPSec termination.
- In a customer-managed hub and spoke network, routing traffic between an IPSec tunnel and the ExpressRoute managed circuit requires deploying an [Azure Route Server instance]( https://learn.microsoft.com/azure/route-server/overview) in the hub VNet, configured to [allow “Branch-to-branch” traffic]( https://learn.microsoft.com/azure/route-server/expressroute-vpn-support).
- In a customer managed VNet, it is possible to customize routing so that traffic between AVS private clouds and on-premises sites can be inspected by firewall devices deployed in Azure.
- Virtual WAN hubs natively support routing traffic between the IPSec tunnel connected to the on-premises site and the AVS managed ExpressRoute circuit. No additional resources must be deployed. 
- When using Virtual WAN, inspection for traffic between AVS private clouds and on-premises sites is enabled by [Virtual WAN native features](https://learn.microsoft.com/azure/virtual-wan/how-to-routing-policies). Regional availability and limitations should be reviewed.

### IPSec termination device
The IPSec tunnel that provides connectivity to the on-premises site can be terminated by Azure VPN Gateways or by 3rd party NVAs. This design decision is driven by the characteristics of the pre-existing Azure environment (if any) and by the desired trade-off between management effort and ability to tailor the configuration to meet specific needs. As such, this guide does not advocate a preferred/recommended solution. The key considerations are listed below.

**Azure VPN Gateways**, both in customer-managed and Virtual-WAN-based hub and spoke networks, can be used to terminate IPSec tunnels connected to on-premises sites. Being platform-managed, Azure VPN Gateways require minimal management effort. Pre-existing gateways can be used even if they support other connectivity scenarios. The following documentation articles should be reviewed to understand supported settings and expected performance:
- [VPN Gateway SKUs and expected performance levels (standalone)](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#benchmark)
- [VPN Gateway cryptographic requirements (standalone)]( https://learn.microsoft.com/azure/vpn-gateway/vpn-gateway-about-compliance-crypto)
- [VPN Gateway settings (Virtual WAN)]( https://learn.microsoft.com/en-us/azure/virtual-wan/gateway-settings#s2s)
- [VPN Gateway cryptographic requirements (Virtual WAN)]( https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-ipsec) 

**Third-party NVAs** are typically used to terminate tunnels from on-premises sites in the following situations:
- The NVA is the CPE of an SDWAN solution deployed both in Azure and the on-premises site.
- The NVA is a firewall that enforces the required security policy for connections between the on-premises site and AVS.

Using third-party devices may provide more flexibility (and access to advanced network functions not supported by native VPN gateways) but increases complexit; High Availability (HA) becomes the user’s responsibility, Multiple instances should be deployed, etc.  

## Transit over ExpressRoute Private peering
ExpressRoute Private peering is the most common choice for connecting an on-premises site to an Azure VNet (or hub and spoke network) in enterprise scenarios. The Azure VNet (or the hub VNet in hub and spoke topologies) contains an ExpressRoute Gateway, configured with a connection to the ExpressRoute circuit. This setup provides layer-3 connectivity between the VNet (or the whole hub and spoke network) and the on-premises site’s network. However, it does not natively provide layer-3 connectivity to AVS private clouds connected to the same VNet (or hub VNet, in hub and spoke networks) over the AVS managed ExpressRoute circuit, as discussed in section [“What is the role played by ExpressRoute Global Reach?”](avs-networking-basics.md#what---is-the-role-played-by-expressroute).
By deploying additional routing devices in the Azure VNet, it is possible to overcome this limitation. Also, this option allows routing traffic through firewall NVAs hosted in the Azure VNet, which provides an effective way to enforce a network security policy for AVS resources and AVS management endpoints. While this approach may seem desirable, it has complexity and performance implications. It should be considered only when ExpressRoute Global Reach and IPSec VPNs (covered in the previous sections) are not applicable. Two implementation options exist:
- Single VNet. When using this option, both the customer managed and the AVS managed circuits are connected to the same ExpressRoute Gateway.
- Auxiliary transit VNet. When using this option, the customer managed ExpressRoute circuit that provides connectivity to the on-premises site is connected to the (typically pre-existing) ExpressRoute Gateway in the hub VNet. The AVS managed circuit is connected to a different ExpressRoute Gateway deployed in an auxiliary transit VNet.
The two options provide different trade-offs between performance, cost (i.e. required Azure resources) and management overhead. 
The following sections cover control plane implementation (i.e. how routes are exchanged between the on-premises site and the private cloud) and data plane implementation (i.e. how network packets are routed between the on-premises site and the private cloud)for both options.
Both options rely, for their control plane implementations, on [Azure Route Server]( https://learn.microsoft.com/azure/route-server/overview). More specifically, both options rely on Azure Route Server to propagate routes between customer managed and AVS managed ExpressRoute circuits, which ExpressRoute Gateways cannot do. Azure Route Server can propagate routes to an ExpressRoute Gateway (and in turn to ExpressRoute circuits connected to it) when the [branch-to-branch setting]( https://learn.microsoft.com/en-us/azure/route-server/expressroute-vpn-support) is enabled.

### ExpressRoute transit, single VNet
In the single VNet approach, both the AVS-managed circuit and the customer-managed circuit are connected to the same VNet, typically the hub VNet in a pre-existing hub and spoke network. Traffic between the private cloud and the on-premises site can be routed through firewall NVAs deployed in the hub VNet. The single VNet architecture is shown in the figure below.
 
![figure13](media/figure13.png)
Figure 13. The single-VNet option for ExpressRoute transit.

The control plane and the data plane are implemented as follows.
- Control plane. As the ExpressRoute Gateway deployed in the Azure VNet cannot propagate routes between the AVS managed and the customer managed ExpressRoute circuits, Azure Route Server is used to inject, in both circuits, routes for supernets that include the private cloud’s address space (management networks and workload segments) and the on-premises address space. Using supernets, instead of the exact prefixes that comprise those address spaces, is required because the exact prefixes are announced in the opposite direction (by the private cloud and the on-premises site). Supernets as large as RFC 1918 prefixes may be used if compatible with the network configuration of the on-premises sites. In most cases, the smallest supernets that include that include the private cloud’s address space and the on-premises address space should be used instead, to avoid conflicts with the network configuration of the on-premises sites. The routes for the supernets are originated by BGP-capable NVAs. The NVAs are configured to establish a BPG session with the Azure Route Server. They are only part of the control plane and do not route actual traffic between the on-premises site and the private cloud. The control plane implementation is shown by the grey lines in Figure 13 below.
- Data plane. The control plane implementation described above achieves the effect of attracting to the ExpressRoute Gateway (a) traffic from the on-premises site, destined to the AVS private cloud; and (b) traffic from the private cloud, destined to the on-premises site. If no UDR’s are applied to the GatewaySubnet, traffic flows directly between the on-premises site and the private cloud. By applying UDR’s to the GatewaySubnet, it is possible to route traffic to an intermediate next hops, such as a firewall NVAs that enforce a network security policy on connections between on-pre sites and private clouds (for example, protecting access to AVS management endpoints from the on-premises site’s network).

### ExpressRoute transit, auxiliary VNet
In this approach, an auxiliary VNet is used to host a second ExpressRoute gateway, connected to the AVS-managed circuit only. By connecting the AVS-managed circuit and the customer-managed circuit to different ExpressRoute gateways, and injecting proper routes into them via Route Server instances, it is possible to granularly control route propagation between the private cloud and the on-premises site. Announcing supernets is no longer necessary (as it is the case for the single VNet option covered in the previous section). Management overhead for UDR’s in the GatewaySubnet is also reduced. This approach allows routing traffic between the private cloud and the on-premises site through firewall NVAs in the hub VNet. The auxiliary VNet implementation option is shown in the figure below.
 
![figure14](media/figure14.png)
Figure 14. The auxiliary VNet implementation option.

The control plane and the data plane are implemented as follows.
- Control plane. To enable route propagation between the AVS-managed circuit and the customer-managed circuit, an Azure Route Server instance is needed in each VNet. As the two Azure Route Server instances cannot establish a BGP adjacency, BGP-capable NVAs are needed to propagate routes between them. At least two NVA instances should be deployed for high availability. More instances may be added to increase throughput. The BGP capable NVAs must have two NICs, attached to different subnets. BGP sessions towards the two Route Servers (in the auxiliary VNet and the hub VNet) must be established over different NICs. Routes originated by the private cloud and by the on-premises site are learned over ExpressRoute circuits: Their AS Path contains ASN 65515 (Azure-reserved ASN used by ExpressRoute Gateways) and ASN 12076 (Microsoft-owned ASN used by the MSEEs in all peering locations). The BGP-capable NVAs must manipulate the AS Path by removing them, to prevent routes from being dropped by BGP loop detection. Additional details on the required BGP configuration are provided in [this step-by-step configuration guide]( https://github.com/Azure/Enterprise-Scale-for-AVS/tree/main/BrownField/Networking/Step-By-Step-Guides/Expressroute%20connectivity%20for%20AVS%20without%20Global%20Reach). It should be noted that the 
- Data plane. In the auxiliary VNet, traffic between the private cloud and the on-premises site is routed through the BGP-capable NVAs. Traffic to/from the private cloud leaves/enters the NVAs through the NIC used for the BGP session with the auxiliary VNet’s Route Server. Traffic to/from the on-premises site leaves/enters the NVAs through the NIC used for the BGP session with the hub VNet’s Route Server. This NIC is attached to subnet associated to a custom route table that (i) disables learning BGP routes from the Route Server (to avoid loops) and (ii) inserts the hub VNet’s firewall in the datapath. To ensure that traffic is symmetrically routed via the hub firewall, UDRs for the all the prefixes used in the private cloud must be configured on the hub’s GatewaySubnet. Additional details are provided in [this step-by-step configuration guide]( https://github.com/Azure/Enterprise-Scale-for-AVS/tree/main/BrownField/Networking/Step-By-Step-Guides/Expressroute%20connectivity%20for%20AVS%20without%20Global%20Reach).


## Next Steps
- Go to the next section to learn about [connectivity between AVS and Azure Virtual Networks](vnet-connectivity.md) 
- Go back to [AVS Networking Basics](avs-networking-basics.md)
- Go back to the AVS Network Design Guide [introduction](readme.md)
