# VMware HCX Licensing Options

HCX comes in 2 different licensing versions:
1.	VMware HCX Advanced
2.	VMware HCX Enterprise

Licenses for HCX Advanced version is included as part of Azure VMware Solution (AVS).

Customers can upgrade to VMware HCX Enterprise via the Azure Portal at no additional cost.

## HCX Advanced vs. HCX Enterprise

### HCX Advanced

More information can be found at [VMware HCX Services](https://docs.vmware.com/en/VMware-HCX/4.3/hcx-user-guide/GUID-32AF32BD-DE0B-4441-95B3-DF6A27733EED.html#GUID-32AF32BD-DE0B-4441-95B3-DF6A27733EED)

|HCX Advanced Services|Description|
|-----------|-----------|
|Interconnect (IX)|This service creates and secures connections between HCX installations, supporting management, migration, replication, and disaster recovery operations. This service is deployed as a virtual appliance.|
|WAN Optimization (WO)|The WAN Optimization service works with the HCX Interconnect service to improve the network performance through a combination of deduplication, compression, and line conditioning techniques. This service is deployed as a virtual appliance.|
|Network Extension (NE)|This service extends the Virtual Machine networks from an HCX source site to an HCX remote site. Virtual Machines that are migrated or created on the extended segment at the remote site are Layer 2 adjacent to virtual machines placed on the origin network. This service is deployed as a virtual appliance.|
|Bulk Migration|This service uses VMware vSphere Replication protocol to move virtual machines in parallel between HCX sites.|
|vMotion Migration|This migration method uses the VMware vMotion protocol to move a single virtual machine between HCX sites with no service interruption.|
|Disaster Recovery|The HCX Disaster Recovery service replicates and protects virtual machines to a remote data center.|

### HCX Enterprise

HCX Enterprise includes all the HCX Advanced Services plus the following:
|HCX Enterprise Services|Description|
|-----------|-----------|
|Mobility Groups|This service supports assembling one or more virtual machines into logical sets for migration and monitoring as a group. Group migration provides the flexibility to manage migrations by application, network, or other aspects of an environment.|
|Mobility Optimized Networking (MON)|MON is an enterprise capability of VMware HCX Network Extension (HCX-NE) feature. MON enables optimized application mobility for virtual machine application groups that span multiple segmented networks or for virtual machines with inter-VLAN dependencies, as well as for hybrid applications, throughout the migration cycle. Migrated virtual machines can be configured to access the internet and cloud provider services optimally, without experiencing the network tromboning effect.|
|Network Extension (NE) High Availability (HA)|Network Extension High Availability protects extended networks from disruptions associated with Network Extension appliance downtime. Network Extension High Availability creates a redundant pair, or group, of connections for Network Extension appliances. In the event that a Network Extension appliance fails of is taken offline, the active connection fails over to the standby connection, and the extended network operations continue without interruption.|
OS Assisted Migration (OSAM)|This migration service moves Linux or Windows-based non-vSphere guest virtual machines from their host environment to a VMware vSphere based environment. This service comprises of two appliances. The HCX Sentinel Gateway appliance is deployed at the source site, and the HCX Sentinel Data Receiver appliance at the destination site. This service also requires the installation of HCX Sentinel Software on each guest virtual machine.|
|Replication Assisted vMotion (RAV) |This service uses both VMware vSphere Replication and vMotion technologies for large-scale, parallel migrations with no service interruption.|
|Traffic Engineering  <p style="padding-left: 20px;">- Application Path Resiliency</p><p style="padding-left: 20px;">- TCP Flow Conditioning</p> | VMware HCX provides settings for optimizing network traffic for HCX Interconnect and Network Extension services. <p style="padding-left: 20px;">- The Application Path Resiliency service creates multiple tunnel flows, for both Interconnect and Network Extension traffic, those may follow multiple paths across the network infrastructure from the source to the destination data centers. The service then intelligently forwards traffic through the tunnel over the optimal path and dynamically switches between tunnels depending on traffic conditions.</p><p style="padding-left: 20px;">-	The TCP Flow Conditioning service adjusts the segment size during the TCP connection handshake between end points across the Network Extension. This optimizes the average packet size to reduce fragmentation and lower the overall packet rate.</p>|


