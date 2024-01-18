# Implement AVS with an existing VWAN hub

## Table of contents

- [Implement AVS with an existing VWAN hub](#implement-avs-with-an-existing-vwan-hub)
  - [Table of contents](#table-of-contents)
  - [Scenario Details](#scenario-details)
    - [Overview](#overview)
    - [Naming](#naming)
    - [Internet Ingress/Egress](#internet-ingressegress)
    - [Assumptions](#assumptions)
  - [Automation implementation](#automation-implementation)
  - [Scenario implementation with manual steps](#scenario-implementation-with-manual-steps)
  - [Appendix](#appendix)


## Scenario Details

### Overview
This scenario is meant for customers who want to implement a new AVS private cloud connecting to an existing VWAN virtual hub. The solution implements a new AVS private cloud and creates an expressRoute connection to the VWAN hub. If the hub is a secure hub, then a flag can be set to toggle the connection to use the Azure firewall in the hub. AVS Landing Zone concepts can be explored in more detail via the [official documentation page](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/azure-vmware/ready). 

![Existing VWAN Hub](./images/avs_vpn_hub_spoke.png)

### Naming

Resource naming is configured by using local variables at the top of the root module.  Each name is configured to use a static prefix value that is provided via an input variable and a randomly generated 4 character suffix for uniqueness. It is expected that many customers will find this naming to be inconsistent with their unique corporate naming conventions, so all the names are maintained in the locals for simplicity in modifying the naming during deployment. 

### Internet Ingress/Egress
Internet ingress and egress to AVS will leverage the existing customer VWAN configuration. This requires that the existing VWAN routing tables will manage the 0.0.0.0/0 route being propagated to AVS. This scenario does not create any additional routing table associations on the AVS expressRoute connection, so if any additional VWAN route tables need to be associated beyond the default route table those will need to be added to the expressRoute connection resource.

### Assumptions

- The existing VWAN hub will be configured with an ExpressRoute gateway.
- The default route table has the 0.0.0.0/0 route sending internet traffic to the preferred security appliance

[(Back to top)](#table-of-contents)

## Automation implementation

This scenario is organized using a root module included in this folder, and a number of child modules included in the modules subdirectory of the terraform directory of this repo.  This root module includes a tfvars sample file that contains an example set of input values. This module also includes a sample providers file that can be modified to fit your specific environment.

To deploy this module, ensure you have a deployment machine that meets the pre-requisites for Azure Deployments with terraform. Clone this repo to a local directory on the deployment machine.  Update the providers and tfvars sample files and remove the .sample extension.

Execute the terraform init/plan/apply workflow to execute the deployment.

[(Back to top)](#table-of-contents)

## Scenario implementation with manual steps
The steps described below are an outline for deploying this scenario manually. If you wish to use the accompanying automation, then skip to the automation guidance below the manual workflow.

These steps represent deploying a configuration using the portal and vcenter.

- Create the required **resource groups** in the target subscription
    - Private Cloud - used to deploy the private cloud and any associated resources
- Deploy the **AVS private cloud**
    - Create a private cloud with an initial management cluster
    - Do not enable the internet access toggle as this will be managed in the existing VWAN hub
    - Upon deployment completion, create an initial expressroute authorization key for attaching to the Hub ExpressRoute Gateway
- Create a new **ExpressRoute connection** linking AVS to the existing ExpressRoute Gateway in the VWAN hub
    - Configure any additional route table associations if required to ensure the 0.0.0.0/0 route gets propagated to AVS
    - Enable the **Propagate Default Route** on the AVS expressRoute connection
- Create **Service Health Alerts** for the AVS SLA related items
    Name    | Description | Metric | SplitDimension | Threshold | Severity 
    ---     | :---:       | :---:  | :---:          | :---:     | :---:
    **CPU**     | CPU Usage per Cluster | EffectiveCpuAverage | clustername | 80 | 2
    **Memory**  | Memory Usage per Cluster | UsageAverage     | clustername | 80 | 2 
    **Storage** | Storage Usage per Datastore | DiskUsedPercentage | dsname | 70 | 2 
    **StorageCritical** | Storage Usage per Datastore| DiskUsedPercentage | dsname | 75 | 0 
- Configure the AVS guest network elements 
    - Configure a new DHCP server
    - Create a new segment and link to the DHCP server
    - Create a DNS scope on the AVS private cloud for any custom DNS required for LDAP configuration
- Deploy a test VM into AVS 
- Test the connectivity from the on-premises connection and validate any internet connectivity

[(Back to top)](#table-of-contents)


## Appendix




[(Back to top)](#table-of-contents)