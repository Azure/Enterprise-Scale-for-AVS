# Reliability Assessment
This step collects detailed information about each applications reliability readiness. 

### What reliability targets and metrics have you defined for your Azure VMware Solution and Azure?

- Have you adequately sized your deployment to handle node failures without affecting your overall uptime?
- If you are using a stretched cluster or active/active or active/passive setup, do you have enough capacity to continue to run your service in the event of active/passive cluster failure?
- When using HCX extended networks, have the required appliances been deployed in a fault resilient setup?
- Have you deployed your ExpressRoute Gateway in a zonal aware configuration?
- Have you verified that vSAN Storage Policies are in place that meet corporate standards?
- Do you have VMware Anti Affinity rules in place to keep VMs apart in event of host failures?

### Have you got documentation on what and how to recover your applications?
- How often do you practice your recovery procedures?  
- Can you describe how the recovery process would go if an app fails?  
- Do you have trouble backing everything up within prescribed windows?
- Do you have enough engineers qualified to do backup/restore administrator?
- How sure are you that everything in your environment that needs to be backed up actually is?
- What are your specified backup/recovery policies for your application tiers?
- Are you confident that systems which are being backed up can be properly restored?
- Can you describe your backup and recovery infrastructure at a high level?
- Do you have a Business Impact Analysis (BIA) for DR?
- What scenarios are you protecting against - have you developed a risk assessment guide? 
- Do you use a DR Automation system or manual Runbooks?
