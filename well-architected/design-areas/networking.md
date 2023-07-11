# Network Considerations for the Azure VMware Solution
## Traffic Distribution 

#### Impact: _Reliability_

### Load Distribution and High Availability
Load balancing the Azure VMware Solution allows for the distribution of traffic through various algorithms such as performance and weight to make sure incoming traffic is divided  to improve
both the scale and reliability of the workload applications. 

### Recommendation
- Use a load balancer such as NSX Advanced Loadbalancer for even distribution of internal and external facing application gateways for routing, application delivery, and SSL termination.
- For workloads that extend into Azure, use Azure Application Gateway, which provides similar functionality to enhance application performance, plus IDPS and Web Application Firewall (WAF) capabilities. Azure Load Balancer can distribute traffic across those zones, providing high availability and fault tolerance for workloads that span multiple Azure Availability Zones.

### Assessment questions 
- How is traffic to the workload distributed?

### Global Distribution 

For applications with a Global presence, it's important to route traffic to the nearest Azure VMware Solution SDDC to minimize the distance between the instances and the users. 

### Recommendation 
- For applications that span multiple regions, consider deploying a DNS-based global traffic load balancing solution such as Azure Traffic Manager


## Content Delivery


### Assessment questions 
- Does the application require a global presence?

#### Impact: _Performance_

Using a Content Delivery Network (CDN) in conjunction with the Azure VMware Solution assists in optimizing the retrieval and distribution of static and dynamic assets for the application through caching. 

### Recommendation
Place your content behind Azure CDN to improve responsiveness and reduce latency for those accessing the applications and websites.

### Assessment questions 
- How is retrieving static assets from the website or application optimized?
- Does the application infrastructure span multiple regions?

## Network Security

### Internet Facing workloads 
Workloads in the Azure VMware Solution can be front-facing, meaning they get mapped to a Public IP, can be exposed to the internet, and accept incoming connections from external sources. However, this association with your VM or load balancer does pose risks to the workloads. 

### Recommendation 

 - For Internet-facing applications, use a firewall (e.g. Azure Firewall) to inspect AVS traffic coming into Azure VNET.
 - Make sure the firewall has rules and access control lists (ACL's) to restrict and filter inbound traffic
   


### Securing traffic between internal workloads
#### Impact: _Security_

Implementing network isolation through segmentation and using virtual LANs (VLANs) aids in preventing unauthorized access between different components of the AVS environment. Network security groups (NSG) are used to isolate and protect traffic within the workloads VNet.

### Recommendation 
 - Use NSGs to restrict further traffic to VMs and other application components  vnets, subnets, and traffic from AVS.  

Also, create segments and VLANs for your AVS workloads. Create firewall rules within NSX-T.

### Assessment questions 
- How is access to front-facing AVS workload segments secured? 

- How is internal communication between segments secured? 

## IP planning
#### Impact: _Security_, _Operational Excellence_
Azure VMware Solution and Cloud virtual networks are designed for growth based on an intentional subnet security strategy. 	An IP addressing tool is in place and allocation is being enforced.	10		Design virtual networks for growth. 

In addition to a /22 RFC-1918, workload segments will have separate non-conflicting CIDR ranges. Plan to have enough IPs for
- virtual machines
- Public IPs
- and load balancers

### Recommendations
- Ensure the IP address range is large enough to accommodate all current and future workloads in the  Azure VMware Solution.
- Efficiently organize available IPs using a spreadsheet and or IP address management (IPAM) tool to avoid. A mechanism to track IPs will help track IP usage and avoid IP conflicts. 
- Plan for potential increases in devices, segments, or subnets so that the IP addressing scheme can handle the additional demands.

#### Assessment questions 
- How are IP addresses spaced, planned, and segmented?

## Next steps

The next section visits how to securely establish connectivity, create perimeters for your workload, and evenly distribute traffic to the application workloads.

> [!div class="nextstepaction"]
> [Networking](./networking.md)



