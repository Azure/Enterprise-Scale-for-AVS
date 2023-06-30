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

This article describes how to configure network connectivity when Azure VMware Solution private clouds are deployed in two Azure regions for disaster resilience purposes. If there are partial or complete regional outages, the network topology in this article allows the surviving components (private clouds, Azure-native resources, and on-premises sites) to maintain connectivity with each other and with the internet.

## Dual-region with Secure vWAN scenario  

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

![image](https://github.com/jasonamedina/Enterprise-Scale-for-AVS/assets/97964083/5c12b6c1-2518-47f8-b1ea-17c3be86bff4)


Both the options highlighted in Figure 5 provide each private cloud with a direct internet breakout in its own region. The following considerations should inform the decision as to which native internet connectivity option to use:

- Managed SNAT should be used in scenarios with basic and outbound-only requirements (low volumes of outbound connections and no need for granular control over the SNAT pool).
- Public IPs down to the NSX-T edge should be preferred in scenarios with large volumes of outbound connections or when you require granular control over NAT IP addresses. For example, which Azure VMware Solution VMs use SNAT behind which IP addresses. Public IPs down to the NSX-T edge also support inbound connectivity via DNAT. Inbound internet connectivity isn't covered in this article.

Changing a private cloud's internet connectivity configuration after the initial deployment is possible. But the private cloud loses connectivity to internet, Azure Virtual Network, and on-premises sites while the configuration is being updated. When either one of the native internet connectivity options in the preceding Figure 5 is used, no extra configuration is necessary in dual region scenarios (the topology stays the same as the one shown in Figure 4). For more information on internet connectivity for Azure VMware Solution, see [Internet connectivity design considerations](/azure/azure-vmware/concepts-design-public-internet-access).

#### Azure-native internet breakout

If a secure internet edge was built in Azure Virtual Network prior to Azure VMware Solution adoption, it might be necessary to use it for internet access for Azure VMware Solution private clouds. Using a secure internet edge in this way is necessary for the centralized management of network security policies, cost optimization, and more. Internet security edges in Azure Virtual Network can be implemented using Azure Firewall or third-party firewall and proxy network virtual appliances (NVAs) available on the Azure Marketplace.

Internet-bound traffic emitted by Azure VMware Solution virtual machines can be attracted to an Azure VNet by originating a default route and announcing it, over border gateway protocol (BGP), to the private cloud's managed ExpressRoute circuit. This internet connectivity option can be configured through the Azure portal (or via PowerShell, CLI or ARM/Bicep templates) at deployment time, as shown in the following Figure 6. For more information, see [Disable internet access or enable a default route](/azure/azure-vmware/disable-internet-access).

:::image type="content" source="media/dual-region-figure-6.png" alt-text="Diagram of Figure 6, which shows the Azure VMware Solution configuration to enable internet connectivity via internet edges in Azure Virtual Network." lightbox="media/dual-region-figure-6.png":::

The internet edge NVAs can originate the default route if they support BGP. If not, you must deploy other BGP-capable NVAs. For more information on how to implement internet outbound connectivity for Azure VMware Solution in a single region, see [Implementing internet connectivity for Azure VMware Solution with Azure NVAs](https://github.com/Azure/Enterprise-Scale-for-AVS/tree/main/BrownField/Networking/Step-By-Step-Guides/Implementing%20internet%20connectivity%20for%20AVS%20with%20Azure%20NVAs). In the dual-region scenario discussed in this article, the same configuration must be applied to both regions.

The key consideration in dual-region scenarios is that the default route originated in each region should be propagated over ExpressRoute only to the Azure VMware Solution private cloud in same region. This propagation allows Azure VMware Solution workloads to access the internet through a local (in-region) breakout. However, if you use the topology shown in Figure 4, each Azure VMware Solution private cloud also receives an equal-cost default route from the remote region over the cross-region ExpressRoute connections. The red dashed lines represent this unwanted cross-region default route propagation in Figure 7.

:::image type="complex" source="media/dual-region-figure-7.png" alt-text="Diagram of Figure 7, which shows the cross-region connections between ExpressRoute Gateways and VMware Solution-managed ExpressRoute circuits must be removed." lightbox="media/dual-region-figure-7.png":::
   Diagram of Figure 7, which shows the cross-region connections between ExpressRoute Gateways and Azure VMware Solution-managed ExpressRoute circuits must be removed to avoid cross-region propagation of the default route.
:::image-end:::

Removing the Azure VMware Solution cross-region ExpressRoute connections achieves the goal of injecting, in each private cloud, a default route to forward internet-bound connections to the Azure internet edge in the local region.

It should be noted that if the cross-region ExpressRoute connections (red dashed lines in Figure 7) are removed, cross-region propagation of the default route still occurs over Global Reach. However, routes propagated over Global Reach have a longer AS Path than the locally originated ones and get discarded by the BGP route selection process.

The cross-region propagation over Global Reach of a less preferred default route provides resiliency against faults of the local internet edge. If a region's internet edge goes offline, it stops originating the default route. In that event, the less-preferred default route learned from the remote region installs in the Azure VMware Solution private cloud, so that internet-bound traffic is routed via the remote region's breakout.

The recommended topology for dual-region deployments with internet breakouts in Azure VNets is shown in the following Figure 8.

:::image type="complex" source="media/dual-region-figure-8.png" alt-text="Diagram of Figure 8, which shows the recommended topology for dual region deployments with internet outbound access through internet edges." lightbox="media/dual-region-figure-8.png":::
   Diagram of Figure 8, which shows the recommended topology for dual region Azure VMware Solution deployments with internet outbound access through internet edges in Azure Virtual Network. Cross-region connections between ExpressRoute Gateways and Azure VMware Solution managed circuits must not be established to prevent unwanted cross-region propagation of the default route.
:::image-end:::

When you originate default routes in Azure, special care must be taken to avoid propagation to on-premises sites, unless there's a requirement to provide internet access to on-premises sites via an internet edge in Azure. The customer-operated devices that terminate the customer managed ExpressRoute circuits must be configured to filter default routes received from Azure, as shown in Figure 9. This configuration is necessary to avoid disrupting internet access for the on-premises sites.

:::image type="content" source="media/dual-region-figure-9.png" alt-text="Diagram of Figure 9, which shows the BGP speakers that terminate the customer-managed ExpressRoute circuits are filtering Azure NVAs' default routes." lightbox="media/dual-region-figure-9.png":::

## Next steps

- For more information on Azure VMware Solution network features, see [Azure VMware Solution networking and interconnectivity concepts](/azure/azure-vmware/concepts-networking).
- For more information on internet connectivity for Azure VMware Solution, see [Internet connectivity design considerations](/azure/azure-vmware/concepts-design-public-internet-access).

  > [!div class="nextstepaction"]
  > [Example architectures for Azure VMware Solutions](./example-architectures.md)
