# Azure VMware Solution Well-Architected Framework: Operational Procedures

The objective of this section is to establish the operational framework for the Azure VMware Solution, along with the applications within the Software Defined Datacenter (SDDC). Standard operating procedures (SOPs) are documented processes for managing a workload. Each AVS workload should have SOPs to govern operations. Without SOPs, teams drift from management best practices, so we recommend a continuous cycle of assessment and health checks for your AVS workload.

## Management & Monitoring & Analytics
#### Impact _Operational Excellence_

It's essential to know how the workload in the SDDC is doing. Similar to how you would monitor things such as CPU usage, OS logs, and security alerts, to name a few, these same elements are monitored in the SDDC. The critical difference is that it is possible now to leverage cloud-native plus existing VMware tools into your operating model. Tools include but are not limited to enabling VMware VROPs, installing Azure Monitor agents, and any third-party monitoring/reporting tool used today on-prem. For more information, see [application monitoring](/application-platform.md)

## Assessment Questions 
 - Are thresholds defined for CPU, Memory, and disks?
 - Is automation configured to alert responsible parties when thresholds are exceeded?
 - Are notifications in place to alert the appropriate teams during an outage?
 - Are there tools for alerting and remediating stale patches, OS versions, and software configurations? 
 - Are Log retention durations clearly defined?
 - Are alerts set to trigger only when thresholds defined are exceeded?
 - Are application state dashboards (e.g., Granfana) created and published?

### Recommendation

Discuss and document acceptable thresholds. 

Use Tags for resource management by identifying workloads and infrastructure based on an organizational taxonomy (e.g., host, business, owner, environment, etc.). The tagging strategy can then be applied for chargeback and resource tracking. These tags can be applied during provisioning. Leveraging infrastructure as code can create, update, and destroy guest VM and work alongside a configuration management tool

 A tool such as Azure Monitor or Grafana is used to visualize the application health model and encompass logs and metrics. Dashboards are tailored to a specific audience, such as developers, security, or networking teams. A tool such as Azure Monitor or Splunk is used for alerting.

Specific owners and processes are defined and documented  for each alert type. Consider prioritizing operational events based on business impact
 Push notifications are used to inform responsible parties of alerts in real time
 Alerting is integrated with an IT Service Management (ITSM) system such as ServiceNow

## Applications
#### Impact _Operational Excellence_

IT teams continuously look to optimize the deployment, management, and maintenance of applications, sites, and services to ensure high performance, reliability, scalability, and security. This involves understanding how applications flow inside the Azure VMware Solution platform and external dependencies and relationships outside the SDDC. 

### Recommendation 
A dependency map is a valuable tool for developers, application architects, and IT teams to understand the structure and behavior of the applications. Having insight into application components such as software and infrastructure, services, and external dependencies provides a visual way to understand data flows, functionality, and API calls. 

## Assessment Questions 

- Are dependencies mappings available (e.g., flow chart, application diagram)?
- Are there mappings between the application and platform layer (e.g., if you get a site down alert and there is an infra alert for high CPU).
- Is there monitoring for the application availability (e.g., up/down alerts)?





## Automation and DevOps
#### Impact _Operational Excellence_

IT teams can expedite the deployment and maintenance of their applications with automation. This includes not only provisioning the underlying platform infrastructure with IaC but using configuration management to consistently deploy configs, performance tune the applications, and use methods such as blue-green deployments to manage the lifecycle of an application from dev to production. Blue-green deployments can also help customers have a consistent web experience by deploying updates and patches to some services while only distributing traffic to healthy servers during maintenance. 

### Recommendations 
Embracing automation and DevOps methodologies enhances operational efficiency and cost management. Organizations can reduce manual effort, minimize errors, and improve resource utilization by automating routine tasks like provisioning, scaling, and patching. This streamlines operations saves time, and allows teams to focus on value-added activities.


## Roles and Responsibilities
One way of achieving a well-architectured application is to have a set of standards and structured processes and know who will execute them. This will help IT organizations to align their technical offerings with business objectives and strategies, resulting in a better customer experience. 

It's important to have a culture of continual improvement that focuses on efficient day-to-day operations for applications in the SDDC, such as maintaining SLAs, maintaining availability, having the capacity to minimize service disruptions, and having a smooth delivery. For example, the Azure VMware solution makes it possible to expand the environment with minimal user input. If manually expanding the contract, it should be documented who will perform these activities and how to do it. AVS operators should ensure node reservation is available for growing the environment as needed. Also, someone should be responsible for identifying underutilized or idle resources and right-sizing VMs to reduce unnecessary costs.

### Recommendations 
It's recommended to adopt a framework such as ITIL/ISO to map day-to-day operations, processes, and activities, faster knowledge transfers, continuous improvements, and change management. 


## Assessment Questions
- Are roles and responsibilities identified (e.g., Network Engineer, Security, Application Owners/Developers, etc.)
- Are application owners identified and mapped to specific roles that follow the principle of least privilege?
- Is a Service Management framework (e.g., ITIL/ISO) in place?
- Are there qualified individuals to apply patches to the systems?


