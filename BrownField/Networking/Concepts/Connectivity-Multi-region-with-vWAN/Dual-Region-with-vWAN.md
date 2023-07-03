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

The next sections describe the Azure VMware Solution network configuration that is necessary to enable, in the reference dual-region scenario, the following communication patterns:

- Azure VMware Solution to Azure VMware Solution (covered in the section [Azure VMware Solution cross-region connectivity](#azure-vmware-solution-cross-region-connectivity));
- Azure VMware Solution to on-premises sites connected over ExpressRoute (covered in the section [Hybrid connectivity](#hybrid-connectivity));
- Azure VMware Solution to Azure Virtual Network (covered in the section [Azure Virtual Network connectivity](#azure-virtual-network-connectivity));
- Azure VMware Solution to internet (covered in the section [Internet connectivity](#internet-connectivity)).

### Azure VMware Solution cross-region connectivity & traffic flows

When multiple Azure VMware Solution private clouds exist, Layer 3 connectivity among them is often a requirement for tasks such as supporting data replication.

Azure VMware Solution natively supports direct connectivity between two private clouds deployed in different Azure regions. Private clouds connect to the Azure network in their own region through ExpressRoute circuits, managed by the platform and terminated on dedicated ExpressRoute meet-me locations. Throughout this article, these circuits are referred to as *Azure VMware Solution managed circuits*. Azure VMware Solution managed circuits shouldn't be confused with the normal circuits that customers deploy to connect their on-premises sites to Azure. The normal circuits that customers deploy are *customer managed circuits* (see Figure 2).

![image](https://github.com/jasonamedina/Enterprise-Scale-for-AVS/assets/97964083/43d9ac83-d982-4cd1-8760-ff32b5dd6f76)


| From |   To |  Hub 1 VNets | On-Premise | Hub 2 VNets | Cross-Regional AVS Private Cloud|
| -------------- | -------- | ---------- | ---| ---| ---|
| AVS Cloud Region 1    | &#8594;| Hub1Fw>Vnet1|  GlobalReach(A)>OnPremise   | Hub2Fw>Vnet2 | Global Reach(C)>AVS Cloud Region 2|
| AVS Cloud Region 2   | &#8594;|  Hub1Fw>Vnet1 |  GlobalReach(B)>OnPremise   | Hub2Fw>Vnet2 | Global Reach(C)>AVS Cloud Region 1|

### On-Premise connectivity & traffic flow

The recommended option for connecting Azure VMware Solution private clouds to on-premises sites is ExpressRoute Global Reach. Global Reach connections can be established between customer managed ExpressRoute circuits and Azure VMware Solution managed ExpressRoute circuits. Global Reach connections aren't transitive, therefore a full mesh (each Azure VMware Solution managed circuit connected to each customer managed circuit) is necessary for disaster resilience, as shown in the following Figure 3 (represented by orange lines).

![image](https://github.com/jasonamedina/Enterprise-Scale-for-AVS/assets/97964083/9ce15daf-f6a8-412a-8d5f-a01c68bd3df1)


| From |   To |  Hub 1 VNets | Hub 2 VNets | AVS Region 1| AVS Region 2| 
| -------------- | -------- | ---------- | ---| ---| ---|
| On-Premise    | &#8594;| Hub1Fw>Vnet1|  Hub2Fw>Vnet2  | Global Reach(A)>AVS Cloud Region 1 | Global Reach(B)>AVS Cloud Region 2| 

### Azure Virtual Network connectivity & traffic flow

Azure Virtual Network can be connected to Azure VMware Solution private clouds through connections between ExpressRoute Gateways and Azure VMware Solution managed circuits. This connection is exactly the same way that Azure Virtual Network can be connected to on-premises sites over customer managed ExpressRoute circuits. See [Connect to the private cloud manually](/azure/azure-vmware/tutorial-configure-networking#connect-to-the-private-cloud-manually) for configuration instructions.

In dual region scenarios, we recommend a full mesh for the ExpressRoute connections between the two regional hub Virtual Network and private clouds, as shown in Figure 4 (represented by yellow lines).

![image](https://github.com/jasonamedina/Enterprise-Scale-for-AVS/assets/97964083/5f153c7b-f683-44e7-b9ab-cebece766580)

| From |   To |  On-Premise | AVS Region 1 | AVS Region 2| Cross-Region Vnet| 
| -------------- | -------- | ---------- | ---| ---| ---|
| Vnet1    | &#8594;| Hub1Fw>OnPremise|  Hub1Fw>AVS Cloud Region 1  | Hub1Fw>AVS Cloud Region 2 | Hub1Fw>Hub2Fw>Vnet2 |
| Vnet2    | &#8594;| Hub2Fw>OnPremise|  Hub2Fw>AVS Cloud Region 1  | Hub2Fw>AVS Cloud Region 2 | Hub2Fw>Hub1Fw>Vnet1 |

### Internet connectivity

When deploying Azure VMware Solution private clouds in multiple regions, we recommend native options for internet connectivity (managed source network address translation (SNAT) or public IPs down to the NSX-T). Either option can be configured through the Azure portal (or via PowerShell, CLI or ARM/Bicep templates) at deployment time, as shown in the following Figure 5.

![image](https://github.com/jasonamedina/Enterprise-Scale-for-AVS/assets/97964083/42be71ef-5416-41e7-8f8b-a0a177757ed8)

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
