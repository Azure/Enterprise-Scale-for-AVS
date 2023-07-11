# Applications

This section covers the guidance for determining the architecture and design pricipals used to configure the optimal configuration for the VMware portion of the Azure VMware Solution.  We cover both design decisions for the workloads that will run in AVS from an infrastructure perspective, and settings related to the user experience.
Perform a Microsoft application assessment before starting your AVS build and use the Migrate assessment dependency map capability to get a complete picture of the current VM landscape.	Weigh the pros and cons of migration approaches: Rehost, Refactor, Rearchitect, Rebuild.  Set up criteria to determine which workloads should be moved to Azure VMware Solution, and which to Azure Native.  Cost, ability to re-IP, capacity, usage patterns should be considered, a.  This will enable migration wave planning and minimize user/business disruption.

Ref: [Application Assessment](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/plan/smart-assessment)

Topics covered in this document

* [Availability]()
* [BCDR]()
* [Performance]() 
* [Capacity]( )
* [Management]( )
* [Automation]()
* [Security]( )

  
## Availability
Create a diagram that clearly shows the critical dependencies that might impact the overall availability of any application - the Microsoft Assessment dependency map tool can be used.  Then when deploying workloads into AVS, use the VMware affinity and anti-affinity rules that are in place to keep VMs that run the same service (ie two servers running behind a load balancer) apart in event of host failures.  This keeps the two servers running in AVS supporting the same application from being on the same AVS host and avoids moving VM's to a host where another copy is already running.  Note this is also true for any VMs operating in a HA or clustered fashion within Azure VMware Solution.  Note: An affinity rule specifies that the members of a selected virtual machine DRS group can or must run on the members of a specific host DRS group. An anti-affinity rule specifies that the members of a selected virtual machine DRS group cannot run on the members of a specific host DRS group.

When running HA solutions like Microsoft Server Clustering in your SDDC design, setting up a Windows cluster can help applications realized their SLA requirements.	This is critially important especially for database (SQL) workloads running Azure VMware Solution - as there is no auto-failover capability in the AVS SDDC.

Ref: [Affinity Rules](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.resmgmt.doc/GUID-FF28F29C-8B67-4EFF-A2EF-63B3537E6934.html) </br>
REf: [Windows Clustering in VMware Environments](https://learn.microsoft.com/en-us/azure/azure-vmware/configure-windows-server-failover-cluster) </br>

Work with application owners to determine the AVS configuration that will enable the application to operate with reduced functionality or degraded performance in the case of an outage.	Avoiding failure is impossible in the public cloud, and as a result applications require resilience to respond to outages and deliver reliability. The application should therefore be designed to operate even when impacted by regional, zonal, service or component failures across critical application scenarios and functionality.

Ref: [Appliction reliability](https://learn.microsoft.com/en-us/azure/well-architected/resiliency/app-design )

## BCDR
Use an Azure validated backup application	to ensure you get support from Microsoft and the Vendor together should you ever encounter a need for support to restore a workload.	Backups can be stored locally in Azure VMware Solution (not recommended), on Azure disk in the same region, or on Azure disk in a different region (preferred).   Select the best option for you data based on the application's SLAs.  Microsoft Backup Server (MABS) is available today, and Microsoft cloud native backup is expected by the end of CY23Q3.  There are also a number of 3rd party backup services available.	

Ref: [Microsoft Backup](https://learn.microsoft.com/en-us/azure/backup/backup-mabs-whats-new-mabs)</br>
Ref: [AVS Backup Partners](https://learn.microsoft.com/en-us/azure/azure-vmware/ecosystem-back-up-vms)

Use an Azure validated disaster recovery application	to ensure you get support from Microsoft and the Vendor together should you ever encounter a disaster.	USe vMWare Site Recovery Manager (SRM), Jetstream, Zerto or a third party applications that have partnered with Microsoft. These tools are licensed seperately. SRM is a disaster recovery solution designed to minimize downtime of the virtual machines in an Azure VMware Solution environment if there was a disaster. SRM automates and orchestrates failover and failback, ensuring minimal downtime in a disaster. Built-in non-disruptive testing ensures your recovery time objectives are met. SRM simplifies management through automation and ensures fast and highly predictable recovery times.	Disaster recovery tools should allow customers to recover into Azure VMware Solution, from Azure VMware Solution to on-premises and between Azure VMware Solution instances, even across regions.  As an alternative, Azure Site Recovery can be used to protect workloads running in Azure VMware Solution by replicating VM's to an Azure Native disaster recovery site.	

Ref:  [AVS BCDR ](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-business-continuity-and-disaster-recovery)
Ref:  [Azure Site Recovery](https://learn.microsoft.com/en-us/azure/site-recovery/Azure VMware Solution-tutorial-replication)

## Capacity
Memory and CPU count are not configurable.  You can configure oversubscription for CPU and you can alter the storage policy applied to the Azure VMware Solution datastores. To determine thelevel of oversubscription the environment can support, use the Azure Migrate VMware Assessement Tool.  Keep the 25% free space available as per the Microsoft and VMware guidance.
Deploy vSAN Storage Policies are in place that meet corporate standards.  Note that while the Default Storage Policy in Azure VMware Solution is thick provisioned,  and the default mirror is based on RAID 1.   You need to add additional nodes to get alternative (RAID 5, RAID 6) capabilities. Use thick and thin provisioning storage policies.	The default storage policy in Azure VMware Solution is thick provisioning, change it to thin for higher VM density, and remember to track IO utilization.	Use a combination of thick and thin provisioned storage policies that match the requirements of your workloads.  For high IO and large  volume changes, use thick provisioned, for more static/lower IO profiles, use thin provisioning.  General guidance is use thin provisioned disks.	While the Default Storage Policy in Azure VMware Solution is redundant, if your machines require that data be copied to additional vSAN nodes, another policy should be created to ensure that the data meets your enhanced redundancy requirements

Ref: [Create an AVS Assessment](https://learn.microsoft.com/en-us/azure/migrate/how-to-create-azure-vmware-solution-assessment) </br>
Ref: [Configure AVS Storage Policies](https://learn.microsoft.com/en-us/azure/azure-vmware/configure-storage-policy) </br>
Ref: [Storage policies](https://learn.microsoft.com/en-us/azure/azure-vmware/concepts-storage) </br>

## Performance
Azure Monitor Metrics is a feature of Azure Monitor that collects numeric data from monitored resources into a time-series database. Metrics are numerical values that are collected at regular intervals and describe some aspect of a system at a particular time. Monitor the logs surfaced by the Diagnostics service available in the AVS SDDC to watch for CPU, Memory and storage metrics.  

Ref: [Configure Metrics in AVS](https://learn.microsoft.com/en-us/azure/azure-vmware/configure-alerts-for-azure-vmware-solution#work-with-metrics)


## Management

Arc-enabled Azure VMware Solution allows managing VMs, guest OS extensions, and guest management. Azure Arc-enabled VMware vSphere (preview) extends Azure governance and management capabilities to VMware vSphere infrastructure. With Azure Arc-enabled VMware vSphere, there is a consistent management experience across Azure and VMware vSphere infrastructure. Performance metrics and logs are sent to log analytics for analysis.	Operations are related to Create, Read, Update, and Delete (CRUD) virtual machines (VMs) in an Arc-enabled Azure VMware Solution private cloud. Users can also enable guest management and install Azure extensions once the private cloud is Arc-enabled.	

Azure ARC for VMware enables the ability to perform various VMware virtual machine (VM) lifecycle operations directly from Azure, such as create, start/stop, resize, and delete.

Ref:  [Using ARC with AVS](https://learn.microsoft.com/en-us/azure/azure-vmware/deploy-arc-for-azure-vmware-solution?tabs=windows)</br>

You have SLA’s established for your applications that include both an RTO and an RPO. The SLAs should be Tiered into levels of service that meet the business requirements and align with the Microsoft Azure SLA's for all services.  Recovery procedures for each application are detailed in a runbook that details the recovery steps. Include these in a recovery run book that details the backup and disaster recovery steps.

Ref: [Microsoft Azure SLAs](https://azure.microsoft.com/en-us/support/legal/sla/summary/)

Using service Tiers in conjuction with application architectures designed for a specific SLAs will help you determine what, how, and where applications should be deployed.

Ref: [Azure VMware Solution Design Considerations](https://techcommunity.microsoft.com/t5/azure-migration-and/azure-vmware-solution-recoverability-design-considerations/ba-p/3746509)


## Automation
The use of 3rd party tool like Citrix Provisioning And Machine Creation Services to automate the deployment of guest VMs in AVS.  Use this to reduce the number of people with vCenter console access and to control the deployments of new images.


## Security
Secure workloads and validate compliance and regulatory requirements by using Microsoft Defender for Cloud and it's cloud security policies.  This tool provides recommendations on how you can secure your cloud solutions on Azure and compliance with those portions of regulatrory frameworks covered by the application platform. The secuirty baseline applies guidance from the Microsoft cloud security benchmarks and steps required for remediation.	Note that to enable Defender for Cloud, either ARC for VMware or ARC for servers is required.

 Ref: [Security and policy](https://learn.microsoft.com/azure/governance/policy/concepts/azure-security-benchmark-baseline)

Configure the external identity provider to enable administrative users to log into the vCenter, NSX-T and HCX appliances using their active directory credentials.  Then use VMwares roles to assign roles to the users.  

Ref:  [Configuring Identity and Roles for AVS](https://learn.microsoft.com/en-us/azure/azure-vmware/concepts-identity) </br>
Ref:  [VMware priviliges in AVS](https://learn.microsoft.com/en-us/azure/azure-vmware/concepts-identity#view-the-vcenter-server-privileges)


Use Azure ARC to deploy the AMA agent to virtual machines The Microsoft cloud security benchmark provides recommendations on how you can secure your cloud solutions on Azure. This security baseline applies guidance from the Microsoft cloud security benchmark version 1.0 to Azure Policy.	10		Define security requirements for the workload	https://learn.microsoft.com/azure/governance/policy/concepts/azure-security-benchmark-baseline

Ref: [Azure ARC for VMWare (where available)](https://learn.microsoft.com/en-us/azure/azure-arc/vmware-vsphere/overview)
Ref: [Azure ARC for Servers (GA)](https://learn.microsoft.com/en-us/azure/azure-arc/servers/overview)
