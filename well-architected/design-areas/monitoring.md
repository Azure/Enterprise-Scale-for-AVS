# Monitoring considerations for Azure VMware workloads 

This design area focuses on observability best practices for a VMware workload. The guidance is intended for the operations team. A combination of tools provided by Microsoft, VMware, and third parties can be used to monitor the infrastructure and the application. This article lists those options. 

Each option offers monitoring solutions with varying degrees of licensing costs, integration options, monitoring scope, and support. Carefully review the terms and conditions before using the tools. 

## Collect infrastructure data 
#### Impact: _Operational excellence, Cost optimization_

Monitoring the workload involves collecting data from various VMware components and Azure VMware Solution (AVS) infrastructure. Azure VMware Solution (AVS) is integrated with VMware Software-Defined Data Center (SDDC) that runs several VMware native components. A popular tool for monitoring infrastructure and applications is vRealize Operations for Azure VMware Solution. 

### Recommendations 

- Configure  vSphere Health Status to get a high-level overview of Azure VMware Solution SDDC's health status.
- Use  vRealize Network Insight for enhanced visibility and analytics of Azure VMware Solution SDDC's network infrastructure.
- Configure cost control for storing and managing costs associated with Azure Monitor.
- For SQL Server, use the SQL Server assessment to support database monitoring on Azure VMware Solution SDDC. 

#### Assessment question 

How are you monitoring your workloads deployed in your Azure VMware Solution Private Cloud? 

What tools do you use to monitor your Azure VMware Solution Private Cloud and clusters? 

### Logging 

You'll need logs collected by VMware Syslog to get health data from the VMware system components, such as ESXi, vSAN, NSX-T, vCenter, and others. These logs are available through Azure VMware Solution (AVS) infrastructure. Azure Log Analytics agent/extension sends guest VM-level logs to Azure Log Analytics. 


### Recommendations 
- Configure Azure Log Analytics to collect those logs for querying, analyzing, and reporting purposes.
  
#### Assessment question 
- Do you have any centralized tool for logging and analysis? 
- Are Log retention durations clearly defined?

### Monitoring the Guest OS

#### Recommendations

- install additional agents to collect data to enable guest management and monitoring on AVS guest VMs. Use Azure Arc for Azure VMware Solution (Preview).  

- There are third-party solutions available. Use Partner solutions for application performance monitoring. Such solutions enable operation teams to continue using the tool of their choice. 

#### Assessment Question
 - Are there tools for alerting and remediating stale patches, OS versions, and software configurations? 

## Security monitoring
#### Impact: _Security, Operational excellence_

Security monitoring is critical to detect and respond to anomalous activities. Workloads running in Azure VMware Solution (AVS) SDDC need comprehensive security monitoring spanning networks, Azure resources, and the Azure VMware Solution (AVS) SDDC itself. You can centralize security events by deploying Microsoft Sentinel workspace.  With this integration, the operation team can view, analyze, and detect security incidents in the context of a broader organizational threat landscape.  

### Recommendations 

- Enable Azure Defender for Cloud on the Azure subscription for deploying Azure VMware Solution SDDC, ensuring the defender plan has "Cloud Workload Protection (CWP)" ON for Servers. 

- Capture and monitor Network Firewall logs deployed in Azure VMware Solution SDDC or Azure for network security. 

- Audit activities by privileged users on Azure VMware Solution SDDC. 

- Integrate Sentinel with Defender for Cloud  and Enable its data collector for security events and connect it with Microsoft Defender for Cloud. For more information, see these articles: 

- Use security monitoring solutions from pre-validated partners in Azure VMware Solution SDDC. 

### Assessment question 

- How are you monitoring security-related events in Azure VMware Solution? 

### Network Security

### Recommendations

- Use Azure Firewall Workbook or similar tools to monitor common metrics and logs related to firewall devices. 

#### Assessment Questions
- How are you monitoring identity and networking events?


## Alerts and notifications 
#### Impact: _Operational Excellence_, _Cost optimization_ 

Configure alerts to notify the accountable teams when certain conditions are met. 

### Recommendations 

- Use vSphere events and alarms subsystem for monitoring vSphere and setting up triggers. 

- Configure Azure Alerts in Azure VMware Solution. Such alerts enable operation teams to respond to expected and unexpected events in real time. 

- Ensure that alerts are configured so that vSAN storage slack space is maintained at the levels mandated by the SLA agreement. 

- Configure Resource Health alerts to get the real-time health status of Azure VMware Solution SDDC. 

Assessment question 

- How do you obtain and utilize platform and workload data to create alerts? 
- Are there mappings between the application and platform layer (e.g., if you get a site down alert and an infra alert for high CPU), and do they map application availability (e.g., up/down alerts)?
- Are thresholds defined for CPU, Memory, and disks?
- Is automation configured to alert responsible parties when thresholds are exceeded?
- Are notifications in place to alert the appropriate teams during an outage?


## Cost Management 
#### Assessment Questions

Are there Azure budgets and alerts on costs? 

### Troubleshooting and Debugging

#### Assessment Questions
Have you identified common queries needed for troubleshooting and debugging? 

## Visualization 
#### Impact: _Operational excellence_ 

Visually representing the monitoring reports in dashboards helps drive effective operations. This will help the operations team to do root-cause analysis and troubleshooting quickly. Operation teams can use such a dashboard for a simplified view of all key resources that make up Azure VMware Solution in a single pane. 

### Recommendations
- Configure the Monitoring dashboard. 
- Create Azure Workbook as a central repository for commonly executed queries, metrics, and interactive reports. 

Assessment question 

- Have you created a single dashboard for all monitoring in a single pane?
- Are application state dashboards (e.g., Granfana) created and published?

### Application Performance Monitoring and Alerting 

### Recommendation

- Discuss and establish baselines based on performance data
- Use application performance monitoring (APM) tools to gain performance insights and the application code level.
- Use a combination of monitoring techniques such as synthetic transactions, heartbeat monitoring, and endpoint monitoring
- Integrate alerts with collaboration messaging tools such as Microsoft Teams


#### Assessment Questions 



### Recommendation


