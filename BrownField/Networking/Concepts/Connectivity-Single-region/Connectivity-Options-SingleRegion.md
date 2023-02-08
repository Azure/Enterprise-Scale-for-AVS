# Single Region Connectivity Guidance

* [Overview](Connectivity-Options-SingleRegion.md#overview)
* [Internet Breakout - On-Premises](Connectivity-Options-SingleRegion.md#default-route-advertisement-from-on-premises)
* [Internet Breakout - AVS Native ]()
  * [Managed SNAT](Connectivity-Options-SingleRegion.md#managed-snat)
  * [Public IP](Connectivity-Options-SingleRegion.md#public-ip-at-the-nsx-t-data-center-edge)
* [Internet Breakout - Azure Native ]()
  * [Secured VWAN Hub](Connectivity-Options-SingleRegion.md#secured-vwan-hub)
  * [Hub & Spoke VNET's](Connectivity-Options-SingleRegion.md#hub--spoke-with-next-gen-firewall)


## Overview 

Azure VMware Solution has many options for connectivity. This includes Azure VMware Solution native services like Managed SNAT, Public IP, and Azure native services such as Azure vWAN Hub and Azure Firewall for default route advertisement. Traversing back to on-premises is also an option for establishing internet connectivity from the Azure VMware Solution. 

This article will discuss the different tools and servies available to implement internet traffic from Azure VMware Solution in a hybrid environment consisting of the Azure VMware Solution private cloud, Azure, and an On-premises data center. Also, this document also discuss how to increase network security, resiliency, and design for scale using Azure Landing Zone best practices.  

## Internet Breakout -  On-Premises 


Lets first look at a basic setup. In Azure VMware Solution, you create a segment(s) and under that segment, you have some VM's that you want to install some packages on from the internet. 

Your segments are attached to the default tier-1 gateway which as a direct path out to the tier-0 edge gateway. 

![image.png](./images/vm_segment.png)

In order to access the internet, a default route, 0.0.0.0/0 must be configured.

The Azure VMware Solution Portal shows that you have 3 options:

![internet_ops.png](./images/internet_ops.png)

One option is to enable the default route from on-premises over a VPN connection. In this scenario, you enable the first option to configure your own default route from on-premises, and have the vpn gateway terminate in an Azure vnet. That same vNet will also have the Azure VMware Solution ExpressRoute circuit gateway as seen below. From there, enable Azure Route Server to dynamically transit from the VPN to ExpressRoute. This is done by enabling Branch to Branch. See: https://learn.microsoft.com/en-us/azure/route-server/Expressroute-vpn-support

![transit.png](./images/vpn.png)

![image.png](./images/vm_segment.png)

In this design, there are several hops required before reaching the internet. To simplify this architecture, rather that a VPN from On-Premises, consider using an Azure ExpressRoute circuit. The ExpressRoute circuit peers with the Azure VMware Solution Managed ExpressRoute circuit using Global Reach https://learn.microsoft.com/en-us/azure/azure-vmware/concepts-networking

![globalreach.png](./images/gr.png)

This however still is not the most direct, low latency option. 

## Managed SNAT

If traversing back to on-premises is not a requirement. Consider using Managed SNAT directly from Azure VMware Solution itself. As the name suggests, this is an Azure VMware Solution managed mechanism to give your Private workloads a Public IP to access the internet for outbound traffic. 

![managedsnat.png](./images/snat.png)
See:https://learn.microsoft.com/en-us/azure/azure-vmware/enable-managed-snat-for-workloads

### Limitations

Please note that this service is for outbound, egress traffic only. Here are some of the additional limitations:

1.) No DNAT: You may have services that require DNAT - For example, if there is a service in Azure that needs to access Azure VMware Solution as it's destination, it won't know how to forward to that address.

2.) Can't natively handle Layer 7: The Managed SNAT has no concepts of HTTP/HTTPS. In order to have this functionality, you will need use a load balancer

3.) Logging: The connection has no concept of logging. No way to see malicious activity, bad actors, or network congestion. 

4.) No Firewall: You can't secure the traffic with Managed SNAT. You can't control TCP/UDP/ICMP without rules to configure

Consideration: Use Managed SNAT for proof of concept evaluations or workloads that don't have these requirements. 

Recommendation: Use Public IP at the NSX edge for a native, scalable, secure solution 

## Public IP at the NSX-T Data Center Edge 

This option gives you more flexibility as it can scale up to over thousands of public IPs and can be used down to the tier 1 gateway. This means the public IP can sit:

- At the Virtual Machine
- At the Load Balancer 
- At a Network Virtual appliance at the NSX Edge

Which gives you flexibility in your design patterns.

![pubip.png](./images/pubip.png)

### Design Considerations:

- Use this option to have a low-latency connection to Azure and need to scale number of outbound connections.
- Leverage firewall for granular rule creation, URL filtering, and TLS Inspection.
- Consider using loadbalancer to evenly distribute traffic to workloads.
- Enable DDoS protection.

## Secured vWAN HUB

This option is for using Azure VWAN Hub to learn routes from AVS statically or dynamically with BGP.  First, lets take the example of a WAN topology. A WAN creates connections between P2P/S2S VPN, ER circuits, mobile devices, amongst other spokes to a centralized location. Azure VMware Solution becomes another spoke off that design and will exchange routes with Secure vWAN Hub dynamically because it speaks BGP. 

![vWAN.png](./images/vwan.png)

Existing vnets in Azure will not be able to peer directly to the vWAN hub, so in order to communicate securely between Azure VMware Solution and workloads, create a Hub vNet where you can deploy an Azure Firewall. 

![vWANarch.png](./images/vwanarch.png)

In this scenario, if you want HTTP/HTTPS traffic to go through this hub and out the internet, you will need to do two things:

	1) Enable WAF/App GW + Azure Firewalls in the hub vnet
	2) Configure rules in Azure Firewall to allow 80/443
  

![vWANandwaf.png](./images/vwanandwaf.png)

In the diagram above, Layer 7 can occur either with the NSX-T Data Center loadbalancer or using the WAF/App Gateway in Azure.

**Note:** Azure Firewall is not a BGP capable device, so you can't route traffic to it through Azure VMware Solution natively. 

### Design Consideration: 
Use vWAN for existing workloads, Hub/Spoke vNets for Azure traffic. You can also deploy Public IP at the NSX-T Data Center Edge for internet traffic for Azure VMware Solution workloads.

### Deploy Azure VWAN

Get started with deploying Azure VWAN [here](Implementation-Options.md#reference-architectures-non-functional---links-in-progress)

## Hub & Spoke with Next-Gen Firewall 

This architecture uses a centralized hub virtual network in Azure with a network virtual appliance. Consider using this architecture  when an existing internet edge device is already configured in Azure which can extend to provide outbound internet to Azure VMware Solution workloads. 
Use ARS to dynamically populate segments from Azure VMware Solution to the Hub network and spokes that are peered to it. 

![hubandspoke.png](./images/hubspoke.png)

https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/dmz/nva-ha?tabs=cli


### DDoS Protection
Consider using WAF with App Gateway for Layer 7 communication and DDoS protection for the hub and spoke networks

![wafappgw.png](./images/wafappgw.png)

### DDoS Protection (In Progress)
Consider using WAF with App Gateway for Layer 7 communication and DDoS protection for the hub and spoke networks

![wafappgw.png](./images/wafappgw.png)

## Next Steps

For next steps on how to implement an end-to-end Azure VMware Solution Landing Zone network architecture, head to [Implementation Options](Implementation-Options.md) to review prerequisites and deployment options.
