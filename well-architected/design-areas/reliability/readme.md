# Azure VMware Solution Well-Architected Framework: Reliability Planning and Design Guidance


## Service Level Agreements and Objectives 

In the shared responsibility model, an organization primarily manages and operates workloads, while Microsoft manages the Azure VMware Solutions physical and virtual infrastructure. 

The overall SLA includes availability targets, such as Service Level Agreements (SLA), and Recovery targets, such as Recovery Time Objectives (RTO) and Recovery Point Objectives (RPO), which should be defined and tested to ensure Azure VMware Solution application reliability aligns with business requirements.

SLAs for each application and its dependencies should be clearly defined. The Azure VMware Solution SLA is only a part of the reliability, and  other services will affect the overall SLA.
Maximum time to recover an application in the event of an outage, regardless of the nature of the outage.
Categorizing applications by  defined Business Continuity tiers will assist the overall BCDR strategy.  Every application should be assigned to a Tier, and be sure to look at application dependencies to ensure cross-tier services map to the lower tier.

## Infrastructure Resiliency

### Compute and Storage 
Knowing when a node becomes unavailable, and a node replacement process starts is important. Also, how will this affect the overall workload? 
Please ensure enough tolerance within the overall design to cater to a complete cluster failure.

While the Default Storage Policy in Azure VMware Solution is redundant, if virtual machines require that data be copied to additional vSAN nodes, another policy should be created to ensure that the data meets your enhanced redundancy requirements. Suppose your VMs operate in a HA or clustered fashion within Azure VMware Solution. In that case, it is advisable to create anti-affinity rules to keep your VMs apart and on separate hosts.
 

### Networking

#### HCX 
When using HCX extended networks, the extenders, by default, are deployed in a single instance model. To increase the resiliency of the implementation, be sure to implement the network extender appliances in a "high-available" configuration as part of HCX service mesh deployment.

#### Expressroute 
A zone outage could affect your connectivity if your ExpressRoute is connected to a gateway not deployed in a zonal-aware configuration.

## Recoverability 

### Design for Recoverability
Understand your options for recoverability, whether the applications are architected for local, regional, or inter-regional availability.
Using a validated disaster recovery solution will ensure you get support from Microsoft and the Vendor together should you ever encounter a disaster.
Replicating them to an alternative Azure region to protect against the unlikely event of a prolonged regional outage, 
Using a validated disaster recovery solution will ensure you get support from Microsoft and the Vendor together should you ever encounter a disaster.

### Backups
Backups can be stored locally in Azure VMware Solution (not recommended), on Azure disk in the same region, or a different region (preferred).   Select the best option for your data based on the application's SLAs.  Microsoft Backup Server (MABS) is available today, and Microsoft cloud-native backup is expected by the end of CY23Q2.  There are also several 3rd party backup services available.
Inter-regional storage is equivalent to off-site backups.  This is Microsoft's recommended pattern.

For Azure VMware Solution environment, SRM, or a third-party application. Alternatively, Azure Site Recovery can protect workloads running in Azure VMware Solution by replicating VMs to an Azure Native disaster recovery site.

### Operations for Application Recovery 
It is important to perform backups and ensure that applications can be up and fully operational from the backup restores. 
A triage process that lists roles, responsibilities, and operations required in the application recovery process. 
A reliable backup must meet a certain RTO point and need to be assessed if they go past that time.  
Ensure you have identified all your applications and their dependencies. This can be in the form of runbooks and application dependency mapping. 

Listen for daily/weekly/quarterly/yearly backups. Listen for DB log shipping to a remote site for the most critical databases with some log marker and 24-hour or 48-hour delay. Listen for backups that happen every 1/2/4/8 hours - these are candidates for DB log replication to a remote site and/or backup from the read-only DB node in a cluster.

If a DR were to occur today, could you meet your SLAs?
Looking for a high-level description like "we use Commvault to push backups of everything to a DataDomain, which then replicates to a DataDomain in our DR site."  
If this exists, it means the customer understands the cost of an outage and the impact of not meeting their SLA (e.g., financial, damage to the brand, damage to reputation, loss of life). For customers that do not have a BIA, they are just following the best-effort model.
Listening for typical disaster scenarios like natural disasters, man-made disasters, malicious attacks/ransomware, disgruntled employee, accidental mistake, etc. 
