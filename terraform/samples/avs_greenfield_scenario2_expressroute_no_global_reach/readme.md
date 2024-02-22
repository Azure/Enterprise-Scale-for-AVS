# Deploy a scenario 2 architecture with Cisco 8kvs

## Table of contents

- [Deploy a scenario 2 architecture with Cisco 8kvs](#deploy-a-scenario-2-architecture-with-cisco-8kvs)
  - [Table of contents](#table-of-contents)
  - [Sample Details](#sample-details)
  - [Automation implementation](#automation-implementation)
  - [Appendix](#appendix)


## Sample Details

Use this module to deploy the scenario 2 architecture (transit hub with routing NVA's) that uses Azure firewall and Cisco 8000v's as the routing NVA.  This sample also allows for the configuration of a second private cloud that can be used to simulate an on-premises environment.


[(Back to top)](#table-of-contents)

## Automation implementation

This sample is a root module that calls a number of child modules included in the modules and scenarios subdirectories of the terraform directory.  

To deploy this module, ensure you have a deployment machine that meets the pre-requisites for Azure Deployments with terraform. Clone this repo to a local directory on the deployment machine.  Modify the sample tfvars file to change the input values.  If you wish to use a terraform state file, you can update the providers.tf file with your storage account values.

Execute the terraform init/plan/apply workflow to execute the deployment.

[(Back to top)](#table-of-contents)

## Appendix


[(Back to top)](#table-of-contents)