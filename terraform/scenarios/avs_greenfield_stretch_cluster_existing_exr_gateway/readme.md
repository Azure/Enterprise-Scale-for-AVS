# Implement AVS Stretch Cluster with integration to existing ExpressRoute Gateway

## Table of contents

- [Scenario Details](#scenario-details)
- [Scenario Implementation - Manual Steps](#scenario-implementation-with-manual-steps)
- [Scenario Implementation - Automation Options](#automation-implementation)
- [Appendix](#appendix)


## Scenario Details

### Overview
This scenario is meant for customers who want to implement a greenfield AVS stretch cluster environment using expressroute to make the hybrid connection. The solution implements a new stretch cluster and makes connections from each zone to the provided id for the existing expressRoute gateway.  AVS Landing Zone concepts can be explored in more detail via the [official documentation page](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/azure-vmware/ready). 

### Naming

Resource naming is configured by using local variables at the top of the root module.  Each name is configured to use a static prefix value that is provided via an input variable and a randomly generated 4 character suffix for uniqueness. It is expected that customers may find this naming to be inconsistent with their unique corporate naming conventions, so all the names are maintained in the locals for simplicity in modifying the naming during deployment. 

### Internet Ingress/Egress
Internet egress for AVS can be enabled with the internet_enabled toggle or by using an existing NVA to advertise the 0.0.0.0/0 route to AVS for internet access. Internet ingress is not covered in this scenario, but can be enabled through one of the standard AVS mechanisms.

### Network Inspection
Network inspection is out of scope for this scenario, but can be added using standard NVA mechanisms either within the private cloud, Azure, or on-premises.

### Assumptions

- This configuration covers a basic implementation of a stretch cluster integrating to an expressroute gateway

[(Back to top)](#table-of-contents)

## Scenario implementation with manual steps
The steps described below are an outline for deploying this scenario manually. If you wish to use the accompanying automation, then skip to the automation guidance below the manual workflow.

These steps represent deploying a configuration using the portal and vcenter.

- Create the required **resource groups** in the target subscription
    - Private Cloud - used to deploy the private cloud and any associated resources

- Deploy the **AVS private cloud**
    - Create a private cloud stretch cluster with an initial management cluster
    - Do not enable the internet access toggle as a default
    - Upon deployment completion, create the initial expressroute authorization keys 

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
    - <TODO: determine guest configuration and testing >
- Test the connectivity


[(Back to top)](#table-of-contents)
## Automation implementation

This scenario is organized using a root module included in this folder, and a number of child modules included in the modules subdirectory of the terraform directory of this repo.  This root module includes a tfvars sample file that contains an example set of input values. This module also includes a sample providers file that can be modified to fit your specific environment.

To deploy this module, ensure you have a deployment resource that meets the pre-requisites for Azure Deployments with terraform. Clone this repo to a local directory on the deployment machine.  Update the providers and tfvars sample files and remove the .sample extension.

Execute the terraform init/plan/apply workflow to execute the deployment.

[(Back to top)](#table-of-contents)

## Appendix




[(Back to top)](#table-of-contents)