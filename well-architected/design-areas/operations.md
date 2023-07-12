# Azure VMware Solution Well-Architected Framework: Operational Procedures

This section aims to establish the Azure VMware Solution's operational framework and the applications within the Software Defined Datacenter (SDDC). Standard operating procedures (SOPs) are documented processes for managing a workload, and each AVS workload should have SOPs to govern operations. A continuous cycle of assessment and health checks for your AVS workload utilizing the SOPs helps prevent drift from best practices and stay aligned with business objectives.

## Management, Monitoring & Analytics






### Data and Application Visualization
#### Impact _Operational Excellence_

Application Dashboards are a way to visualize and monitor an application's performance, health, and other metrics. They provide insights into how code and infrastructure changes impact application behavior and help customer support teams to understand the impact of change, performance, and availability issues on an application. Executive leadership and business stakeholders may also benefit from these products to track performance indicators to make informed decisions to align the application's performance with business objectives. For example, an executive can monitor its commitment to customers by reviewing metrics such as service availability, incident resolution times, and average response time to ensure the organization is delivering services per their SLA. 

Granting access to appropriate stakeholders to application dashboards promotes transparency, encourages collaboration, and cultivates a shared comprehension of the application's performance. This mechanism enables the organization to make informed decisions therefore helping stakeholders focus on pursuing crucial initiatives that propel the business forward. 

### Recommendations
- Build an application dashboard with Azure Application Insights or Grafana and connect it to relevant data sources that store metrics from the AVS environment
- Ensure the data source aligns with security and compliance requirements
- Define access controls and permissions such as user authentication and RBAC so that each stakeholder has the appropriate access based on their role
- Conduct periodic access reviews to ensure user access is up to date and aligned with current roles and responsibilities


#### Assessment Questions

- Are application state dashboards (e.g., Application Insights, Granfana) created and published?


### Tracking Application Dependencies 
#### Impact _Operational Excellence_

IT teams continuously look to optimize the deployment, management, and maintenance of applications, sites, and services to ensure high performance, reliability, scalability, and security. This involves understanding how applications flow inside the Azure VMware Solution platform and external dependencies and relationships outside the SDDC. A dependency map is a valuable tool for developers, application architects, and IT teams to understand the structure and behavior of the applications. Having insight into application components such as software and infrastructure, services, and external dependencies provides a visual way to understand data flows, functionality, and API calls.

### Recommendation 
 
- Use Azure Application insights to track dependencies such as databases, API calls, and external services
- Use Azure Service Map in Azure Monitor to automatically discover and visualize different application and infrastructure components 
- Use third-party tools (e.g., NewRelic, Datadog) to discover and map dependencies
- Use custom scripts or third-party configuration management tools that track the automation and deployment of the dependencies 

#### Assessment Questions 

- Are dependency mappings available (e.g., flow chart, application diagram)?

## Achieve Faster Time-To-Market with DevOps
#### Impact _Operational Excellence_

Organizations benefit from improved collaboration and software quality by adopting DevOps practices. For example, automation can expedite the deployment and maintenance of applications. Infrastructure as Code (IaC) can create several resources in AVS, such as the entire SDDC or individual components like clusters, network appliances, storage, and more. Using tools such as Azure Resource Manager, Bicep, Terraform, Azure CLI, or Powershell will automate the provisioning and configuration of resources in AVS. The outputs returned from deploying IaC can serve as documentation to help maintain and provide additional visibility in the state and configuration of provisioned resources. 

Managing the code with a version control system allows versioning to track and roll back changes as needed.  

Suppose there is a need to update application code across servers, methods such as blue-green deployments aid in managing the lifecycle of an application from development to production. Blue-green deployments can help customers to have a consistent web experience when updates and patches are being performed by distributing traffic only to healthy servers during maintenance using weighted algorithms. AVS does not have the same methods for achieving Blue-Green as a cloud-native application would, but it is still achievable. Before making changes to the application configuration, take snapshots of the environment and use version control to ensure you return to the last known good state.  Consider creating a staging environment that mirrors production and deploys updates there before going live. From there, perform rolling updates to a subset of servers and test the application. 

In summary, organizations can reduce manual effort, minimize errors, and improve resource utilization by automating routine tasks like provisioning, scaling, and patching. DevOps methodologies are an important element of well-architected to streamline operations, save time, and allow teams to focus on value-added activities.

### Recommendations 

- Use Infrastructure as Code to deploy and provision infrastructure in a way that is repeatable, auditable, and consistent
- Use Version Control Systems such as Azure DevOps or GIT to track changes, collaborate, and rollback code to previous versions as needed.
- Leverage the blue-green concept by creating a staging environment that mirrors production and test before going live
- Maintain the last good state of the application by using snapshots, cloning the disks, and having version-controlled code. 
 

#### Assessment Questions
- Has the organization adopted DevOps methodologies such as Agile Development, Infrastructure as Code, Configuration management, and Version Control?

## Defining Roles and Responsibilities for Efficient Operations
#### Impact _Operational Excellence_

Having well-defined roles and responsibilities helps ensure clarity, accountability, and effective management of a well-architected AVS workload. A defined set of standards and structured processes and knowing who will execute them leads to efficient operations, helping IT organizations align their technical offerings with business objectives and strategies. As the AVS environment grows and evolves, well-defined roles and responsibilities lead to easier task delegation and the potential to scale the solution without disruption, resulting in a better experience for the application's users. 

It's important to have a culture of continual improvement that focuses on efficient day-to-day operations for applications in the SDDC, such as maintaining SLAs, maintaining availability, having the capacity to minimize service disruptions, and having a smooth delivery. For example, the Azure VMware solution makes it possible to expand the environment with minimal user input. If manually expanding the contract, it should be documented who will perform these activities and how to do it. AVS operators should ensure node reservation is available for growing the environment as needed. Also, someone should be responsible for identifying underutilized or idle resources and right-sizing VMs to reduce unnecessary costs.

#### Assessment Questions
- Are roles and responsibilities identified (e.g., Network Engineer, Security, Application Owners/Developers, etc) and mapped to roles based on least privilege?

### Tagging Strategies and Best Practices 

 A tagging strategy can be applied for chargeback and resource tracking. These tags are key-pair values defined at the resource level and can be applied during provisioning. Leveraging infrastructure as code can create, update, and destroy guest VM and work alongside a configuration management tool. Examples of tags include
 - Environment: Identifying resources as "Production," "QA," or "Dev Test"
 - Cost Center to track resource costs and expenses
 - SLA: Prioritizing resources on their SLA requirements
 - Lifecycle: Noting if the application is "Active," "Archived," or "Retired.
 - Criticality: Labeling resources based on their business impact and significance

These tagging considerations are general, and it's important that the tagging strategy used aids in effective resource categorization, resource lifecycle management, and reporting within AVS. 

### Recommendations 
- Use Tags for resource management by identifying workloads and infrastructure based on an organizational taxonomy (e.g., host, business, owner, environment, etc.).

 #### Assessment Questions
 - Are there tags on the workloads services, and does the tagging strategy align with organizational needs?



## Incident Management

It's essential to know how the workload in the SDDC is doing by monitoring metrics such as CPU usage, OS logs, and security alerts in the SDDC. However, several key operational aspects must be evaluated to ensure the alerting system's effectiveness. 
- Are all the critical components identified, such as databases, network devices, and storage, amongst other relevant components?
- Are the thresholds set appropriate?
- Are the alerts specific and actionable?
- Are the right people receiving the alerts?
- Is there a substantial amount of noise and false positives?
- Are there adequate escalation procedures in place?

Evaluating the processes and procedures to respond to critical alerts assists in making sure they are addressed promptly. 

### Establishing Incident Response Teams 

Before an incident or outage, it is crucial to establish a well-defined notification process to ensure timely communication. Identifying the relevant personnel responsible for resolution is vital. Having dedicated remediation team can be formed comprising operations, application owners, and DevOps experts who possess the necessary expertise is needed to resolve issues quickly. The operations team must be aware of the appropriate individuals to involve in triaging the problem.

An incident response team can effectively coordinate responses by maintaining a comprehensive distribution list. This list should include key stakeholders from business-critical departments and designated escalation contacts. Business stakeholders must be informed of any potential impact on operations resulting from the incident. The assigned escalation contacts should be individuals capable of making decisions or escalating issues to higher levels for guidance.

Regularly reviewing the distribution list is essential to ensure its accuracy and alignment with current roles and responsibilities. This ensures that key stakeholders are promptly informed about significant events occurring in AVS.

### Recommendations
- Define the appropriate recipients for AVS Alerts and Incidents:
- Clearly define escalation contacts that should be reachable and authorized to make decisions or escalate issues
- Identify key business stakeholders or representatives to ensure visibility into any potential impact and to provide guidance
- Have a remediation team in place of administrators, infrastructure engineers, and personnel with the necessary expertise to address and resolve issues
- Alerting is integrated with an IT Service Management (ITSM) system like ServiceNow.
- Adopt a framework such as ITIL/ISO to map day-to-day operations, processes, and activities, faster knowledge transfers, continuous improvements, and change management.


#### Assessment Questions

- Is a Service Management framework (e.g., ITIL/ISO) in place?
 
### Effective Manage alerts 

Consider consolidating alerts to reduce the number of individual notifications. For example, instead of alerting for every single machine low on space, consider consolidating them by hosts, resource groups,s or clusters. This can also be applied to host issues, CPU, and storage spikes. Also, you can streamline notifications and reduce noise by establishing alerts based on time windows. For example, if a host is alerting for a short time, you may want to suppress the alert based on defined time thresholds (e.g., only alert after 5mins). 

### Recommendations 
- Prioritize alerts based on their impact on operations or the criticality of the affected systems. Fine-tune alerts to trigger only meaningful events
- Define relevant alert criteria such as thresholds, severity levels, or specific conditions
- Use methods for reducing the number of individual notifications to reduce noise and effectively manage alerts.
- Have a mechanism to ensure key stakeholders are notified about significant events to minimize alert fatigue.
- Leverage notification channels such as SMS, Email, Push Notifications and collaboration platforms such as teams to ensure alerts are delivered effectively 
  
#### Assessment Questions
- Are severity thresholds clearly defined?
- Are alerts aggregated to focus on meaningful, actional, and critical issues?




