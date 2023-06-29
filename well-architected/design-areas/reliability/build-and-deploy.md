# Azure VMware Solution Well-Architected Framework: Reliability Discovery and Assessment

The Build and Deploy section implements the supporting infrastructure  (SDDC) is deployed and configured based on the information gathered from the Assess and Discovery section. 

## Concepts


- Identity and access management services (LDAPS)
- Infrastructure services (Virtual Machines, Virtual Networks, vSAN)
- Automation of infrastructure, workload, and security services

### Compute
- Create a placement policy: https://learn.microsoft.com/en-us/azure/azure-vmware/create-placement-policy#create-a-placement-policy
- Deploy Stretched clusters: https://learn.microsoft.com/en-us/azure/azure-vmware/deploy-vsan-stretched-clusters#deploy-a-stretched-cluster-private-cloud.
- Configure storage policies: https://learn.microsoft.com/en-us/azure/azure-vmware/configure-storage-policy#list-storage-policies
  
### Networking 
- Activate high availability (HA) for HCX network extension: https://learn.microsoft.com/en-us/azure/azure-vmware/configure-hcx-network-extension-high-availability#activate-high-availability-ha
- Create a zone redundant gateway: https://learn.microsoft.com/en-us/azure/vpn-gateway/create-zone-redundant-vnet-gateway
- Review reliability best practices: https://learn.microsoft.com/en-us/azure/well-architected/resiliency/design-best-practices

### Backups

- Azure Backup servers must live on a Recovery Vault for long-term retention. Local/Geo-Redundant must be set before configuring backups: https://learn.microsoft.com/en-us/azure/azure-vmware/set-up-backup-server-for-azure-vmware-solution#set-storage-replication

### Automation
- Setup Monitoring and Alerting for host quota: https://github.com/Azure/Enterprise-Scale-for-AVS/tree/main/BrownField/Monitoring/AVS-Utilization-Alerts
- Send syslogs to Log Analytics workspace: https://learn.microsoft.com/en-us/azure/azure-vmware/configure-vmware-syslogs
  






