# Azure VMware Solution Well-Architected Framework: Operational Procedures -  Discovery and Assessment

## Monitoring and Logging

This section assesses how the Azure VMware Solution Private cloud and workloads are being monitored, how events are logged, and how alerting takes place if anomalies are detected

### How are you monitoring workloads deployed in your Azure VMware Solution Private Cloud 
- Are Azure Monitor agents installed and deployed to collect OS metrics?
- Are there tools in place for log aggregation?
- Are Infrastructure, OS,  and application logs in a centralized place?
- Are third tools a part of the monitoring solution? If so, are they approved for use with the Azure VMware Solution
- Do you have vROPS (vRealize Operations) in use?
- How are you collecting and assessing security logs today?
- Do you have tools in place for patch management?

##  Alerting and remediation

This section assesses how  alerting occurs if anomalies are detected in the Azure VMware Solution Private cloud?

 - Are thresholds configured for...
 - Is automation configured to alert responsible parties when thresholds are exceeded?
 - Are notifications in place to alert the appropriate teams during an outage?
 - Are there tools for alerting and remediating stale patches, OS versions, and software configurations? 
 - Are Log retention durations clearly defined?
 - Are alerts set to trigger only when thresholds defined are exceeded?
 - Are application state dashboards (e.g Granfana) created and are published?
## Applications
- Are dependencies mappings available (e.g flow chart, application diagram)?
- Are there mappings between the application and platform layer (e.g. if you get a site down alert and there is an infra alert for high CPU).
- Is there monitoring for how the application availability (e.g up/down alerts)? 

