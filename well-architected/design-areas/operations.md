# Azure VMware Solution Well-Architected Framework: Operational Procedures

This section aims to build the operating model for the Azure VMware Solution, and the applications inside the Software Defined Datacenter (SDDC). Standard operating procedures (SOPs) are documented processes for managing a workload. Each AVS workload should have SOPs to govern operations. Without SOPs, teams drift from management best practices, so we recommend a continuous cycle of assessment and health checks for your AVS workload.

## Management & Monitoring & Analytics

It's essential to know how the workload in the SDDC is doing. Similar to how you would monitor things such as CPU usage, OS logs, and security alerts, to name a few, these same elements are monitored in the SDDC. The critical difference is that it is possible now to leverage cloud-native plus existing VMware tools into your operating model. Tools include but are not limited to enabling VMware VROPs, installing Azure Monitor agents, and any third-party monitoring/reporting tool used today on-prem. For more information see [application monitoring](/application-platform.md)

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

