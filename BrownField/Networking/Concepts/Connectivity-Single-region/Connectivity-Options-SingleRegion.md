---
title:  Outbound Connectivity Options - Single Region
author: Sabine Blair
ms.author: sablair
ms.date: 12/8/2022
ms.topic: conceptual
ms.service: cloud-adoption-framework
ms.subservice: ready
ms.custom: internal
---

# Introduction

AVS has many options for connectivity such as AVS native services like Managed SNAT and Public IP as well as Azure native services such as Azure VWAN Hub and Azure Firewall. Traversing back to on-prem is also an option. Without a one-size fits all solution, how do you know which architecture is best for your environment?

This blog will talk about the different tools and servies available to have internet flows from AVS. In addition to that, we'll also discuss how to "level up" your architecture using ALZ concept to build a more secure, resilient, scalable design. 

## Default Route from On-Premises
Lets first look at a basic setup. In AVS, you create a segment(s) and under that segment, you have some VM's that you want to install some packages on from the internet. 

Your segments are attached to the default tier 1 which as a direct path out to the tier-0. 
![image.png](./images/vm_segment.png)
The problem is, you haven't configured your default route, 0.0.0.0/0 (aka quad-0).

The AVS Portal shows that you have 3 options. Use the two native options, or something else. 
![internet_ops.png](./images/internet_ops.png)

So let's say you choose to advertise the default route from on-premises over VPN. So from on-premises, your vpn terminates in a vnet. That vnet also has the AVS Expressroute circuit gateway. From there, you enable Azure Route Server to dynamically transit from the vpn to expressroute. This is done by enabling Branch to Branch.
![transit.png](./images/vpn.png)

From AVS, this is a lot of hops. To simplify this architecture, rather that a VPN from On-Premises, you can leverage Expressroute. You can peer the Expressroute circuit with AVS's Expressroute circuit using Global Reach 

![globalreach.png](./images/gr.png)

This however still is not the most direct, low latent option. 

## Managed SNAT
If traversing back to on-prem is not a requirement. Consider using Managed SNAT directly from AVS itself. As the name suggest, this is an AVS managed mechanism to give your Private workloads a Public IP to access the internet

![managedsnat.png](./images/snat.png)

Now here are some of the caveats. 
1.) No DNAT: You may have services that require DNAT - For example, if there is a service in Azure that needs to access a DMZ in AVS, AVS is now the destination, and a service is trying to access it via a public IP, however, that is not possible as AVS won't know how to translate that address

2.) Can't natively handle L7: The Managed SNAT has no concepts of HTTP/HTTPS. In order to have this functionality, you will need use a load balancer

3.) Logging: The connection has no concept of logging. No way to see malicious activity, bad actors, network constraints…zilch

4.) No Firewall: You can't secure the traffic with Managed SNAT. You can't control TCP/UDP without rules to configure

Consideration: Use Managed SNAT for POC or workloads that don't have these requirements. 
Recommendation: Use Public IP at the NSX edge for a native, scalable, secure solution 

## Public IP at the NSX Edge 

This option gives you more flexibility as it can scale up to over thousands of public IP's and can be used down to the tier 1. This means the public IP can sit
	- At the Virtual Machine
	- At the Load Balancer 
	- At a Network Virtual appliance at the NSX Edge

Which gives you flexibility in your design patterns.

![pubip.png](./images/pubip.png)

### Design Considerations:

Use this option to have a low-latent connection to Azure and need to scale number of outbound connections
Leverage firewall for granular rule creation, URL filtering, and TLS Inspection  
Consider using loadbalancer to evenly distribute traffic to workloads 
Enable DDOS protoection 

## Secured VWAN HUB

So we've covered the simplest use case for integrating AVS with Azure and enabling workloads to have internet connectivity. You may however have a requirement to have your default route and/or traffic flows go through Azure. Lets take the example of a customer who has a WAN

![vwan.png](./images/vwan.png)

In this scenario, we have customers leveraging a WAN. This gives them access use P2P/S2S VPN, ER circuits, mobile devices all to a centralized place. AVS then because another spoke off that design and will integrate with the Secure VWAN Hub because it speaks BGP. 
Now you're existing vnets in Azure can not peer directly. So, if you need to communicate securely between AVS and workloads, create a hub vnet where you can deploy azure Firewall. 

![vwanarch.png](./images/vwanarch.png)

In this scenario, if you want HTTP/HTTPS traffic to go through this hub and out the internet, you will need to do two things

	1) Enable WAF/App GW
	2) Enable an NVA

![vwanandwaf.png](./images/vwanandwaf.png)

In the diagram above, L7 can occur either with the NSX-T loadbalancer or using WAF/App Gateway in Azure.

**Note:** Azure Firewall is not a BGP capable device, so you can't route traffic to it through AVS natively. 

### Design Consideration: 
Use VWAN for existing workloads, Hub/Spoke VNET's for Azure traffic, and deploying Public IP at the NSX-Edge 

If you don't need a WAN and can use a third party, BGP capable device in a central hub network topology, that then brings us to our next architecturev

## Hub & Spoke with Next-Gen Firewall 
![hubandspoke.png](./images/hubspoke.png)