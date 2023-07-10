# Azure VMware Solution Well-Architected Framework: Infrastructure & Provisioning 

The Infrastructure section refers to the foundational layer of the Azure VMWare Solution offering that supports the compute, storage, and networking capabilities required to run VMware workloads efficiently and reliably. This section also details using the Software Defined Data Center (SDDC) stack, which includes VMware vSphere, vCenter Server, NSX-T, and vSAN, to address areas such as resilience, security, scalability, automation, and disaster recovery.

## Choice of hosting platform

#### Impact: _Performance_, _Operational Excellence_


Before deploying the workload, there must be a general understanding of the components required to support the Azure VMware Solution. This includes putting careful consideration into the workload's characteristics, resources, and scale requirements. These factors make up the overall cluster design. Also, ensure that AVS is the right choice for your infrastructure deployment. There are scenarios where migrating workloads to an IaaS or PaaS service in Azure may be more cost-effective and performant than migrating to Azure VMware Solution. 
#### Assessment Question

Have you considered Azure Native PaaS or IaaS solutions before migrating workloads to the Azure VMware Solution?



### Recommendations 
- Assess Azure native solutions before moving to the Azure VMware Solution. 
- Use the Azure VMware Solution Deployment Planning Guide Checklist and read the Azure VMware Solution Azure docs published online.
- Set up criteria to determine which workloads should be moved to Azure VMware Solution and which to Azure Native, considering cost, ability to re-IP capacity, and usage patterns.

## Clustering and Provisioning

When provisioning infrastructure in the SDDC, the primary focus is on the hosts, which are the underlying compute and storage for the virtual machine.  Clustering is concerned with creating logical groupings of hosts to provide advanced management and availability features. Once the hosts are provisioned, you can create and configure vSphere clusters within the AVS environment to manage VMs and provide compute capabilities.

### Fault Tolerance

A stretched cluster primarily relates to  computing resource distribution across fault domains or availability zones. Another aspect to consider is the latency of connecting to workloads, as some may not be latency-sensitive. 

#### Assessment Questions 
- If  using a stretched cluster(s), do you have enough capacity to continue running your service in the event of active/passive cluster failure?

#### Recommendations
- Use stretched clusters for high-availability
- Co-locate the application and service tiers by ensuring the application, database, and storage tiers are in the same availability zone.

### Region Selection and Application Placement

Region selection is important because it ensures users are near the solution. Having users physically close to the peering location will mean minimal latency. For example, there is a requirement that if using HCX, the roundtrip latency must be less than 150ms.

### Assessment Questions 
- Are users located near the Azure VMware Solution region(s) hosting your SDDC?

### Recommendations

- Choose the Azure region for deploying the AVS cluster carefully by considering the proximity to your users or other resources, network connectivity options, and latency requirements.
- Select a region closer to the users or other Azure services can help minimize latency.

#### Data Sovereignty

Different regions may have specific regulatory requirements and data residency restrictions. 

### Assessment Questions

 Have you considered data sovereignty implications when designing the data storage locations, Azure native, and Azure VMware Solution cloud services?

### Recommendations

Understand the cloud [shared responsibility](https://azure.microsoft.com/resources/shared-responsibility-for-cloud-computing/) model for industry or region-based regulatory compliance.

Ensure your data remains in the correct geopolitical zone when using Azure data services. Azure's geo-replicated storage uses the concept of a paired region in the same geopolitical region

### Automation
Organizing infrastructure deployments using Infrastructure and Code (IaC) enables more efficient infrastructure provisioning by reducing manual error and facilitating the adoption of DevOps principles in infrastructure management. Infrastructure updates can be made through code modifications, reducing the time and effort required for manual configuration and provisioning.

#### Assessment Questions
- Is the Azure VMware Solution infrastructure components provisioned manually, or are Infrastructure as Code (IaC) tools such as Bicep, Terraform, or Puppet  used for deployment?

### Recommendations
- Automate expansion and contraction through Infrastructure-as-Code. Repeatable deployments will ensure consistency each time.

### Capacity and Resource Utilization

Before deploying an application in AVS, it is crucial to ensure proper sizing and capacity planning. This entails considering scalability requirements, growth projections, and performance considerations. 

#### Assessment questions

- Do dependency maps show application flows, communication paths, dependencies, and infrastructure components?

### Recommendations:
- Leverage Azure Migrate for insights into resource utilization and SKU size recommendations before migrating to Azure. 
- Analyzing resource utilization patterns over a specific timeframe helps establish baseline usage, identify peak periods, and anticipate resource spikes.
- Create a dependency map that outlines the components on the critical path. The map should be actively maintained and regularly checked for changes in the solution.
 

## High Availability 
#### Impact: _Reliability_


When sizing for an application, ensure the VM is sized to handle the workload at peak performance.  The application should also be able to operate with reduced functionality or degraded performance in the case of an outage.	In a failure event, design for resilience to respond to outages and deliver reliability even when impacted by regional, zonal, service, or component failures impact critical application functionality. Scaling vertically is the ability of the virtual machine to add more resources to the individual hosts. This requires picking the right SKU, powering the host down, and adding more resources from an ESXi host with those resources available. 





### Assessment questions

- Is application scaling based on vertical and or horizontal scaling?


The downtime associated with vertical scaling may disrupt the business, so consider scaling horizontally in the workload design. Horizontal scaling is the ability to dynamically span the workload across multiple virtual machines. This typically involves leveraging vSphere features like resource allocation settings, VM templates, cloning, or dynamic resource allocation techniques. For example, if you want to distribute traffic across three separate VMs, you would want those on three separate hosts for high availability.

### Recommendations 
- Use [Auto-scale for Azure VMware Solution](https://github.com/Azure/azure-vmware-solution/tree/main/avs-autoscale) to define performance metrics to be used for scale-in or scale-out operations in Azure VMware Solution cluster nodes.

One way to ensure resource availability is through affinity rules. By configuring affinity rules, administrators have more control over VM placement, enabling the VMs to be distributed according to specific requirements, performance considerations, availability needs, or licensing constraints. 
 
 For VMs deployed with HA or clustering within the Azure VMware Solution, creating anti-affinity rules to keep your VMs apart and on separate hosts is highly recommended.

If one host experiences an issue or failure, the anti-affinity rule enforces distribution across multiple hosts, ensuring that the impact is limited and the availability of applications or services is maintained.


### Assessment questions


- Are Affinity/Anti-Affinity rules in place to keep VMs apart in the event of host failures?

### Recommendations 
- When a low-latent communication path is required from VM to VM, use affinity rules so that they live on the same hosts
- When VMs supporting the application need fault tolerance or to optimize host performance through resource distribution, use VM-to-VM affinity.
- For VMs deployed with HA or clustering within the Azure VMware Solution, create anti-affinity rules to keep VMs apart and on separate hosts

## Storage
#### Impact: _Reliability_, _Performance_

### vSAN

While the Default Storage Policy in Azure VMware Solution is redundant, If your machines require that data be copied to additional vSAN nodes, another policy should be created to ensure that the data meets your enhanced redundancy requirements.

#### Assessment Questions
- Are there vSAN Storage Policies that meet corporate standards?
- Are there thick and/or thin provisioning storage policies in use?	

### Azure Netapp Files (ANF)
When you plan to exceed the storage in the SDDC, Azure NetApp Files (ANF) in AVS is another solution that will expand disk allocation and  provide a high-performance, low-latency, scalable storage platform. ANF dynamically adjusts the storage capacity and performance tiers based on the workload needs so that the AVS environment can scale as your storage requirements grow.

Azure services (such as ANF) that interact with AVS are in the same zone as AVS	Ensure that Azure services that interact with AVS are in the same zone where AVS is deployed.  If all or part of the application is highly sensitive to latency, it may mandate component co-locality, limiting the applicability of multi-region and multi-zone strategies.	Doing so will reduce latency, so applications will respond more quickly.  An example is when using an ANF-based datastore where colation is critical for disk expansions.

#### Assessment Questions
- Do you need additional storage for the Azure VMware Solution environment?

### Recommendation
- 	Azure NetApp Files can be connected as an additional datastore attached  for the Azure Vmware solution. Going through an application assessment will help determine the optimal combination of Azure VMware Solution Nodes and external storage like Azure NetApp Files.


### Assessment questions
- If a node replacement process starts, will this affect your overall workload?




## Business Continuity and Disaster Recovery 
The SDDC should have protection against data loss, minimizes downtime, and maintain the continuity of operations when there are unexpected disruptions or disasters. 

### Service Level Agreements (SLAs)

Availability targets such as Service Level Agreements (SLAs) for Azure VMware Solution application(s) are defined for your platform and should be in place.


 
## Recovery time objective (RTO)

Recovery targets to identify how long the Azure VMware Solution can be unavailable (Recovery Time Objective) and how much data loss is acceptable during a disaster (Recovery Point Objective) identified.

### Design considerations


- **Critical path dependencies**. Not all components of the solution are equally critical. Clearly understand the dependencies that can take down the system versus others that might lead to degraded experience. The design should harden the resiliency of critical components to minimize the impact of outages.

- **Scale out and scale in on-demand**. The environment should be able to expand and contract based on load. Handle those operations through automation. User input should be kept to a minimum to avoid typical errors caused by humans in loop.


### Assessment questions

- Have you got a calculated SLA based on the key services being used within Azure VMware Solution and the surrounding technologies?

## Backup 

For business continuity, robust data protection must be implemented to ensure your virtual machines' availability, integrity, and recoverability and critical data within the AVS environment. Not only must the backup tools be in place, but they must be confirmed to work.	A key principle of Azure VMware Solution is to  provide Independent software vendor (ISV) technology support, validated with Azure VMware Solution.  Understanding the partners and options available to you is critical to your backup success.	

### Assessment Questions
- Are you using an Azure-validated backup application?

### Recommendations
- Use Microsoft-supported backup solutions like MABS or approved 3rd party vendors.

Azure Site Recovery is a disaster recovery solution designed to minimize downtime of the virtual machines in an Azure VMware Solution environment if there is a disaster. ARS automates and orchestrates failover and failback, ensuring minimal downtime in a disaster. Also, built-in non-disruptive testing ensures your recovery time objectives are met. Overall, ARS simplifies management through automation and ensures fast and highly predictable recovery times.


### Recommendations
- In a prolonged regional outage, workloads protect the workloads by replicating them to an alternative Azure region.
- Configure Azure Site Recovery to send the backups to an alternate region 

#### Assessment Questions
- Are backups stored in a different region	To protect against a regional disaster?


Most importantly, there needs to be a clear understanding of what backup and recovery infrastructure exists in the environment. To have a backup solution configured, backup targets for the infrastructure must also be used. Your applications, databases, and assets are sent to a blob storage or Azure backup vault. From there, owners for backing up and restoring the application should be identified. 

- Is there a clear understanding of backup and recovery infrastructure exists? Are the backup and discovery procedures documented? 

### Establish Baseline performance

#### Impact _Operational_Excellence_

Establishing a performance baseline provides insight into the Azure VMware Solutions capabilities and helps identify performance constraints. 

#### Assessment Question

Has the workload been benchmarked and performance tested for metrics such as CPU utilization, memory usage, storage IOPS, network throughput, latency, and response times before migrating to the Azure VMware Solution?

### Recommendations 

* Use tools to benchmark the existing environment before migrating to Azure VMware Solution SDDC. [VMware vRealize Operations](/azure/azure-vmware/vrealize-operations-for-azure-vmware-solution), [Perfmon](/message-analyzer/perfmon-viewer), [iostat](https://linux.die.net/man/1/iostat) are some of the common utilities that can be used for establishing baseline performance.
* Use [performance-based assessment](/azure/migrate/best-practices-assessment#sizing-criteria) when estimating Azure VMware Solution SDDC capacity.


### Debugging and troubleshooting tools

A systematic approach to identifying, troubleshooting, and fixing problems in the SDDC leads to faster resolution times. Operations teams must be able to define the problem or symptom the workload is experiencing, the scope of the issue, and the ability to collect information, including error messages, logs, and any specific conditions or actions that trigger the issue.

#### Assessment Question
What tools are installed for debugging and diagnosing issues?
  
### Recommendations

* Familiarize with the following debugging and troubleshooting tools. These tools are indispensable for identifying potential performance bottleneck(s) quickly.
  * [Azure Network Watcher](/azure/network-watcher/network-watcher-monitoring-overview)
  * [KQL](/azure/data-explorer/kusto/query/tutorials/learn-common-operators?pivots=azuremonitor)
  * [PSPing](/sysinternals/downloads/psping)






For detailed coverage of Infrastructure Monitoring, see the [Monitoring](./monitoring.md) section

## Next steps

Now that we've taken a look at the underlying platform, lets investigate further into the application platform (e.g databases, vms, operating systems, and configurations)
> [!div class="nextstepaction"]
> [Application Platform](./application-platform.md)
