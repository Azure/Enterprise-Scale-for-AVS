# VMware HCX Components

## HCX Connector & HCX Cloud Manager
![HCX Connector](./images/hcx-connector.png)
HCX Connector

![HCX Cloud Manager](./images/hcx-cloudmanager.png)
HCX Cloud Manager

In an HCX site-to-site architecture, there is notion of an HCX source and an HCX destination environment. This is true also for AVS-to-AVS deployments as well. Depending on the architecture and environment HCX is being deployed in, there may be a specific installer: HCX Connector or HCX Cloud.

HCX Connector is always deployed as the source. HCX Cloud is typically deployed as the destination, but it can be used as the source in AVS-to-AVS deployments. In AVS, Microsoft deploys HCX Cloud through the Add-Ons tab in the Azure Portal AVS Private Cloud blade. Customer is responsible for deploying HCX Connector on-premises.

Microsoft deploys HCX Cloud in the management zone within AVS. Both HCX Cloud and HCX Connector are a one-to-one relationship to a vCenter environment.

## HCX-IX - Interconnect Appliance

![HCX Interconnect Appliance](./images/hcx-ix.png)
HCX-IX - Interconnect Appliance

The HCX-IX service appliance provides replication and vMotion-based migration capabilities to Azure VMware Solution (AVS), providing strong encryption, traffic engineering, and virtual machine mobility.

This appliance includes the deployment of the Mobility Agent service that appears as a host object in vCenter server. The Mobility Agent is the mechanism that HCX uses to perform vMotion, Cold, and Replication Assisted vMotion (RAV) migrations to a destination site.

## HCX-WO - WAN Optimization Appliance

![HCX WAN Optimization Appliance](./images/hcx-wo.png)
HCX-WO - WAN Optimization Appliance

The VMware HCX WAN Optimization service improves performance characteristics of the private lines or Internet paths by applying WAN Optimization techniques like data de-duplication and line conditioning.

## HCX-NE - Network Extension Appliance

![HCX Network Extension Appliance](./images/hcx-ne.png)
HCX-NE - Network Extension Appliance

The HCX Network Extension service provides layer 2 connectivity between sites. HCX Network Extension provides the ability to keep the same IP and MAC addresses during virtual machine migrations. When the Network Extension service is enabled on a Service Mesh, a pair of virtual appliances will be deployed: one in the source and one in the destination site (AVS).

## HCX-SGW - Sentinel Gateway Appliance

![HCX Sentinel Gateway Appliance](./images/hcx-sentinel.png)
HCX-SGW - Sentinel Gateway Appliance

HCX Enterprise also includes a service called OS Assisted Migration (OSAM). With OSAM you can migrate guest (non-vSphere) virtual machines from an on-premises data center to AVS. The OSAM service has several components: the HCX Sentinel software that is installed on each virtual machine to be migrated, a Sentinel Gateway (SGW) appliance for connecting and forwarding guest workloads in the source environment, and a Sentinel Data Receiver (SDR) in the destination (AVS) environment.

## HCX-SDR - Sentinel Data Receiver Apppliance

![HCX Sentinel Data Reciever Appliance](./images/hcx-sdr.png)

The HCX Sentinel Data Receiver (SDR) appliance works with the HCX Sentinel Gateway appliance to receive, manage, and monitor data replication operations at the destination environment.
