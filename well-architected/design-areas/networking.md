# Azure VMware (AVS) networking considerations

## Load Distribution 

Impact: Reliability

Load balancing the Azure VMware Solution allows for the distribution of traffic through various algorithms such as performance and weight to make sure incoming traffic is divided  to improve
both the scale and reliability of the workload applications. 

Consider using a load balancer such as NSX Advanced Loadbalancer  for even distribution of both internal and external facing application gateways for routing, application delivery, and SSL termination.
You may also deploy an Azure Loadbalancer natively in Azure Application Gateway,  which provides similar functionality to enhance application performance. 

If your AVS deployment spans multiple Azure Availability Zones, Azure Load Balancer can distribute traffic across those zones, providing high availability and fault tolerance.

## Global distribution and Content Delivery 

## Isolation boundaries

Network security groups (NSG) are used to isolate and protect traffic within the workloads VNet. 	An Azure native service that is part of a complete zero trust pattern.	5		Use NSG or Azure Firewall to protect and control traffic within VNETs


## IP planning

Azure VMware Solution and Cloud virtual networks are designed for growth based on an intentional subnet security strategy. 	An IP addressing tool is in place and allocation is being enforced.	10		Design virtual networks for growth
