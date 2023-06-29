# Azure VMware Solution Well-Architected Framework: Reliability Discovery and Assessment
This step collects detailed information about each application's reliability readiness. 

### What reliability targets and metrics have you defined for your Azure VMware Solution and Azure?

- Have you adequately sized your deployment to handle node failures without affecting overall uptime?
- If you are using a stretched cluster or active/active or active/passive setup, do you have enough capacity to continue to run your service in the event of active/passive cluster failure?
- When using HCX extended networks, have the required appliances been deployed in a fault-tolerant setup?
- Have you deployed your ExpressRoute Gateway in a zonal-aware configuration?
- Have you verified that vSAN Storage Policies are in place that meets corporate standards?
- Do you have VMware Anti Affinity rules in place to keep VMs apart in the event of host failures?

### Do you have documentation on what and how to recover your applications?
- How often do you practice your recovery procedures?  
- Can you describe the recovery process if an app fails?  
- Are backups able to complete in the windows allocated?
- Are there engineers qualified and dedicated to administering backup/restore procedures?
- Does everything in the environment need to be backed up?
- What are the specified backup/recovery policies for your application tiers?
- What is the level of confidence in the current backup and restore procedures?
- Is the backup and recovery infrastructure defined?
- Is there a Business Impact Analysis (BIA) for DR?
- What scenarios are you protecting against and is there a developed a risk assessment guide? 
- Is the DR strategy today executed manually through a runbook or are there automated steps?

### Do you have a comprehensive Business Continuity strategy for your environment?

- Are SLAs established for the applications? 
- Is the backup solution in place Azure-validated?
- Are backups stored in a different region?
- Is the disaster recovery application Azure validated?
- Is failover architecture in places across multiple regions?
- Is the failover architecture is inter-regional (across availability zones)
