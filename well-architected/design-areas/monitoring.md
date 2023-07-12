# Monitoring considerations for Azure VMware workloads 

This design area focuses on observability best practices for a VMware workload. The guidance is intended for the operations team. To monitor the infrastructure and the application, a combination of tools provided by Microsoft, VMware, and third-parties can be used. This article lists those options. 

Each option offers monitoring solutions with varying degree of licensing costs, integration options, monitoring scope and support. Carefully, review terms and conditions before using the tools. 

## Collect infrastructure data 

To monitor the workload, you'll need to collect data from various VMware components and Azure VMware Solution (AVS) infrastructure.  

### Recommendations 

Impact: _Operational excellence, Cost optimization_

Azure VMware Solution (AVS) is integrated with VMware Software-Defined Data Center (SDDC) that runs several VMware native components. Configure vSphere Health Status to get a high-level overview of Azure VMware Solution SDDC's health status. Use vRealize Network Insight to get enhanced visibility and analytics of Azure VMware Solution SDDC's network infrastructure. 

A popular tool for monitoring infrastructure and application is vRealize Operations for Azure VMware Solution. 

You'll need logs collected by VMware Syslog to get health data from the VMware system components, such as ESXi, vSAN, NSX-T, vCenter, and others. These logs are available through Azure VMware Solution (AVS) infrastructure. Configure Azure Log Analytics to collect those logs for querying, analyzing and reporting purposes. 

There might be tradeoffs on cost. Configure cost control for storing and managing costs associated with Azure Monitor. 

To enable guest management and monitoring on AVS guest VMs, you'll need to install additional agents to collect data. Use Azure Arc for Azure VMware Solution (Preview). For example, Azure Log Analytics agent/extension sends guest VM level logs to Azure Log Analytics. 

Use native monitoring tools and processes for database activities. For example, if SQL server is used, SQL Server assessment is recommended to support database monitoring on Azure VMware Solution SDDC. 

There are third-party solutions available. Use Partner solutions for application performance monitoring. Such solutions enable operation teams to continue using tool of their choice. 

### Assessment question 

How are you monitoring your workloads deployed in your Azure VMware Solution Private Cloud? 

What tools do you use to monitor your Azure VMware Solution Private Cloud and clusters? 

Do you have any centralized tool for logging and analysis 

## Security monitoring 

Security monitoring is a critical to detect and respond to anomalous activities. Workloads running in Azure VMware Solution (AVS) SDDC needs comprehensive security monitoring spanning networks, Azure resources and the Azure VMware Solution (AVS) SDDC itself.  

### Recommendations 

#### Impact: _Security, Operational excellence_

Use security monitoring solutions from Partners. These tools are pre-validated to be used for Azure VMware Solution SDDC. 

Enable Azure Defender for Cloud on the Azure subscription used for deploying Azure VMware Solution SDDC. Ensure that the defender plan has "Cloud Workload Protection (CWP)" ON for Servers. Operations team will be able to cover Azure VMware Solution guest VMs with threat protection. 

For network security, capture and monitor Network Firewall logs deployed either in Azure VMware Solution SDDC or Azure. Run guest VMs behind this firewall. 

Use Azure Firewall Workbook or similar tools to monitor common metrics and logs related to firewall device. 

Audit activities by privileged users on Azure VMware Solution SDDC. 

You can centralize security events by deploying Microsoft Sentinel workspace. Enable it's data collector for security events and connect it with Microsoft Defender for Cloud. With this integration, the operation team can view, analyze, and detect security incidents in the context of broader organizational threat landscape. For more information, see these articles: 

Enable data collector 

Integrate Sentinel with Defender for Cloud 

### Assessment question 

How are you monitoring security-related events in Azure VMware Solution? 

How are you monitoring identity and networking events? 

## Alerts and notifications 

You also need to configure alerts so that notifications are sent to the accountable teams when certain conditions are met. 

### Recommendations 

### Impact: _Operational excellence, Cost optimization_ 

vSphere events and alarms subsystem is recommended for monitoring vSphere and setting up triggers. 

Configure Azure Alerts in Azure VMware Solution. Such alerts enable operation teams to respond to expected and unexpected events in real-time. 

Understand Azure VMware Solution Service Level Agreement (SLA) commitments. Ensure that alerts are configured so that vSAN storage slack space is maintained at the levels mandated by SLA agreement. 

Configure Resource Health alerts. Operations teams can use these alerts to get real-time health status of Azure VMware Solution SDDC. 

Assessment question 

Have you identified users/user groups who will receive alerts? 

Have you defined processes to be followed in response to various alerts? 

How do you utilize platform and workload data and then alert relevant teams when issues occur? 

How do you govern and set Azure budgets and alerts on costs? 

## Visualization 

It's highly recommended that you visually represent the monitoring reports in dashboards to drive effective operations. This will help the operations team to quickly do root-cause analysis and troubleshooting. 

#### Impact: _Operational excellence_ 

Configure Monitoring dashboard. Operation teams can use such dashboard for a simplified view of all key resources that make up Azure VMware Solution in a single pane. 

Create Azure Workbook as a central repository for commonly executed queries, metrics and interactive reports. 

Assessment question 

Have you created a single dashboard for all monitoring in a single pane? 

Have you identified common queries needed for troubleshooting and debugging? 

### Logging

 - Are application state dashboards (e.g., Granfana) created and published?
 - Are there tools for alerting and remediating stale patches, OS versions, and software configurations? 
 - Are Log retention durations clearly defined?

### Application Performance Monitoring and Alerting 

### Recommendation

- Discuss and establish baselines based on performance data
- Use application performance monitoring (APM) tools to gain performance insights and the application code level.
- Use a combination of monitoring techniques such as synthetic transactions, heartbeat monitoring, and endpoint monitoring
- Integrate alerts with collaboration messaging tools such as Microsoft Teams


#### Assessment Questions 
 - Are thresholds defined for CPU, Memory, and disks?
 - Is automation configured to alert responsible parties when thresholds are exceeded?
 - Are notifications in place to alert the appropriate teams during an outage?


### Recommendation




#### Assessment Questions
 - Are there mappings between the application and platform layer (e.g., if you get a site down alert and there is an infra alert for high CPU), and do they map application availability (e.g., up/down alerts)?
