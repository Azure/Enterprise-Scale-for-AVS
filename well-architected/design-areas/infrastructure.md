# Azure VMware Solution Well-Architected Framework: Infrastructure & Provisioning 

This section refers to the foundational layer of the Azure VMWare Solution offering that supports the operations and services running the applications such as compute, storage, and their operations.

## Introduction  

#### Impact: _Performance_, _Operational Excellence_


For deploying the Azure VMware Solution, there must be a general understanding of the components required to support the Azure VMware Solution. Another aspect to consider is the latency of connecting to workloads as some may not be latency-sensitive.  Having users physically close to the peering location will mean minimal latency. For example, there is a requirement that if using HCX, the roundtrip latency must be less than 150ms.

Also, ensure that AVS is the right choice for your infrastructure deployment. Consider assessing Azure native solutions prior to moving to the Azure VMware Solution. 

Organizing infrastructure deployments using Infrastructure and Code (IaC) enables more efficient infrastructure provisioning by reducing manual error and facilitating the adoption of DevOps principles in infrastructure management. Infrastructure updates can be made through code modifications, reducing the time and effort required for manual configuration and provisioning.

Lastly, it may be more appropriate for a work to migrate to an IAAS or PAAS service in Azure may be more cost-effective and performant than migrating to Azure VMware Solution. 

### Recommendations 
- Use the Azure VMware Solution Deployment Planning Guide Checklist and read the Azure VMware Solution Azure docs published online.
- Set up criteria to determine which workloads should be moved to Azure VMware Solution and which to Azure Native, considering cost, ability to re-IP capacity, and usage patterns.
- Create a dependency map that outlines the components on the critical path. The map should be actively maintained and regularly checked for changes in the solution.
- Automate expansion and contraction through Infrastructure-as-Code. Repeatable deployments will ensure consistency each time.





### Assessment Questions 
- Have you considered moving some workloads to Azure Native?
- Are users located near the Azure VMware Solution region/regions hosting your SDDC?
- Are there dependency maps showing application flows, communication path, dependencies, and infrastructure component?
- Is the infrastructure deployed using Infrastructure as Code (e.g Bicep, Terraform, Puppet, etc)?

## High Availability 
#### Impact: _Reliability_


When sizing for an application, ensure the VM is sized to handle the workload at peak performance.  The application should be also able to operate with reduced functionality or degraded performance in the case of an outage.	In the event of a failure event, design for resilience to respond to outages and deliver reliability. The application should therefore be designed to operate even when impacted by regional, zonal, service, or component failures across critical application scenarios and functionality. One way to do so is by configuring affinity rules. By configuring affinity rules, administrators have more control over VM placement and can ensure that VMs are distributed in a manner that aligns with specific requirements, performance considerations, availability needs, or licensing constraints. 


### Recommendations 
- When a low-latent communication path is required from VM to VM, use affinity rules so that they live on the same hosts
- When VM's supporting the application need fault tolerance or to optimize host performance through resource distribution, use VM to VM affinity. 
- Follow the high-availability /resilience guidance provided by Microsoft to reduce the possibility of an application outage.
- For VMs deployed with HA or clustering within the Azure VMware Solution, it is highly recommended to create anti-affinity rules to keep your VMs apart and on separate hosts.

### Assessment questions

- Is application auto-scaling based on vertical and or horizontal scaling?
- Are workloads designed to make use of  affinity and anti-affinity policies?
- Are Anti-Affinity rules in place to keep VMs apart in the event of host failures?


## Compute and Storage
#### Impact: _Reliability_, _Performance_

While the Default Storage Policy in Azure VMware Solution is redundant, If your machines require that data be copied to additional vSAN nodes, another policy should be created to ensure that the data meets your enhanced redundancy requirements.
When you plan to exceed the storage in the SDDC, Azure NetApp Files (ANF) in AVS is another solution that will expand disk allocation and  provide a high-performance, low-latency, scalable storage platform. ANF dynamically adjusts the storage capacity and performance tiers based on the workload needs so that the AVS environment can scale as your storage requirements grow.

Azure services (such as ANF) that interact with AVS are in the same zone as AVS	Ensure that Azure services that interact with AVS are in the same zone where AVS is deployed.  If all or part of the application is highly sensitive to latency, it may mandate component co-locality, limiting the applicability of multi-region and multi-zone strategies.	Doing so will reduce latency, so applications will respond more quickly.  An example is when using an ANF-based datastore where colation is critical for disk expansions.

### Recommendation
- 	Azure NetApp Files can be connected as an additional datastore attached  for the Azure Vmware solution. Going through an application assessment will help determine the optimal combination of Azure VMware Solution Nodes and external storage like Azure NetApp Files.
- Co-locate the application and service tiers by making sure the application, and database, and storage tiers are in the same availability zone.


### Assessment questions
- If a node replacement process starts, will this affect your overall workload?
- If  using a stretched cluster(s) in an active/active or active/passive setup, do you have enough capacity to continue running your service in the event of active/passive cluster failure?	
- Are there vSAN Storage Policies that meet corporate standards?
- Are there thick and/or thin provisioning storage policies in use?	
- Do you need additional storage for the Azure VMware Solution environment?


## Business Continuity and Disaster Recovery 
The SDDC should have protection against data loss, minimizes downtime, and maintain the continuity of operations when there are unexpected disruptions or disasters. 

### Service Level Agreements (SLAs)

Availability targets such as Service Level Agreements (SLAs) for Azure VMware Solution application(s) are defined for your platform and should be in place.


 
## Recovery time objective (RTO)

Recovery targets to identify how long the Azure VMware Solution can be unavailable (Recovery Time Objective) and how much data loss is acceptable during a disaster (Recovery Point Objective) identified.

### Design considerations


- **Critical path dependencies**. Not all components of the solution are equally critical. Clearly understand the dependencies that can take down the system versus others that might lead to degraded experience. The design should harden the resiliency of critical components to minimize the impact of outages.

- **Scale out and scale in on-demand**. The environment should be able to expand and contract based on load. Handle those operations through automation. User input should be kept to a minimum to avoid typical errors caused by human in loop.


### Assessment questions

- Have you got a calculated SLA based on the key services being used within Azure VMware Solution and the surrounding technologies?

- How often do you practice your recovery procedures?   If they do test restores, what does that procedure look like?  Do they just restore the contents of a server/datastore and call it good?  Do they actually get the application fully running in a test environment and check it out?

- Can you describe how the recovery process would go if an app fails?  A triage process for the most critical apps that covers everything from patch issues to malicious element to infrastructure failure?

- Do you have trouble backing everything up within the prescribed windows?	Backup times that exist past the RTO point need to be addressed.  

- Are there methods in place to ensure backups are occurring?	Ensure you have identified all your applications and their dependencies.
- Do you have a Business Impact Analysis (BIA) for DR?	If this exists, it means the customer understands the cost of an outage and the impact of not meeting their SLA (e.g., financial, damage to brand, damage to reputation, loss of life).


## Back up 

Backup tools are in place and confirmed to work with Azure	A key principle of Azure VMware Solution is to enable you to continue using your investments and your favorite VMware solutions running on Azure. Independent software vendor (ISV) technology support, validated with Azure VMware Solution.  Understanding the partners and options available to you is critical to your backup success.	20		Use Microsoft-supported backup solutions like MABS or approved 3rd party vendors.

SRM is a disaster recovery solution designed to minimize downtime of the virtual machines in an Azure VMware Solution environment if there is a disaster. SRM automates and orchestrates failover and failback, ensuring minimal downtime in a disaster. Also, built-in non-disruptive testing ensures your recovery time objectives are met. Overall, SRM simplifies management through automation and ensures fast and highly predictable recovery times.

### Recommendations
In the event of a prolonged regional outage, workloads protect the workloads by replicating them to an alternative Azure region.

### Assessment Questions

- Are backups stored in a different region	To protect a regional disaster? 
- Is there a clear understanding of backup and recovery infrastructure exists?
- Are there Disaster Recovery Automation systems or manual Runbooks?
- Is Site Recovery Manager is currently being used on-premises?
- Is there an Azure-validated backup application in place? 
- You are using an Azure-validated backup application	Using a validated disaster recovery solution will ensure you get support from Microsoft and the Vendor together should you ever encounter a disaster.


### Establish Baseline performance

#### Impact _Operational_Excellence_

For detailed coverage of Infrastructure Monitoring, see the [Monitoring](./monitoring.md) section
* Use tools to benchmark the existing environment before starting the migration to Azure VMware Solution SDDC. [VMware vRealize Operations](/azure/azure-vmware/vrealize-operations-for-azure-vmware-solution), [Perfmon](/message-analyzer/perfmon-viewer), [iostat](https://linux.die.net/man/1/iostat) are some of the common utilities that can be used for establishing baseline performance.
* Use [performance-based assessment](/azure/migrate/best-practices-assessment#sizing-criteria) when estimating Azure VMware Solution SDDC capacity.


### Debugging and troubleshooting tools

* Familiarize with following debugging and troubleshooting tools. These tools are indispensible for identifying potential performance bottleneck(s) quickly.
  * [Azure Network Watcher](/azure/network-watcher/network-watcher-monitoring-overview)
  * [KQL](/azure/data-explorer/kusto/query/tutorials/learn-common-operators?pivots=azuremonitor)
  * [PSPing](/sysinternals/downloads/psping)

### Defining and tracking metrics

* Use [Auto-scale for Azure VMware Solution](https://github.com/Azure/azure-vmware-solution/tree/main/avs-autoscale) to define performance metrics to be used for scale-in or scale-out operations in Azure VMware Solution cluster nodes.

## Next steps

Now that we've taken a look at the underlying platform, lets investigate further into the application platform (e.g databases, vms, operating systems, and configurations)
> [!div class="nextstepaction"]
> [Application Platform](./application-platform.md)
