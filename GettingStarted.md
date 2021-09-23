# Getting Started

This guide is designed to help you get started with deploying AVS via the templates and scripts within this repository. Before you deploy, it is recommended to review the templates to understand the resources that will be deployed and the associated costs.

## Table Of Contents
- Planning
  - Deployment Scenarios
  - Deployment Templates & Scripts
- Deployment Flow
- Example Deployment Steps

# Prerequisites
Prior to deploying, you need to ensure you have met the following prerequisites:
- Access to an exiiting Azure Subscription with [contributor access](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)
- [Request  AVS host quota](https://docs.microsoft.com/en-us/azure/azure-vmware/request-host-quota-azure-vmware-solution) for all regions you wish to deploy to

# Planning
This section covers the high level steps for planning an AVS deployment and the decisions that need to be made.
The deployment will use the Microsoft provided Bicep/Powershell/Azure Cli templates from this repository and the customer provided configuration files that contain the system specific information. During the deployment, information from both will be merged.
It is important to note that these templates can be modified if required, and a series of smaller modules are provided to assist in developing templates for existing environments (see Brownfield deployment below)

## Deployment Scenarios
The AVS Deployment Automation Framework supports deployment into greenfield scenarios (no Azure infrastructure components exist) or brownfield scenarios (Azure infrastructure components exist). The [101-AVS-ESLZSingleRegionDeployment](101-AVS-ESLZSingleRegionDeployment/) template provides a complete AVS environment within a single template.

### Greenfield deployment
In the Greenfield scenario, no Azure infrastructure components for AVS on Azure deployment exist prior to deploying. The automation framework will create an AVS Private Cloud in one or more regions, create a virtual network & virtual network gateway local to each Private Cloud, and configure basic private cloud interconnectivity between regions.
It is important to consider the lifecycle of each of these components, if you want to deploy these items individually or via separate executions, then please see the Brownfield Deployment section.

### Brownfield deployment
In the Brownfield scenario, the Automation framework will deploy the solution using existing Azure resources. This gives you greater control over the resources, allowing you to either split up the deployment into smaller pieces or utilize existing resources. For these deployments, a series of smaller modules are provided with tightly scoped deployments, allowing you to [deploy HCX](008-AVS-HCX/), [configure monitoring](006-AVS-Monitor-Utilization/), and set up both [VNet](004-AVS-ExRConnection-NewVNet/) and [Global Reach](005-AVS-GlobalReach/) connectivity with an existing private cloud.

## Deployment Templates & Scripts
For each module a set of options are provided for deployment. All modules within this repository contain Bicep & ARM templates, with a subset also providing Powershell and Azure CLI scripting options.
It is important to note that you can deploy the Bicep or ARM templates via the [Azure CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-cli), [Powershell](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#powershell), or the Azure Portal. Depending on the version of Azure CLI and Powershell you have installed, you may need to update prior to deploying Bicep templates. You can check if you have support for bicep via the following commands:
```Azure CLI
az bicep version
```
```Powershell
bicep --help
```

# Deployment Flow
The deployment flow has three key steps: Requesting quota, deploying the Private Cloud, and configuring connectivity.

## Requesting quota
It is important to [request quota](https://docs.microsoft.com/en-us/azure/azure-vmware/request-host-quota-azure-vmware-solution) ahead of deploying any template that contains a Private Cloud resource, or modifies the scale of an existing cluster. When deploying manually via the Azure Portal, you will be prompted to request quota if you have skipped this step. However when deploying via template or script, the lack of quota will result in a failed deployment.
Quota for AVS is subscription and region specific, if you want to deploy AVS to multiple regions then you will need to request quota in each region.

## Deploying the private cloud
During this step, you will deploy the template that provisions the base infrastructure. It is important to ensure that the parameters that are provided to the template (provided in a parameters file or inline) are configured to match your networking configuration, and do not overlap with any existing networks. Changing the network ranges used once the private cloud is deployed will require the deletion of the Private Cloud.

## Configuring connectivity
If you choose not to deploy connectivity as part of the private cloud deployment, the final step is to configure connectivity. This can either be achieved via the [ExpressRoute Connection](002-AVS-ExRConnection-GenerateAuthKey/) template or script.

# Choosing the orchestration environment
The templates and scripts need to be executed from an execution environment, currently the supported environments are:

## PowerShell or AzureCLI via Azure Cloud Shell
https://docs.microsoft.com/en-us/azure/cloud-shell/overview
## Local Azure PowerShell
https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#powershell
## Local Azure CLI
https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-cli
## Azure DevOps or Automation Pipeline
Alongside command-line deployment you can also choose to automate the deployment of an environment. For more details see _x_

# Example Deployment Steps (Azure CLI)
1. Clone this repository onto either the Azure Cloud Shell or your local machine
2. Select the template you want to use, for the steps below we will be using the ARM template within [101-AVS-ESLZSingleRegionDeployment](101-AVS-ESLZSingleRegionDeployment/ARM/)
3. Modify the `ESLZDeploy.parameters.json` parameters file to define your location, networking, and alert emails
4. Before deploying, confirm the correct subscription is selected using the following command:
```Azure CLI
az account show
```
5. Kick off the AVS deployment using the template & parameters file. You will need to fill in the following arguments:
 - The location the deployment metadata will be stored: `-l Location`
You can use the `-c` option to validate what resources will be deployed prior to be deploying:
```Azure CLI
az deployment sub create -n AVSDeploy -l AustraliaEast -c -f "ESLZDeploy.deploy.json" -p "@ESLZDeploy.parameters.json"
```
You can also use `--no-wait` option to kick of the deployment without waiting for it to complete:
```Azure CLI
az deployment sub create -n AVSDeploy -l AustraliaEast -c --no-wait -f "ESLZDeploy.deploy.json" -p "@ESLZDeploy.parameters.json"
```

# Confirming Deployment
Once the deployment has completed it is important to check that the deployment succeeded & the AVS Private Cloud status is "Succeeded". If the Private Cloud fails to deploy, you may need to [raise a support ticket](https://docs.microsoft.com/en-us/azure/azure-vmware/fix-deployment-failures).