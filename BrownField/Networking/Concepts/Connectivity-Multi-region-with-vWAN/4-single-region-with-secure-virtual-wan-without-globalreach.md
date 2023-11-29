---
title: Single-Region Azure VMware Solution design without Global Reach, using Secure Virtual WAN with Routing-Intent
description: Learn how to configure network connectivity when Azure VMware Solution private cloud is deployed in an Azure region with Secure Virtual WAN.
author: jasonmedina
ms.author: jasonmedina
ms.date: 11/28/2023
ms.topic: conceptual
ms.service: caf
ms.subservice: caf-scenario-vmware
ms.custom: think-tank, e2e-azure-VMware
---

# Single-region deployment using Secure Virtual WAN Hub with Routing-Intent

This article describes the best practices for connectivity, traffic flows, and high availability of single-region Azure VMware Solution when using Azure Secure Virtual WAN with Routing Intent. You will learn the design details of using Secure Virtual WAN with Routing-Intent, without Global Reach. This article breaks down Virtual WAN with Routing Intent topology from the perspective of an Azure VMware Solution private cloud, on-premises sites, and Azure native. The implementation and configuration of Secure Virtual WAN with Routing Intent are beyond the scope and are not discussed in this document.

In regions without Global Reach support or with a security requirement to inspect traffic between Azure VMware Solution and on-premises at the hub firewall, a support ticket must be opened to enable ExpressRoute to ExpressRoute transitivity. ExpressRoute to ExpressRoute transitivity isn't supported by default with Secure Virtual WAN. - see [Transit connectivity between ExpressRoute circuits with routing intent](/azure/virtual-wan/how-to-routing-policies#expressroute)

>[!NOTE]
>  When configuring Azure VMware Solution with Secure Virtual WAN Hubs, ensure optimal routing results on the hub by setting the Hub Routing Preference option to "AS Path." - see [Virtual hub routing preference](/azure/virtual-wan/about-virtual-hub-routing-preference)
>

## Single-region with Secure Virtual WAN scenario  
Secure Virtual WAN with Routing Intent is only supported with Virtual WAN Standard SKU. Secure Virtual WAN with Routing Intent provides the capability to send all Internet traffic and Private network traffic (RFC 1918) to a security solution like Azure Firewall, a third-party Network Virtual Appliance (NVA), or SaaS solution. In the scenario, we have a network topology that spans a single region. There is one Virtual WAN with a single hub(Hub1) located in the Region. The Hub has its own instance of an Azure Firewall deployed(Hub1Fw), essentially making it a Secure Virtual WAN Hub. Having a Secure Virtual WAN hub is a technical prerequisite to Routing Intent. Secure Virtual WAN Hub1 have Routing Intent enabled.    

The single region also has an Azure VMware Solution Private Cloud and an Azure Virtual Network. There is also an on-premises site connecting to the region, which we review in more detail later in this document. 
![Diagram of Single-Region Azure VMware Solution Scenario](./media/single-region-virtual-wan-without-globalreach-1.png)

### Understanding Topology Connectivity 

| Connection | Description  |
|:-------------------- |:--------------------  |
| Connections (E) | Azure VMware Solution private cloud managed ExpressRoute connection to the hub.  |
| Connections (F) | on-premises ExpressRoute connection to the hub.  |

## Single-region Secure Virtual WAN Traffic Flows

The following sections cover traffic flows and connectivity for Azure VMware Solution, on-premises, Azure Virtual Networks, and the Internet.

### Azure VMware Solution connectivity & traffic flows

This section focuses on only the Azure VMware Solution private cloud. The Azure VMware Solution private cloud has an ExpressRoute connection to the hub (connections labeled as "E").

 The Azure VMware Solution private cloud communicates to on-premises through the Hub firewall. The traffic flows over the Azure VMware Solution Managed ExpressRoute (Connection “E”) and the on-premises ExpressRoute (Connection “F”), both of which pass through the Hub firewall. With ExpressRoute to ExpressRoute transitivity enabled on the Secure Hub and Routing-Intent enabled, the Secure Hub sends the default RFC 1918 addresses (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to both the on-premises and the Azure VMware Solution. The diagram below shows that the Azure VMware Solution only learns the specific routes from Azure and the default RFC 1918 addresses from the Secure Hub. However, the Azure VMware Solution does not learn the specific routes from the on-premises network. It relies on the default RFC 1918 addresses to route back to the on-premises network through the Hub firewall. The Hub firewall has the specific routes for the on-premises networks and routes traffic toward the destination over Connection “F”. For more information, see the traffic flow section for more detailed information.

The diagram illustrates the Route Table as seen from the perspective of Azure VMware Solution.

![Diagram of Single-Region Azure VMware Solution with Cross Azure VMware Solution Topology](./media/single-region-virtual-wan-without-globalreach-2.png)  
**Traffic Flow**  

| From |   To |  Virtual Network | on-premises |
| -------------- | -------- | ---------- | ---|
| Azure VMware Solution Cloud    | &#8594;| HubFw>Virtual Network|  HubFw>on-premises   | 

### on-premises connectivity & traffic flow

This section focuses only on the on-premises site. As shown in the diagram, the on-premises site has an ExpressRoute connection to the hub (connection labeled as "F").

On-premises communicates to Azure VMware Solution through the Hub firewall. The traffic flows over  the on-premises ExpressRoute (Connection “F”) and the Azure VMware Solution Managed ExpressRoute (Connection “E”), both of which pass through the Hub firewall. With ExpressRoute to ExpressRoute transitivity enabled on the Secure Hub and Routing-Intent enabled, the Secure Hub sends the default RFC 1918 addresses (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to both the on-premises and the Azure VMware Solution. The diagram below shows that on-premises only learns the specific routes from Azure and the default RFC 1918 addresses from the Secure Hub. However, on-premises does not learn the specific routes from Azure VMware Solution. It relies on the default RFC 1918 addresses to route back to Azure VMware Solution through the Hub firewall. The Hub firewall has the specific routes for Azure VMware Solution and routes traffic toward the destination over Connection “E”. For more information, see the traffic flow section for more detailed information.

When you enable ExpressRoute to ExpressRoute transitivity on the Hub, it will send the default RFC 1918 addresses (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to your on-premises network. Therefore, you should not advertise the exact RFC 1918 prefixes (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) back to Azure. This can create routing problems within Azure. Instead, you should advertise more specific routes back to Azure for your on-premises networks.

Additionally, if your ExpressRoute circuit is advertising a non-RFC1918 prefix to Azure, please make sure the address ranges that you put in the Private Traffic Prefixes text box are less specific than ExpressRoute advertised routes. For example, if the ExpressRoute Circuit is advertising 40.0.0.0/24 from on-premises, put a /23 CIDR range or larger in the Private Traffic Prefix text box (example: 40.0.0.0/23).

The diagram illustrates the Route Table as seen from the perspective of on-premises and Azure VMware Solution.

![Diagram of Single-Region Azure VMware Solution with on-premises](./media/single-region-virtual-wan-without-globalreach-3.png)  
**Traffic Flow**  

| From |   To |  Virtual Network  | Azure VMware Solution |
| -------------- | -------- | ---------- | ---| 
| on-premises    | &#8594;| HubFw>Virtual Network| HubFw>Azure VMware Solution Cloud | 

### Azure Virtual Network connectivity & traffic flow

This section focuses only on connectivity from an Azure Virtual Network perspective. As depicted in the diagram, the Virtual Network has a Virtual Network peering directly to the hub.

The diagram illustrates how all Azure native resources in the Virtual Network learn routes under their "Effective Routes". A Secure Hub with enabled Routing Intent always sends the default RFC 1918 addresses (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to peered Virtual Networks, plus any other prefixes that have been added as "Private Traffic Prefixes" - see [Routing Intent Private Address Prefixes](/azure/virtual-wan/how-to-routing-policies#azurefirewall). In our scenario, with Routing Intent enabled, all resources in the Virtual Network currently possess the default RFC 1918 address and use the hub firewall as the next hop. All traffic ingressing and egressing the Virtual Networks will always transit the Hub Firewall. For more information, see the traffic flow section for more detailed information.

The diagram illustrates the Route Table as seen from the perspective of the Azure Virtual Network and Azure VMware Solution.

![Diagram of Single-Region Azure VMware Solution with Virtual Networks](./media/single-region-virtual-wan-without-globalreach-4.png)  
**Traffic Flow**  

| From |   To |  on-premises | Azure VMware Solution | 
| -------------- | -------- | ---------- | ---|
| Virtual Network    | &#8594;| HubFw>on-premises|  HubFw>Azure VMware Solution  |

### Internet connectivity

This section focuses only on how internet connectivity is provided for Azure native resources in Virtual Networks and Azure VMware Solution Private Clouds in a single region. There are several options to provide internet connectivity to Azure VMware Solution. - see [Internet Access Concepts for Azure VMware Solution](/azure/azure-VMware/concepts-design-public-internet-access)

Option 1: Internet Service hosted in Azure  
Option 2: VMware Solution Managed SNAT  
Option 3: Azure Public IPv4 address to NSX-T Data Center Edge  

Although you can use all three options with Single Region Secure Virtual WAN with Routing Intent,  "Option 1: Internet Service hosted in Azure" is the best option when using Secure Virtual WAN with Routing Intent and is the option that is used to provide internet connectivity in the scenario.  

As mentioned earlier, when you enable Routing Intent on the Secure Hub, it advertises RFC 1918 to all peered Virtual Networks. However, you can also advertise a default route 0.0.0.0/0 for internet connectivity to downstream resources. The default route is advertised via connection "E".

Virtual networks peered to the Hub will use the hub firewall to access the internet.  
 
Another important point is that with Routing Intent, you can choose to not advertise the default route over specific ExpressRoute connections. We recommend not to advertise the default route to your on-premises ExpressRoute connections. 

See traffic flow section more information.

The diagram illustrates the Route Table as seen from the perspective of Azure VMware Solution and the Azure Virtual Network.

![Diagram of Single-Region Azure VMware Solution with Internet](./media/single-region-virtual-wan-without-globalreach-5.png)  
**Traffic Flow**  

| From |   To |  Primary Internet Route | 
| -------------- | -------- | ---------- |
| Virtual Network    | &#8594;| HubFw>Internet|
| Azure VMware Solution    | &#8594;| HubFw>Internet|

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
