# Azure VMware (AVS) networking considerations

## Load Distribution 

#### Impact: Reliability

Load balancing the Azure VMware Solution allows for the distribution of traffic through various algorithms such as performance and weight to make sure incoming traffic is divided  to improve
both the scale and reliability of the workload applications. 

Consider using a load balancer such as NSX Advanced Loadbalancer  for even distribution of both internal and external facing application gateways for routing, application delivery, and SSL termination.
You may also deploy an Azure Loadbalancer natively in Azure Application Gateway,  which provides similar functionality to enhance application performance. 

If your AVS deployment spans multiple Azure Availability Zones, Azure Load Balancer can distribute traffic across those zones, providing high availability and fault tolerance.

## Global distribution and Content Delivery 
#### Impact: Performance

Using a Content Delivery Network (CDN) in conjunction with the Azure VMware Solution assists in optimizing the retrieval and distribution of static and dynamic assets for the application through caching. 

Consider placing your content behind Azure CDN to improve responsiveness and reduce latency for those accessing the applications and websites.

 

## Isolation boundaries

#### Impact: Security

Network security groups (NSG) are used to isolate and protect traffic within the workloads VNet. 	An Azure native service that is part of a complete zero trust pattern.	5		Use NSG or Azure Firewall to protect and control traffic within VNETs. 

Also, create segments and VLANs for your AVS workloads. Create firewall rules within NSX-T.


## IP planning

Azure VMware Solution and Cloud virtual networks are designed for growth based on an intentional subnet security strategy. 	An IP addressing tool is in place and allocation is being enforced.	10		Design virtual networks for growth. 

Remember to that in addition to a /22 RFC-1918, that workload segments will have separate non-conflicting CIDR ranges. Make sure to plan to have enough IP's for
- virtual machines
- Public IP's
- and load balancer



