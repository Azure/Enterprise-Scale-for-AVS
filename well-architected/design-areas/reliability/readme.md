# Azure VMware Solution Well-Architected Framework: Reliability Planning and Design Guidance

In the shared responsibility model, an organization primarily manages and operates workloads, while Microsoft manages the Azure VMware Solutions physical and virtual infrastructure. 

## Service Level Agreements and Objectives 

The overall SLA includes availability targets, such as Service Level Agreements (SLA), and Recovery targets, such as Recovery Time Objectives (RTO) and Recovery Point Objectives (RPO), which should be defined and tested to ensure Azure VMware Solution application reliability aligns with business requirements.

SLAs for each application and its dependencies should be clearly defined. The Azure VMware Solution SLA is only a part of the reliability, and  other services will affect the overall SLA.
Maximum time to recover an application in the event of an outage, regardless of the nature of the outage.
Categorizing applications by  defined Business Continuity tiers will assist the overall BCDR strategy.  Every application should be assigned to a Tier, and be sure to look at application dependencies to ensure cross-tier services map to the lower tier.
## Operations 

## Infrastructure Resiliency

### Compute and Storage 
Knowing when a node becomes unavailable, and a node replacement process starts is important. Also, how will this affect the overall workload? 
Ensure enough tolerance within the overall design to cater to a complete cluster failure.

While the Default Storage Policy in Azure VMware Solution is redundant, if virtual machines require that data be copied to additional vSAN nodes, another policy should be created to ensure that the data meets your enhanced redundancy requirements. Suppose your VMs operate in a HA or clustered fashion within Azure VMware Solution. In that case, it is advisable to create anti-affinity rules to keep your VMs apart and on separate hosts.
 

### Networking

#### HCX 
When using HCX extended networks, the extenders, by default, are deployed in a single instance model. To increase the resiliency of the implementation, be sure to implement the network extender appliances in a "high-available" configuration as part of HCX service mesh deployment.

#### Expressroute 
A zone outage could affect your connectivity if your ExpressRoute is connected to a gateway not deployed in a zonal-aware configuration.

## Recoverability 

Understand your options for recoverability, whether the applications are architected for local, regional, or inter-regional availability.
Using a validated disaster recovery solution will ensure you get support from Microsoft and the Vendor together should you ever encounter a disaster.
Replicating them to an alternative Azure region to protect against the unlikely event of a prolonged regional outage, 
Using a validated disaster recovery solution will ensure you get support from Microsoft and the Vendor together should you ever encounter a disaster.

