---
title: Network considerations for Azure VMware Solution dual-region deployments with Secure vWAN
description: Learn how to configure network connectivity when Azure VMware Solution private clouds are deployed in two Azure regions with Secure vWAN.
author: jmedina
ms.author: jmedina
ms.date: 06/22/2023
ms.topic: conceptual
ms.service: caf
ms.subservice: caf-scenario-vmware
ms.custom: think-tank, e2e-azure-vmware
---

# Network considerations for Azure VMware Solution dual-region deployments using Secure vWAN with Routing-Intent

This article describes the best practices for connectivity, traffic flows, and high availability of dual-region Azure VMWare Solution when using Azure vWAN with Routing Intent. This article will break down vWAN with Routing Intent topology from the perspective of AVS private clouds, On-premise sites, and Azure native. How to implement and configure Secure vWAN with Routing Intent is out of the scope and will not be discussed in this document.

The document assumes readers have a basic understanding of vWAN and Secure vWAN with Routing Intent.

**What is Azure Virtual WAN?**  
[https://learn.microsoft.com/en-us/azure/virtual-wan/how-to-routing-policies](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about)

**How to configure Virtual WAN Hub routing intent and routing policies**  
https://learn.microsoft.com/en-us/azure/virtual-wan/how-to-routing-policies

## Dual-region with Secure vWAN scenario  
Secure vWAN with Routing Intent provides the capability to send all Internet traffic and Private network traffic (RFC 1918) to a security solution like Azure Firewall, a third-party NVA, or SaaS. 
In the scenario, we have a network topology that spans two regions. There is one vWAN with two Hubs, Hub1 and Hub2. Hub1 is in Region 1, and Hub2 is in Region 2.Each Hub in both regions has its instance of Azure Firewall deployed(Hub1Fw, Hub2Fw), essentially making them Secure vWAN Hubs. Having Secure vWAN hubs is a technical prerequisite to Routing Intent. Secure vWAN Hub1 and Hub2 have Routing Intent enabled.  

Each region has its own AVS Private Cloud and an Azure Vnet. There is also an on-premise site connecting to both regions, which we will review in more detail later in this document.
![image](https://github.com/jasonamedina/Enterprise-Scale-for-AVS/assets/97964083/0d2d0b80-e550-4f69-a321-411658a066ab)
### Understanding Topology Connectivity 
**Brown Connections**: AVS private cloud connection to its local regional hub.  
**Pink Connections**: AVS private cloud connection to its cross-regional hub.   
**Orange Connection**: AVS Region 1 Global Reach connection back to on-premise.   
**Green Connection**: AVS Region 2 Global Reach connection back to on-premise.   
**Purple Connection**: AVS Region 1 and AVS Region 2 Global Reach connection back to each other's private cloud.   
**Black Connections**: On-premise connectivity via ExpressRoute to both regional hubs.  
**Inter-Hub Connection**: When two hubs are deployed under the same vWAN, they automatically form an inter-hub connection with one another. The purpose of the inter-hub is to transit cross-regional traffic between the two hubs.  

## Dual-region Secure vWAN Traffic Flows

The following sections below will discuss traffic flows and connectivity for AVS, On-Premise, Azure Vnets, and the Internet. 

### Azure VMware Solution cross-region connectivity & traffic flows

This section will focus on only the AVS Cloud Region 1 and AVS Cloud Region 2. Each AVS private cloud will have an ExpressRoute connection to its local regional hub (brown connections) and an ExpressRoute connection to the cross-regional hub (pink connections).

Each AVS Cloud Region connects back to on-premise via Global Reach. AVS Cloud Region 1 Global Reach connection is shown in orange as "Global Reach (A)". AVS Cloud Region 2 Global Reach connection is shown in green as "Global Reach (B)". Both AVS private clouds are connected directly to each other via Global Reach shown in purple as Global Reach (C). Keep in mind that Global Reach traffic will never transit any hub firewalls. See traffic flow section below for more information.  

The diagram also depicts how all routes in each AVS Cloud region will learn routes from both the local and cross-regional hub. All blue routes are from Region 1, and all red routes are from Region 2. 

![image](https://github.com/jasonamedina/Enterprise-Scale-for-AVS/assets/97964083/43d9ac83-d982-4cd1-8760-ff32b5dd6f76)

**Traffic Flow**
| From |   To |  Hub 1 VNets | On-Premise | Hub 2 VNets | Cross-Regional AVS Private Cloud|
| -------------- | -------- | ---------- | ---| ---| ---|
| AVS Cloud Region 1    | &#8594;| Hub1Fw>Vnet1|  GlobalReach(A)>OnPremise   | Hub2Fw>Vnet2 | Global Reach(C)>AVS Cloud Region 2|
| AVS Cloud Region 2   | &#8594;|  Hub1Fw>Vnet1 |  GlobalReach(B)>OnPremise   | Hub2Fw>Vnet2 | Global Reach(C)>AVS Cloud Region 1|

### On-Premise connectivity & traffic flow

This section will focus only on the on-premise site. As shown in the diagram below, the On-Premise site will have an ExpressRoute connection to both Region 1 and Region 2 hubs (black connections).

On-Premise can communicate to AVS Cloud Region 1 via orange connection "Global Reach (A)". On-Premise will also be able to communicate with AVS Cloud Region 2 via green connection "Global Reach (B).

The diagram shows how On-Premise will learn routes from both regional hubs and both AVS Private clouds. All blue routes are from Region 1, and all red routes are from Region 2. Black routes are on-premise routes and are advertised back to Azure.

![image](https://github.com/jasonamedina/Enterprise-Scale-for-AVS/assets/97964083/9ce15daf-f6a8-412a-8d5f-a01c68bd3df1)

**Traffic Flow**
| From |   To |  Hub 1 VNets | Hub 2 VNets | AVS Region 1| AVS Region 2| 
| -------------- | -------- | ---------- | ---| ---| ---|
| On-Premise    | &#8594;| Hub1Fw>Vnet1|  Hub2Fw>Vnet2  | Global Reach(A)>AVS Cloud Region 1 | Global Reach(B)>AVS Cloud Region 2| 

### Azure Virtual Network connectivity & traffic flow

This section will focus only on connectivity from an Azure Vnet perspective. As shown in the diagram below, both Vnet1 and Vnet2 will have a vnet peering directly to its local regional hub. 

The diagram shows how all Azure native resources in Vnet1 and Vnet2 will learn routes under their "Effective Routes". A Secure Hub with Routing Intent enabled will always send the default RFC 1918 addresses (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to peered Vnets. In our case, since Routing Intent is enabled, all resources within Vnet1 and Vnet2 will have the default RFC 1918 address with a next-hop of their local regional hub firewall. All traffic ingressing and egressing the Vnets will always transit the Hub Firewalls. Please see the traffic flow below for more detailed information.

![image](https://github.com/jasonamedina/Enterprise-Scale-for-AVS/assets/97964083/5f153c7b-f683-44e7-b9ab-cebece766580)

**Traffic Flow**
| From |   To |  On-Premise | AVS Region 1 | AVS Region 2| Cross-Region Vnet| 
| -------------- | -------- | ---------- | ---| ---| ---|
| Vnet1    | &#8594;| Hub1Fw>OnPremise|  Hub1Fw>AVS Cloud Region 1  | Hub1Fw>AVS Cloud Region 2 | Hub1Fw>Hub2Fw>Vnet2 |
| Vnet2    | &#8594;| Hub2Fw>OnPremise|  Hub2Fw>AVS Cloud Region 1  | Hub2Fw>AVS Cloud Region 2 | Hub2Fw>Hub1Fw>Vnet1 |

### Internet connectivity

When deploying Azure VMware Solution private clouds in multiple regions, we recommend native options for internet connectivity (managed source network address translation (SNAT) or public IPs down to the NSX-T). Either option can be configured through the Azure portal (or via PowerShell, CLI or ARM/Bicep templates) at deployment time, as shown in the following Figure 5.

![image](https://github.com/jasonamedina/Enterprise-Scale-for-AVS/assets/97964083/42be71ef-5416-41e7-8f8b-a0a177757ed8)

**Traffic Flow**
| From |   To |  Primary Internet Route | Backup Internet Route
| -------------- | -------- | ---------- | ---------- |
| Vnet1    | &#8594;| Hub1Fw>Internet| None|
| Vnet2    | &#8594;| Hub2Fw>Internet| None|
| AVS Cloud Region 1    | &#8594;| Hub1Fw>Internet| Hub2Fw>Internet|
| AVS Cloud Region 2    | &#8594;| Hub2Fw>Internet| Hub1Fw>Internet|

Both the options highlighted in Figure 5 provide each private cloud with a direct internet breakout in its own region. The following considerations should inform the decision as to which native internet connectivity option to use:

- Managed SNAT should be used in scenarios with basic and outbound-only requirements (low volumes of outbound connections and no need for granular control over the SNAT pool).
- Public IPs down to the NSX-T edge should be preferred in scenarios with large volumes of outbound connections or when you require granular control over NAT IP addresses. For example, which Azure VMware Solution VMs use SNAT behind which IP addresses. Public IPs down to the NSX-T edge also support inbound connectivity via DNAT. Inbound internet connectivity isn't covered in this article.

Changing a private cloud's internet connectivity configuration after the initial deployment is possible. But the private cloud loses connectivity to internet, Azure Virtual Network, and on-premises sites while the configuration is being updated. When either one of the native internet connectivity options in the preceding Figure 5 is used, no extra configuration is necessary in dual region scenarios (the topology stays the same as the one shown in Figure 4). For more information on internet connectivity for Azure VMware Solution, see [Internet connectivity design considerations](/azure/azure-vmware/concepts-design-public-internet-access).

## Next steps

- For more information on Azure VMware Solution network features, see [Azure VMware Solution networking and interconnectivity concepts](/azure/azure-vmware/concepts-networking).
- For more information on internet connectivity for Azure VMware Solution, see [Internet connectivity design considerations](/azure/azure-vmware/concepts-design-public-internet-access).

  > [!div class="nextstepaction"]
  > [Example architectures for Azure VMware Solutions](./example-architectures.md)
