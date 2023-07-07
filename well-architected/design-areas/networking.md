# Azure VMware (AVS) networking considerations

## Load Distribution 

#### Impact: _Reliability_

Load balancing the Azure VMware Solution allows for the distribution of traffic through various algorithms such as performance and weight to make sure incoming traffic is divided  to improve
both the scale and reliability of the workload applications. 

### Recommendation
Use a load balancer such as NSX Advanced Loadbalancer  for even distribution of internal and external facing application gateways for routing, application delivery, and SSL termination.
You may also deploy a  Loadbalancer natively in with Azure Application Gateway, which provides similar functionality to enhance application performance. 

If the AVS deployment spans multiple Azure Availability Zones, Azure Load Balancer can distribute traffic across those zones, providing high availability and fault tolerance.

If the application spans multiple regions, consider deploying a DNS-based global traffic load balancing solution such as Azure Traffic Manager

### Assessment questions 
- How is traffic to the workload distributed?
## Global distribution and Content Delivery 

#### Impact: _Performance_

Using a Content Delivery Network (CDN) in conjunction with the Azure VMware Solution assists in optimizing the retrieval and distribution of static and dynamic assets for the application through caching. 

### Recommendation
Place your content behind Azure CDN to improve responsiveness and reduce latency for those accessing the applications and websites.

### Assessment questions 
- How is retrieving static assets from the website or application optimized?
- Does the application infrastructure span multiple regions?

## Isolation boundaries

#### Impact: _Security_

Implementing network isolation through segmentation and  using virtual LANs (VLANs) aids in preventing unauthorized access between different components of the AVS environment.

### Recommendation 
Network security groups (NSG) are used to isolate and protect traffic within the workloads VNet. 	An Azure native service that is part of a complete zero trust pattern.	5		Use NSG or Azure Firewall to protect and control traffic within VNETs. 

Also, create segments and VLANs for your AVS workloads. Create firewall rules within NSX-T.

### Assessment questions 
- How is access to front-facing AVS workload segments secured? 

- How is internal communication between segments secured? 

## IP planning
#### **Impact**: _Infrastructure_
Azure VMware Solution and Cloud virtual networks are designed for growth based on an intentional subnet security strategy. 	An IP addressing tool is in place and allocation is being enforced.	10		Design virtual networks for growth. 

Remember that in addition to a /22 RFC-1918, workload segments will have separate non-conflicting CIDR ranges. Make sure to plan to have enough IPs for
- virtual machines
- Public IPs
- and load balancer


### Assessment questions 
- How are IP addresses spaced, planned, and segmented?







