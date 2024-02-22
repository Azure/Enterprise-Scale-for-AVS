# AVS LANDING ZONE FAQ

## Connectivity from On-Premises to Azure VMware Solution

### Can traffic traverse from On-Prem to Azure end-to-end with an IPSec tunnel?

Yes. Traffic can traverse directly from On-Premise directly to the AVS NSX-T DC Edge. Consider using Public IP down to the NSX-T DC Edge for default route advertisement. 

### Can traffic traverse from On-Prem to Azure without Global Reach? 

Yes, if natively routing traffic from on-prem to AVS is desired, this is possible either with a managed Secured VWAN Hub or an Azure Native VNET Hub + Azure Route Server. If default route advertisement occurs either from On-Prem or AVS, both of these solutions are possible.  

### Can traffic traverse from On-Prem to Azure without Global Reach and default route advertisement positioned in Azure? 

Secured vWAN Hub with Azure Firewall or Third-Party NVA will work.  If the default route advertisement needs to happen within a Hub VNET, Azure Firewall will not work because it does not speak BGP. Customer must purchase a Third Party BGP-capable NVA.    

### Can the Secured vWAN Hub provide the transit and also filter traffic end-to-end from On-Prem to AVS?  

Technically, yes. This is only possible with Route Intent which is in public preview. It's scale limits, multi-regional deployment and integration with Azure PaaS services are still under review. Deployment is at user discretion without SLA from Microsoft.  

Consider using two Hub and Spoke networks, each with a BGP-capable NVA and tunnel the traffic through the two appliances in each hub. This is option has the most complexity, but comes with the most flexibility and scale. 

### How to I prevent workloads on-premises from learning a default route from Azure?

Add a route filter to the on-premises firewall. Microsoft doesn't not block default routes at it's edge devices.   

### Can I encrypt traffic over Global Reach?

You cannot encrypt traffic with IPsec over Global Reach. You can however encrypt traffic at the physical layer with Macsec. 

### Can I access vCenter Server when using advertising a default route from on-premises?

AVS Management plane operations such (e.g vMotion, NSX-T Manager, HCX, etc) receive traffic via default route, will not send a response back to on-premises. Accessing vCenter Server from on-premises requires well-known, specific routes. 

Consider using Azure Bastion to access vCenter Server securely.
