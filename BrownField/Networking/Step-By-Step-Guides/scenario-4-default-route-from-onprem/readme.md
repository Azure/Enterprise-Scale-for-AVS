# Scenario 4: Egress from Azure VMware Solution through 0.0.0.0/0 advertisement from on-premises

XXX

## Prerequisites

* blah
* blah
* blah

## Deployment Steps

XXX

### Step 1

Validate internet traffic from on-premise location is routed via router deployed and running at on-premise location.

### Step 2

Establish a GlobalReach connectivity between ER circuits connecting on-premise location to Azure and AVS to Azure.

### Step 3

Validate that AVS routes are propagated to on-premise location

### Step 4

Validate that on-premise routes are propagated to AVS

### Step 5

Validate that 0.0.0.0/0 route ia available to AVS with next hop configured as on-premise router

### Step 6

Validate that AVS guest VMs can reach to internet

## Next Steps

Consider using using a step by step deployment guide on [a third-party NVA in the hub VNet inspecting traffic between AVS and the internet and between AVS and Azure VNets](https://docs.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-network-topology-connectivity#scenario-5-a-third-party-nva-in-the-hub-vnet-inspects-traffic-between-avs-and-the-internet-and-between-avs-and-azure-vnets).
