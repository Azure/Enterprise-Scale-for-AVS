# HCX Service Mesh

HCX Service Mesh is the mechanism used to activate the different HCX services like HCX Migration, Disaster Recovery, Network Extension, and WAN Optimization.

The creation of the HCX Service Mesh deploys Virtual Appliances in the source site as well as in the corresponding destination site (AVS) in pairs. It also activates the configuration, deployment, and serviceability of the appliance pairs.

A Service Mesh specifies a local and remote Compute Profile pair. When a Service Mesh is created, the HCX Service appliances are deployed on both the source and destination sites and are automatically configured by HCX to create the secure optimized transport fabric.

## HCX Service Mesh Site Pairs

You register the destination (AVS) HCX system in the Site Pairing interface at the source site. Pairing the source and the destination site is a requirement for creating an HCX Service Mesh.

## Compute Profiles

The compute profile defines the structure and operational details for the virtual appliances used in the Service Mesh architecture.

The compute profile will ask for a Deployment Resource as well as Service Resources.

### Deployment Resources

The resources (Cluster, Resource Pool, Datastore) where the appliances will be installed.

> **NOTE:** Ensure that all hosts/clusters can talk to the resources you've select like Datastores for example. Otherwise, you run the chance of a specific host/cluster not being able to reach a certain resource like a network or datastore where the HCX Appliances will be placed by the Service Mesh creation.

### Service Resources

The resources HCX will be able to service for migration, replication, protection.
The compute profile:
- Provisions the infrastructure at the source and AVS site.
- Provides the placement details (Resource Pool, Datastore) where the system places the virtual appliances.
- Defines the networks to which the virtual appliances connect.

The following conditions apply when deploying an HCX Service Mesh network:
- The integrated compute profile creation wizard can be used to create the compute and network profiles (Network Profiles can also be pre-created).
- HCX Interconnect service appliances are not deployed until a service mesh is created.

### Network Profiles