# Align to business metrics



##### Service Level Agreements (SLAs)

Availability targets such as Service Level Agreements (SLAs) for Azure VMware Solution application(s) are defined.

Have you got a calculated SLA based upon the key services being used within Azure VMware Solution and the surrounding technologies.

Do you have a Business Impact Analysis (BIA) for DR?	If this exists, it means the customer understands the cost of an outage and the impact of not meeting their SLA (e.g. financial, damage to brand, damage to reputation, loss of life). For customers that do not have a BIA, they really are just following the best effort model.

##### Recovery time objective (RTO)

Recovery targets to identify how long the Azure VMware Solution can be unavailable (Recovery Time Objective) and how much data loss is acceptable during a disaster (Recovery Point Objective) identified.

### Design considerations


- **Critical path dependencies**. Not all components of the solution are equally critical. Have a clear understanding of the dependencies that can take down the system versus others that might lead to degraded experience. The design should harden resiliency of critical components so that impact of outages can be minimized.

- **Scale out and scale in on demand**. The environment should be able to expand and contract based on load. Handle that operations through automation. User input should be kept to a minimum to avoid typical errors caused by human in loop.

How often do you practice your recovery procedures?   If they do test restores, what does that procedure look like?  Do they just restore the contents of a server/datastore and call it good?  Do they actually get the application fully running in a test environment and check it out?

Can you describe how the recovery process would go if an app fails?  A triage process for the most critical apps that covers everything from patch issues to malicious deletement to infrastructure failure?

Do you have trouble backing everything up within prescribed windows?	Backup times that exist past the RTO point need to be addressed.  

How sure are you that everything in your environment that needs to be backed up actually is?	Ensure you have identified all your applications and their dependencies.  



### Design recommendations

-  Create a dependency map that outlines the components that are on the critical path. The map should be actively maintained and regularly checked for changes in the solution.

- Automate expansion and contraction through Infrastructure-as-Code. Repeatable deployments will ensure consistency each time. 



## Core components

Are the core components on which the applications runs. this includes compute, storage, and their operations.

## Initial design

AVS/Azure core infrastructure		You have a clear understanding of the components required to support Azure VMware Solution	Use the Checklist in the Azure VMware Solution Deployment Planning Guide.	10		Go through the learning path in the attached link.  Read the Azure VMware Solution Azure docs published on the web.

Have you considered moving some workloads to Azure native?	Depending on the nature of the workload, migration to an IAAS or PAAS service in Azure may be more cost effective and performant than migrating to Azure VMware Solution.	5		Set up criteria to determine which workloads should be moved to Azure VMware Solution, and which to Azure Native.  Cost, ability to re-IP, capacity, usage patterns should be considered.

Are your user located near the Azure VMware Solution region/regions hosting your SDDC?	Consider the latency of connecting to workloads - some may not be latency senstive, others may be.  Having your users as physically close to the peering location will mean that latency is kept to a minimum.  Also, there is a requirement that if using HCX, the roundtrip latency must be less that 150ms.
Have you designed your workloads to make use of  affinity and anti-affinity policies?	Used to specify affinity or anti-affinity between a group of virtual machines and a group of hosts. An affinity rule specifies that the members of a selected virtual machine DRS group can or must run on the members of a specific host DRS group. An anti-affinity rule specifies that the members of a selected virtual machine DRS group cannot run on the members of a specific host DRS group.
 Are your application auto-scaling based on vertical vs. horizontal scaling?	When sizing for an application, ensure that the vm is sized to handle the largest workload when in an Azure VMware Solution or physical hardware environment. 

 The application can operate with reduced functionality or degraded performance in the case of an outage.	Avoiding failure is impossible in the public cloud, and as a result applications require resilience to respond to outages and deliver reliability. The application should therefore be designed to operate even when impacted by regional, zonal, service or component failures across critical application scenarios and functionality.

 Follow the high-availability /reslilience guidance provided by Microsoft to reduce the possibility of an application outage.

Impact: Performance


##### Compute

Do you have VMware Anti Affinity rules in place to keep VMs apart in event of host failures?	If your VMs operate in a HA or clustered fashion within Azure VMware Solution, it is advisable to create anti-affinity rules to keep your VMs apart and on seperate hosts.

Have you adequately sized your deployment to handle node failures without affecting your overall uptime?	If a node becomes unavailable and a node replacement process starts, how will this affect your overall workload?

If you are using a stretched cluster or active/active or active/passive setup, do you have enough capacity to continue to run your service in the event of active/passive cluster failure?	You need to ensure that there is enough tolerance within the overall design to cater for a complete cluster failure

Impact: Reliability

##### Storage

Have you verified that vSAN Storage Policies are in place that meet corporate standards?	While the Default Storage Policy in Azure VMware Solution is redundant, If your machines require that data be copied to additional vSAN nodes, another policy should be created to ensure that the data meets your enhanced redundancy requirements.

Impact: Reliability


Do you need additional storage for you Azure VMware Solution environment? 	Azure NetApp Files can be connected as an additional datastore attached  for the Azure Vmware solution. 

Going through an application assessment will help determine the optimal combination of Azure VMware Solution Nodes and external storage like Azure NetApp Files.

Are you using thick and thin provisioning storage policies?	The default storage policy in Azure VMware Solution is thick, be sure to change it to thin for higher VM density, and track IO utilization.




Impact: Peformance

Azure services that interact with AVS are in the same zone as AVS	Ensure that Azure services that interac with AVS are in the same zone where AVS is deployed.  If all or part of the application is highly sensitive to latency it may mandate component co-locality which can limit the applicability of multi-region and multi-zone strategies.	15		This will reduce latency so applications will respond more quickly.  Critical for ANF based data store expansions.


### Design recommendations




## Back up 

Backup tools are in place and confirmed to work with Azure	A key principle of Azure VMware Solution is to enable you to continue to use your investments and your favorite VMware solutions running on Azure. Independent software vendor (ISV) technology support, validated with Azure VMware Solution.  Understand the partners and options available to you is critical to your backup success.	20		Use Microsoft supported back up solutions like MABS, or approved 3rd party vendors.

#### guest workloads

You are storing your backups in a different region	To protect against the unlikely event of a prolonged regional outage, you can protect your workloads by replicating them to an alternative Azure region.

## Disaster recovery strategy

Can you describe your backup and recovery infrastructure at a high level?	Looking for a high level description like "we use Commvault to push backups of everything to a DataDomain which then replicates to a DataDomain in our DR site".  

Do you have a Business Impact Analysis (BIA) for DR?	If this exists, it means the customer understands the cost of an outage and the impact of not meeting their SLA (e.g. financial, damage to brand, damage to reputation, loss of life). For customers that do not have a BIA, they really are just following the best effort model.

Do you use a DR Automation system or manual Runbooks?	Ask about the number of runbooks the customer has and dig to see if they understand their application dependency mapping. 

Site Recovery Manager is currently being used on-premises?	SRM is a disaster recovery solution designed to minimize downtime of the virtual machines in an Azure VMware Solution environment if there was a disaster. SRM automates and orchestrates failover and failback, ensuring minimal downtime in a disaster. Also, built-in non-disruptive testing ensures your recovery time objectives are met. Overall, SRM simplifies management through automation and ensures fast and highly predictable recovery times.

You are using an Azure validated backup application	Using a validated disaster recovery solution will ensure you get support from Microsoft and the Vendor together should you ever encounter a disaster.

Your failover architecture is  local to a region 	Understand your options if your  applications are architected for logal, regional or inter-regional availability.
Your failover architecture is inter-regional	Understand your options if your  applications are architected for local, regional or inter-regional availability.


### Establish Baseline performance

* Use tools to benchmark existing environment before starting migration to Azure VMware Solution SDDC. [VMware vRealize Operations](/azure/azure-vmware/vrealize-operations-for-azure-vmware-solution), [Perfmon](/message-analyzer/perfmon-viewer), [iostat](https://linux.die.net/man/1/iostat) are some of the common utilities that can be used for establishing baseline performance.
* Use [performance-based assessment](/azure/migrate/best-practices-assessment#sizing-criteria) when estimating Azure VMware Solution SDDC capacity.


### Debugging and troubleshooting tools

* Familiarize with following debugging and troubleshooting tools. These tools are indispensible for identifying potential performance bottleneck(s) quickly.
  * [Azure Network Watcher](/azure/network-watcher/network-watcher-monitoring-overview)
  * [KQL](/azure/data-explorer/kusto/query/tutorials/learn-common-operators?pivots=azuremonitor)
  * [PSPing](/sysinternals/downloads/psping)

### Defining and tracking metrics

* Use [Auto-scale for Azure VMware Solution](https://github.com/Azure/azure-vmware-solution/tree/main/avs-autoscale) to define performance metrics to be used for scale-in or scale-out operations in Azure VMware Solution cluster nodes.
