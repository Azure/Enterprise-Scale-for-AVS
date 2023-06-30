# Azure VMware Solution Well-Architected Framework: Performance Planning and Design Guidance

The Well-Architected framework assesses the performance of hybrid workloads that are running in the Azure VMware solution where the application footprint extends over to Azure Native Services.

## Infrastructure Performance

In the shared responsibility model, consumers of AVS are responsible for the provisioning of infrastructure inside of the Software Defined Datacenter. This involves right sizing the overall infrastructure footprint as well as the footprint for each application. 

### Compute 

Having performant workload requires knowing which SKU's are available in the region you are deploying. From there, leveraging a tool such as Azure Migrate to assess the server requirements needed to run the workloads. If there are workloads requiring high performance compute, these workloadscan benefit from affinity policies, RAID  configrations or may be worth investigating Azure native compute solutions such as VM's, App Services, containers, functions or HPC SKU's.

### Data Platform 

Database workloads may have native tools for scale such as ....Zonal deployments will also facilate horizontally scaling across different regions


### Management and Monitoring 
Microsoft tooling can help assess metrics for the servers to help with capacity planning and management. 
s
It's important not only understand the traffic patterns 
