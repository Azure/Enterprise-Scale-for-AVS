# Azure VMware Solution Well-Architected Framework: Operational Excellence

This section aims to build the operating model for the Azure VMware Solution, and the applications inside the Software Defined Datacenter (SDDC). Standard operating procedures (SOPs) are documented processes for managing a workload. Each SAP workload should have SOPs to govern operations. Without SOPs, teams drift from management best practices, so we recommend a continuous cycle of assessment and health checks for your SAP workload.

## Management & Monitoring & Analytics

It's essential to know how the workload in the SDDC is doing. Similar to how you would monitor things such as CPU usage, OS logs, and security alerts, to name a few, these same elements are monitored in the SDDC. The key difference is that you can now leverage cloud-native plus existing VMware tools into your operating model. Tools include but are not limited to enabling VMware VROPs, installing Azure Monitor agents, and any third-party monitoring/reporting tool used today on-prem. 


The Azure VMware Solution also assists with OS-level metrics and telemetry collection for analysis. Monitoring OS extensions, guest management, patching, and upgrades is important.

Once logs are collected, it's important to have a centralized place for logging and analysis. Once data has been collected and analyzed, it's possible to triage and remediate anomalies. Analysis for security, performance benchmarks, and anomalies are then available for triage and alerting. This is often in terms of an automated ticket generation process for remediation or service restoration. 

#### Cost Management & Monitoring
Azure provides tools such as Azure Cost management and BIlling that enable organizations to monitor, analyze and optimize AVS costs by providing a window into resource usage, cost allocation, and budget management.

## Operational Procedures 

### Alerting and Remediation 
Utilizing platform and workload data and proactively addressing escalations such as downtime, increased performance, and security alerts. 

## Performance Optimization

### Disk Expansion 
Azure VMware solution makes it possible to expand the environment with minimal user input. If manually expanding the contract, it should be documented who will perform these activities and how to do it. AVS operators should ensure node reservation is available for growing the environment as needed. 

#### Continous cost optimization and right-sizing 
Identifying underutilized or idle resources and right-sizing VMs can save money by reducing unnecessary costs.


## Patching and Upgrades

Tagging also for resource management by identifying workloads and infrastructure based on an organizational taxonomy (e.g., host, business, owner, environment, etc.). The tagging strategy can then be applied for chargeback and resource tracking. These tags can be applied during provisioning. Leveraging infrastructure as code can create, update, and destroy guest VM and work alongside a configuration management tool 

## Disaster Recovery and Business Continuity

Recognizing which workloads are critical to running the business is a central requirement for disaster preparation. Once a DR plan is in place, verified, and tested, this will create day-to-day procedures to be prepared in the event of a disaster. 

It's also important to have a list of follow-up activities and know who is assigned to them to mark a failure or recovery as complete. 

Backups need to be regularly verified and tested to be useful. This means completing in the time allotted, not being corrupted, and the data integrity and recovery process are valid. 

## Security, Governance, and Compliance

Assigning roles and responsibilities using the least privilege will ensure that more permissions are not given than needed and that the permissions are appropriate to the role assigned. Accounts and roles can map to a RACI. RBAC roles and JIT access enforce the least privileged roles and responsibilities. 

#### Cost Optimization through financial governance 

Consider implementing cost management policies, defining spending thresholds, and having budget controls to optimize and track spending.

## Automation and DevOps

Embracing automation and DevOps methodologies enhances operational efficiency and cost management. Organizations can reduce manual effort, minimize errors, and improve resource utilization by automating routine tasks like provisioning, scaling, and patching. This streamlines operations saves time, and allows teams to focus on value-added activities.
