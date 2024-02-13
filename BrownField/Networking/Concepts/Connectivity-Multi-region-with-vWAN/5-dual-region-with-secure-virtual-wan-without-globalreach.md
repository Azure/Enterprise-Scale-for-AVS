---
title: Dual-Region Azure VMware Solution design without Global Reach, using Secure Virtual WAN with Routing-Intent
description: Learn how to configure network connectivity when Azure VMware Solution private clouds are deployed in two Azure regions with Secure Virtual WAN.
author: jasonmedina
ms.author: jasonmedina
ms.date: 11/28/2023
ms.topic: conceptual
ms.service: caf
ms.subservice: caf-scenario-vmware
ms.custom: think-tank, e2e-azure-VMware
---

# Dual-region deployments using Secure Virtual WAN Hub with Routing-Intent

This article describes the best practices for connectivity, traffic flows, and high availability of dual-region Azure VMware Solution when using Azure Secure Virtual WAN with Routing Intent. You will learn the design details of using Secure Virtual WAN with Routing-Intent, without Global Reach. This article breaks down Virtual WAN with Routing Intent topology from the perspective of Azure VMware Solution private clouds, on-premises sites, and Azure native. The implementation and configuration of Secure Virtual WAN with Routing Intent are beyond the scope and are not discussed in this document.

In regions without Global Reach support or with a security requirement to inspect traffic between Azure VMware Solution and on-premises at the hub firewall, a support ticket must be opened to enable ExpressRoute to ExpressRoute transitivity. ExpressRoute to ExpressRoute transitivity isn't supported by default with Secure Virtual WAN. - see [Transit connectivity between ExpressRoute circuits with routing intent](/azure/virtual-wan/how-to-routing-policies#expressroute)

>[!NOTE]
>  When configuring Azure VMware Solution with Secure Virtual WAN Hubs, ensure optimal routing results on the hub by setting the Hub Routing Preference option to "AS Path." - see [Virtual hub routing preference](/azure/virtual-wan/about-virtual-hub-routing-preference)
> 
  
## Dual-region with Secure Virtual WAN scenario  
Secure Virtual WAN with Routing Intent is only supported with Virtual WAN Standard SKU. Secure Virtual WAN with Routing Intent provides the capability to send all Internet traffic and Private network traffic (RFC 1918) to a security solution like Azure Firewall, a third-party Network Virtual Appliance (NVA), or SaaS solution. In the scenario, we have a network topology that spans two regions. There is one Virtual WAN with two Hubs, Hub1 and Hub2. Hub1 is in Region 1, and Hub2 is in Region 2. Each Hub has its own instance of Azure Firewall deployed(Hub1Fw, Hub2Fw), essentially making them each Secure Virtual WAN Hubs. Having Secure Virtual WAN hubs is a technical prerequisite to Routing Intent. Secure Virtual WAN Hub1 and Hub2 have Routing Intent enabled.    

Each region has its own Azure VMware Solution Private Cloud and an Azure Virtual Network. There is also an on-premises site connecting to both regions, which we review in more detail later in this document.  
![Diagram of Dual-Region Azure VMware Solution Scenario](./media/dual-region-virtual-wan-without-globalreach-1.png)

### Understanding Topology Connectivity 

| Connection | Description  |
|:-------------------- |:--------------------  |
| Connections (E) | Azure VMware Solution private cloud managed ExpressRoute connection to its local regional hub.  |
| Connections (D) | Azure VMware Solution private cloud managed ExpressRoute connection to its cross-regional hub.  |
| Connections (F) | on-premises ExpressRoute connections to both regional hubs.  |
| Inter-Hub Connection | When two hubs are deployed under the same Virtual WAN  |

## Dual-region Secure Virtual WAN Traffic Flows

The following sections cover traffic flows and connectivity for Azure VMware Solution, on-premises, Azure Virtual Networks, and the Internet.

### Azure VMware Solution cross-region connectivity & traffic flows

This section focuses on only the Azure VMware Solution Cloud Region 1 and Azure VMware Solution Cloud Region 2. Each Azure VMware Solution private cloud has an ExpressRoute connection to its local regional hub (connections labeled as "E") and an ExpressRoute connection to the cross-regional hub (connections, labeled as "D").

 Each Azure VMware Solution private cloud communicates back to on-premises through their local regional Hub firewall via Connection "E". The traffic flows over the Azure VMware Solution Managed ExpressRoute (Connection “E”) and the on-premises ExpressRoute (Connection “F”), both of which pass through the local regional Hub firewall. 

  Each Azure VMware Solution private cloud communicates back to on-premises through their local regional Hub firewall via Connection "E". The traffic flows over the Azure VMware Solution Managed ExpressRoute (Connection “E”) and the on-premises ExpressRoute (Connection “F”), both of which pass through the local regional Hub firewall. 
  
 With ExpressRoute to ExpressRoute transitivity enabled on the Secure Hub and Routing-Intent enabled, the Secure Hub sends the default RFC 1918 addresses (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to both the on-premises and the Azure VMware Solution. The diagram below shows that the Azure VMware Solution only learns the specific routes from Azure and the default RFC 1918 addresses from the Secure Hub. However, the Azure VMware Solution does not learn the specific routes from the on-premises network. It relies on the default RFC 1918 addresses to route back to the on-premises network through the Hub firewall. The Hub firewall has the specific routes for the on-premises networks and routes traffic toward the destination over Connection “F”. For more information, see the traffic flow section for more detailed information.

The diagram depicts how each Azure VMware Solution Cloud learns routes from their local and cross-regional hubs.

![Diagram of Dual-Region Azure VMware Solution with Cross Azure VMware Solution Topology](./media/dual-region-virtual-wan-without-globalreach-2.png)
**Traffic Flow**

| From |   To |  Hub 1 Virtual Networks | on-premises | Hub 2 Virtual Networks | Cross-Regional Azure VMware Solution Private Cloud|
| -------------- | -------- | ---------- | ---| ---| ---|
| Azure VMware Solution Cloud Region 1    | &#8594;| Hub1Fw>Virtual Network 1|  GlobalReach(A)>on-premises   | Hub2Fw>Virtual Network 2 | Global Reach(C)>Azure VMware Solution Cloud Region 2|
| Azure VMware Solution Cloud Region 2   | &#8594;|  Hub1Fw>Virtual Network 1 |  GlobalReach(B)>on-premises   | Hub2Fw>Virtual Network 2 | Global Reach(C)>Azure VMware Solution Cloud Region 1|

### on-premises connectivity & traffic flow

As mentioned earlier, the hub will advertise the default RFC 1918 addresses (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to ExpressRoutes. This means that the hub will not advertise specific routes from one ExpressRoute to another ExpressRoute. For example:

In the diagram, you can see that the on-premises network 10.255.0.0/16 is not learned by any of the Azure VMware Solution Private clouds.
Similarly, the Azure VMware Solution Private clouds or any specific segments from Azure VMware Solution are not learned by the on-premises network.For instance, the on-premises network does not learn the Azure VMware Solution Region 1 10.150.0.0/22 and Region 2 10.250.0.0/22 routes.

On-premises will learn the default RFC 1918 addresses on both connections “F”. However, on-premises does not have the more specific routes, so it will use the 10.0.0.0/8 route to reach the Azure VMware Solution private clouds. But since 10.0.0.0/8 is learned on both connections “F”, the traffic from on-premises to Azure VMware Solution Private clouds will be load balanced between both regional Hub 1 and Hub 2. This will cause asymmetric traffic and introduce latency.

To avoid the load balancing issue from on-premises to Azure VMware Solution Private clouds, you will need to use Route-Maps on the Hubs to advertise specific routes on one Hub and use BGP AS-Prepending on the other regional Hub. The Route-Map will be applied to the on-premises connection “F”. By advertising specific routes and using AS-Prepending, you can ensure symmetric traffic flow. This means that the traffic will follow the same path in both directions, from on-premises to Azure VMware Solution Private clouds and back. This will improve the performance and reliability of your network.

For example, you can use the following configuration:

| Hub |   Route-Map Name | Prefix | AS-Prepending | 
| -------------- | -------- | ---------- | ---|
| Hub 1   | Route map out |  10.150.0.0/22   | No
| Hub 1   | Route map out |  10.250.0.0/22   | Yes
| Hub 2   | Route map out |  10.250.0.0/22   | No
| Hub 2   | Route map out |  10.150.0.0/22   | Yes 

When you enable ExpressRoute to ExpressRoute transitivity on the Hub, it will send the default RFC 1918 addresses (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to your on-premises network. Therefore, you should not advertise the exact RFC 1918 prefixes (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) back to Azure. This can create routing problems within Azure. Instead, you should advertise more specific routes back to Azure for your on-premises networks.

Additionally, if your ExpressRoute circuit is advertising a non-RFC1918 prefix to Azure, please make sure the address ranges that you put in the Private Traffic Prefixes text box are less specific than ExpressRoute advertised routes. For example, if the ExpressRoute Circuit is advertising 40.0.0.0/24 from on-premises, put a /23 CIDR range or larger in the Private Traffic Prefix text box (example: 40.0.0.0/23).

The diagram illustrates how on-premises and each Azure VMware Solution Private cloud learns routes from both regional hubs.

![Diagram of Dual-Region Azure VMware Solution with on-premises](./media/dual-region-virtual-wan-without-globalreach-3.png)
**Traffic Flow**

| From |   To |  Hub 1 Virtual Networks | Hub 2 Virtual Networks | Azure VMware Solution Region 1| Azure VMware Solution Region 2|
| -------------- | -------- | ---------- | ---| ---| ---|
| on-premises    | &#8594;| Hub1Fw>Virtual Network 1|  Hub2Fw>Virtual Network 2  | Global Reach(A)>Azure VMware Solution Cloud Region 1 | Global Reach(B)>Azure VMware Solution Cloud Region 2| 

### Azure Virtual Network connectivity & traffic flow

This section focuses only on connectivity from an Azure Virtual Network perspective. As depicted in the diagram, both Virtual Network 1 and Virtual Network 2 have a Virtual Network peering directly to their local regional hub.

The diagram illustrates how all Azure native resources in Virtual Network 1 and Virtual Network 2 learn routes under their "Effective Routes". A Secure Hub with enabled Routing Intent always sends the default RFC 1918 addresses (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to peered Virtual Networks, plus any other prefixes that have been added as "Private Traffic Prefixes" - see [Routing Intent Private Address Prefixes](/azure/virtual-wan/how-to-routing-policies#azurefirewall). In our scenario, with Routing Intent enabled, all resources in Virtual Network 1 and Virtual Network 2 currently possess the default RFC 1918 address and use their local regional hub firewall as the next hop. All traffic ingressing and egressing the Virtual Networks will always transit the Hub Firewalls. For more information, see the traffic flow section for more detailed information.

The diagram illustrates how Azure Virtual Networks and each Azure VMware Solution private cloud learns routes from both regional hubs.

![Diagram of Dual-Region Azure VMware Solution with Virtual Networks](./media/dual-region-virtual-wan-without-globalreach-4.png)
**Traffic Flow**

| From |   To |  on-premises | Azure VMware Solution Region 1 | Azure VMware Solution Region 2| Cross-Region Virtual Network|  
| -------------- | -------- | ---------- | ---| ---| ---|
| Virtual Network 1    | &#8594;| Hub1Fw>on-premises|  Hub1Fw>Azure VMware Solution Cloud Region 1  | Hub1Fw>Azure VMware Solution Cloud Region 2 | Hub1Fw>Hub2Fw>Virtual Network 2 |
| Virtual Network 2    | &#8594;| Hub2Fw>on-premises|  Hub2Fw>Azure VMware Solution Cloud Region 1  | Hub2Fw>Azure VMware Solution Cloud Region 2 | Hub2Fw>Hub1Fw>Virtual Network 1 |

### Internet connectivity

This section focuses only on how internet connectivity is provided for Azure native resources in Virtual Networks and Azure VMware Solution Private Clouds in both regions. There are several options to provide internet connectivity to Azure VMware Solution. - see [Internet Access Concepts for Azure VMware Solution](/azure/azure-VMware/concepts-design-public-internet-access)

Option 1: Internet Service hosted in Azure  
Option 2: VMware Solution Managed SNAT  
Option 3: Azure Public IPv4 address to NSX-T Data Center Edge  

Although you can use all three options with Dual Region Secure Virtual WAN with Routing Intent,  "Option 1: Internet Service hosted in Azure" is the best option when using Secure Virtual WAN with Routing Intent and is the option that is used to provide internet connectivity in the scenario.  

As mentioned earlier, when you enable Routing Intent on the Secure Hub, it advertises RFC 1918 to all peered Virtual Networks. However, you can also advertise a default route 0.0.0.0/0 for internet connectivity to downstream resources. The preferred default route is advertised via connection "E", and the backup default route is advertised via connection "D".

 Each Virtual Network will egress to the internet using its local regional hub firewall. The default route is never advertised across regional hubs over the "inter-hub" link. Therefore, Virtual Networks can only use their local regional hub for internet access. 

From an Azure VMware Solution Private Cloud perspective, when advertising the default route across regional connections (connections labeled as "D"), you need to configure route maps with BGP prepending on the Secure Virtual WAN hubs. When you do not use BGP prepending, Azure VMware Solution Cloud regions load balance internet traffic between their local and regional hubs. This load balance would introduce asymmetric traffic and impact internet performance. 

Before we continue, let's go over what BGP prepending is. BGP prepending is a technique in inter-domain routing where an AS artificially extends the AS Path by adding its own AS number multiple times to influence inbound traffic. By making the path appear longer, the AS aims to divert traffic away from the prepended route and towards other potentially more favorable paths. You can use any BGP Private AS when using BGP prepending. 

The goal here is to use BGP prepending for only the default routes across cross regional ExpressRoute links (connections labeled as "D") down to Azure VMware Solution Private clouds. We are not prepending the default route across local ExpressRoute links (connections labeled as "E") to the Azure VMware Solution Private Clouds. Use the Route Maps function of Virtual WAN to achieve redundant internet egress connectivity for your AVS Private Clouds.

>[!NOTE]
>  When using BGP Prepending, please be aware that utilizing a Private BGP Autonomous System Number (ASN) within the range of 64512-65535 in the AS path will result in it being stripped before the routes are sent back to the on-premises location. This, in turn, will impact the ability to honor the AS_PATH attribute from the on-premises perspective. To address this, when implementing BGP Prepending, we strongly recommend selecting Autonomous Systems falling within the range of 64496-64511, as specified in RFC 5398.
>

In short, Azure VMware Solution Private Clouds prioritize internet access via regional local hubs, using the cross-regional hub as backup during local hub outages. See traffic flow section more information.

Another important point is that with Routing Intent, you can choose to not advertise the default route over specific ExpressRoute connections. We recommend not to advertise the default route to your on-premises ExpressRoute connections. 

The diagram illustrates how Azure Virtual Networks and each Azure VMware Solution private cloud learns default routes from both regional hubs.

![Diagram of Dual-Region Azure VMware Solution with Internet](./media/dual-region-virtual-wan-without-globalreach-5.png)
**Traffic Flow**

| From |   To |  Primary Internet Route | Backup Internet Route |
| -------------- | -------- | ---------- | ---------- |
| Virtual Network 1    | &#8594;| Hub1Fw>Internet| None|
| Virtual Network 2    | &#8594;| Hub2Fw>Internet| None|
| Azure VMware Solution Cloud Region 1    | &#8594;| Hub1Fw>Internet| Hub2Fw>Internet|
| Azure VMware Solution Cloud Region 2    | &#8594;| Hub2Fw>Internet| Hub1Fw>Internet|

### Connectivity between Azure NetApp Files and Azure VMware Solution with Virtual WAN
If you use Azure NetApp Files as external storage for Azure VMware Solution, it is recommended use ExpressRoute FastPath. FastPath improves the data path performance between Azure VMware Solution and your Azure NetApp File virtual network by bypassing the gateway. However, Virtual WAN does not support FastPath at the time of this writing; so, you need to create an ExpressRoute Gateway that supports FastPath in the same Virtual Network as Azure NetApp Files - see [ExpressRoute Gateways that support FastPath](/azure/expressroute/about-fastpath#gateways). Then, you can connect the Azure VMware Solution managed ExpressRoute circuit to the gateway.

### Utilizing VMware HCX MON without Global Reach
HCX Mobility Optimized Networking (MON) is an optional feature to enable when using HCX Network Extensions (NE). MON provides optimal traffic routing under certain scenarios to prevent network tromboning between the on-premises-based and cloud-based resources on extended networks.

**Egress Traffic from Azure VMware Solution**   
Once Mobility Optimized Networking (MON) has been enabled for a specific extended network and a virtual machine, egress traffic for that virtual machine will no longer trombon back to on-premises over the Network Extensions (NE) IPSEC tunnel. Traffic for that virtual machine destined to on-premises will now egress out of the Azure VMware Solution NSX-T Tier-1 Gateway> NSX-T Tier-0 Gateway>Azure Virtual WAN>On-Premises.

**Ingress Traffic to Azure VMware Solution**   
Once Mobility Optimized Networking (MON) has been enabled for a specific extended network and a virtual machine, from Azure VMware Solution NSX-T, a /32 host route is injected back to Azure Virtual WAN. Azure Virtual WAN will advertise this /32 route back to on-premises (this will not happen when using Routing-Intent without Global Reach - more on this later). This /32 host route is to ensure that on-premises does not use the Network Extensions (NE) IPSEC tunnel to route back to the Azure VMware Solution virtual machine.

**Limiation**  
Once ExpressRoute to ExpressRoute transitivity is enabled on the hub, the hub will then advertise over both the on-premises-based ExpressRoute and Azure VMware Solution ExpressRoute the default RFC 1918 addresses: 10.0.0.0/8, 172.16.0.0/12 and 192.168.0.0/16. However, there is a default behavior when using routing intent where the Virtual WAN hub will not advertise a more specific route from one ExpressRoute Circuit to another ExpressRoute circuit. This means that host routes (more specific routes) will not be advertised from the Azure VMware Solution ExpressRoute to the on-premises-based ExpressRoute circuit. It will only advertise the default RFC 1918 addresses: 10.0.0.0/8, 172.16.0.0/12 and 192.168.0.0/16 addresses.
When you enable Routing-Intent without Global Reach, the /32 host route is never learned on-premises due to this behavior. This will introduce asymmetric traffic, where traffic egresses Azure VMware Solution via the NSX-T Tier-1 gateway but returning traffic from on-premises will return over the Network Extensions (NE) IPSEC tunnel.

**Workaround**  
To resolve this issue, on-premises on the same network device that peers back to Azure via BGP you can create a /32 static route with a next-hop of the Microsoft BGP Peer IP addresses. You can then redistribute the static route back to on-premises using your preferred routing protocol. This will now keep traffic symmetrical and force traffic from on-premises to Mobility Optimized Networking (MON) enabled virtual machines over the ExpressRoute Circuit and not over the on-premises Network Extensions (NE) IPSEC tunnel.


## Next steps

- For more information on Virtual WAN hub configuration, see [About virtual hub settings](/azure/virtual-wan/hub-settings).
- For more information on how to configure Azure Firewall in a Virtual Hub, see [Configure Azure Firewall in a Virtual WAN hub](/azure/virtual-wan/howto-firewall).
- For more information on how to configure the Palo Alto Next Generation SAAS firewall on Virtual WAN, see [Configure Palo Alto Networks Cloud NGFW in Virtual WAN](/azure/virtual-wan/how-to-palo-alto-cloud-ngfw).
- For more information on Virtual WAN hub routing intent configuration, see [Configure routing intent and policies through Virtual WAN portal](/azure/virtual-wan/how-to-routing-policies#nva).
- For more information how to configure Virtual WAN Route-Maps, see [How to configure Route-maps](/azure/virtual-wan/route-maps-how-to).

