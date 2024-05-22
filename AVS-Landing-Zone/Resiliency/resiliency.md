## Steps for Achieving Resiliency in the Azure VMware Solution

![Dual Region AVS](../Resiliency/dual-region-azure-netapp-highres.png)



### Multi-homed AVS Circuits with cross-region connectivity to Azure

ExpressRoute from on-premises should connect to two meet-me locations. You can add weights to the circuits. They should connect two gateways in separate regions. To test a loss of connectivity to Azure in one region, disconnect the VNET from that circuit and test

#### Optional - Global Reach on-premises environments

You can also force tunnel back to on-premises for a route to Azure regions. This is a longer path, but it can assist if you need connectivity back through Azure. You can accomplish this by creating a Global Reach connection to the two on-premises circuits. 


### Globally Peered Regional Hubs

Enable Global peering so that each VNET is learned by each ExpressRoute circuit. 

### Connect Primary and Secondary AVS Sites with Global Reach

This will enable replication of your VSAN datastores using a Disaster Recovery tool. In the event you lose an edge router, the edge router in the secondary region will be learned and provide a path back to Azure and, ultimately, on-premises. Creating an Expressroute connection directly to the secondary hub would be best. 

### Enable cross-region replication with ANF datastores

Enable cross-region replication of your ANF datastores to have a copy of your data. This will also provide ANF datastores to your secondary AVS site. For performance, ANF data stores should be kept in the same region as AVS. In the event of a disaster, failover to the secondary AVS site and ANF datastore. 

### Additional information 

Make sure all the Expressroute Gateways are of zone redundant SKUs. Review the best practices for ExpressRoute Gateways and connections found in the [AVS APRL guidance](https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-specialized-workloads/avs/)

