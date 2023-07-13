---

# Application considerations for Azure VMware Solution (AVS)



This section aims to build the operating model for the Azure VMware Solution, and the applications inside the Software Defined Datacenter (SDDC). Standard operating procedures (SOPs) are documented processes for managing a workload. Each AVS workload should have SOPs to govern operations. Without SOPs, teams drift from management best practices, so we recommend a continuous cycle of assessment and health checks for your AVS workload.


## Align to business metrics
**Impact**: _Reliability_

Azure provides Service Level Agreements (SLAs) for all its services. The composite SLA of your workload should include [SLAs for Azure infrastructure]() and SLAs defined for the application.  




##### Recommendations


- Define Service Level Agreements (SLAs) for the application and its key use cases.
- Determine how much downtime is acceptable. Quantify that value as the 
Recovery time objective (RTO). 
- Determine the maximum duration of data loss that's acceptable during an outage. Quantify that value as the Recovery point objective (RPO).
- Document the business metrics in your strategy for backup and disaster recovery. 

## Choose a migration approach
**Impact**: _Performance Efficiency, Cost Optimization_


Common approaches for migrating or modernizing to the cloud are Rehost, Refactor, Rearchitect, and Rebuild. Each requires careful rationalization by evaluating the pros and cons. 
Your workload might be better suited for IaaS or PaaS services. Those services might be more cost-effective and performant than migrating to Azure VMware Solution.

The modernization approach, or updating current apps and data to a cloud-first model, can meet your business needs at reduced costs. Evaluate the choices for application and at the Azure infrastructure level.

Application: Choose modernization based on the purpose of the application, life expectancy, supportability, cost, and SLAs.

Infrastructure: Consider the cost of an Azure VMware Solution node against running applications in Azure native services. You can run as many workloads in Azure VMware Solution as possible in the static memory/storage/compute. However, porting applications to Azure native can be more cost-effective than instantiating another Azure VMware Solution node.

The application assessment results can help you understand where servers should be optimally placed.

Your workload might be better suited for IaaS or PaaS services. Those services might be more cost-effective and performant than migrating to Azure VMware Solution.

The modernization approach or updating current apps and data to a cloud-first model, can meet your business needs at reduced costs. Evaluate the choices for application and at the Azure infrastructure level. 
    
- **Application**: Choose modernization based on the purpose of the application, life expectancy, supportability, cost, and SLAs. 

- **Infrastructure**: Consider the cost of an Azure VMware Solution node against running applications in Azure native services. You can run as many workloads in Azure VMware Solution as you can fit in the static memory/storage/compute. However, porting applications to Azure native can be more cost-effective than instantiating another Azure VMware Solution node. 


##### Recommendations

- **Use assessments** to get a complete picture of the impact on the application, infrastructure, and the adjustments needed in your business strategy. This exercise will help you  understand the workload, its dependencies, and system requirements. You will be better prepared for your migration wave planning.

    - [Strategic Migration Assessment and Readiness Tool (SMART)](/azure/cloud-adoption-framework/plan/smart-assessment)
    - [Tutorial: Assess VMware VMs for migration to Azure VMs](/azure/migrate/concepts-azure-vmware-solution-assessment-calculation)
    - [Application assessment](/azure/architecture/serverless-quest/application-assessment) 

- **Is Azure VMware Solution the right choice?** 

    

    The application assessment results can help you understand where servers should be optimally placed.

## Establish a security baseline

The Microsoft cloud security benchmark provides recommendations on how you can secure your cloud solutions on Azure. This security baseline applies controls defined by Microsoft cloud security benchmark version 1.0 to Azure Policy.

**Impact**: _Security_

##### Recommendations

Apply the recommendations given in the **security baseline** to protect your workload. 

> [Azure security baseline for Azure VMware Solution](/security/benchmark/azure/baselines/azure-vmware-solution-security-baseline)


## Identify dependencies

Not all components of the solution are equally critical. Some components can take down the system while others might lead to degraded experience.

**Impact**: _Reliability, Operational Excellence, Performance Efficiency_

##### Recommendation

- **Create a  dependency map** that identifies the critical dependencies. Maintain and check the accuracy of the map at a regular cadence. 


## Scale the workload to handle load

The environment should be able to expand and contract based on load. Handle those operations through automation. User input should be kept to a minimum to avoid typical errors caused by human in loop.

**Impact**: _Performance Efficiency, Operational Excellence_


##### Recommendations

- When sizing for an application, ensure that the virtual machine is sized to handle the largest workload in an Azure VMware Solution or physical hardware environment. You might be able to handle the load with vertical scaling. Migration is a good opportunity to review Azure capabilities such as scale sets and automated vertical scaling of virtual machine size.
- Define high and low threshold values by running performance tests. Observe Azure metrics for the percentage usage of cluster CPU, memory, and storage resources. 
- Set alerts on the threshold values and trigger your the auto-scale node event within in Azure VMware Solution private cloud. 

> [!NOTE]
> ![GitHub logo](../_images/github.svg)For an example implementation, see [Auto-Scale function](https://github.com/Azure/azure-vmware-solution/tree/main/avs-autoscale).

## Set affinity and anti-affinity policies [MOVED TO INFRASTRUCTURE}
**Impact**: _Performance Efficiency_

An affinity rule specifies that the members of a selected virtual machine DRS group can or must run on the members of a specific host DRS group. An anti-affinity rule specifies that the members of a selected virtual machine DRS group cannot run on the members of a specific host DRS group.

##### Recommendation

An important capability with the Vmware solution.  Because auto-failover isn't available in Azure VMware Solution, having a good understanding of [Affinity Policies](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.resmgmt.doc/GUID-FF28F29C-8B67-4EFF-A2EF-63B3537E6934.html) is key to application availability.

The next section visits how to securely establish connectivity, create perimeters for your workload, and evenly distribute traffic to the application workloads.

> [!div class="nextstepaction"]
> [Networking](./networking.md)

