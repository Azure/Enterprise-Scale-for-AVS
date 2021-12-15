# Getting Started

This guide is designed to help you get started with deploying AVS via the templates and scripts within this repository. Before you deploy, it is recommended to review the templates to understand the resources that will be deployed and the associated costs.

## Table Of Contents

- Prerequisites
- Planning
  - Deployment Scenarios
  - Deployment Templates & Scripts
- Deployment Flow
- Example Deployment Steps

## Prerequisites

Prior to deploying, you need to ensure you have met the following prerequisites:

- Access to an existing Azure Subscription with [contributor access](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)
- [Request AVS host quota](https://docs.microsoft.com/en-us/azure/azure-vmware/request-host-quota-azure-vmware-solution) for all regions you wish to deploy to
- Registered the Microsoft.AVS resource provider with subscription to be used for deployment.

## Planning

This section covers the high level steps for planning an AVS deployment and the decisions that need to be made.
The deployment will use the Microsoft provided Bicep/PowerShell/Azure CLI templates from this repository and the customer provided configuration files that contain the system specific information. During the deployment, information from both will be merged.
It is important to note that these templates can be modified if required, and a series of smaller modules are provided to assist in developing templates for existing environments (see Brownfield deployment below)

## Deployment Scenarios

The AVS Automation Framework supports deployment into greenfield scenarios (no Azure infrastructure components exist) or brownfield scenarios (Azure infrastructure components exist).

### Greenfield deployment

In the Greenfield scenario, no Azure infrastructure components for AVS on Azure deployment exist prior to deploying. The automation framework will create an AVS Private Cloud in one or more regions, create a virtual network & virtual network gateway local to each Private Cloud, and configure basic private cloud connectivity.

It is important to consider the life cycle of each of these components, if you want to deploy these items individually or via separate executions, then please see the Brownfield Deployment section.

The [AVS Green Field](AVS-Landing-Zone/GreenField) template provides a complete AVS landing zone reference implementation within a single template.

### Brownfield deployment

In the Brownfield scenario, the Automation framework will deploy the solution using existing Azure resources. This gives you greater control over the resources, allowing you to either split up the deployment into smaller pieces or utilize existing resources. 

## Deployment Options

For each module a set of options are provided for deployment. All modules within this repository contain Bicep & ARM templates, with a subset also providing PowerShell and Azure CLI scripting options.
It is important to note that you can deploy the Bicep or ARM templates via the [Azure CLI](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install#azure-cli), [PowerShell](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install#powershell), or the Azure Portal. Depending on the version of Azure CLI and PowerShell you have installed, you may need to update prior to deploying Bicep templates. You can check if you have support for bicep via the following commands:

```Azure CLI
az bicep version
```

```Powershell
bicep --help
```

## Deployment Flow

The deployment flow has three key steps: Requesting quota, deploying the Private Cloud, and configuring connectivity.

### 1. Requesting quota

It is important to [request quota](https://docs.microsoft.com/azure/azure-vmware/request-host-quota-azure-vmware-solution) ahead of deploying any template that contains a Private Cloud resource, or modifies the scale of an existing cluster. When deploying manually via the Azure Portal, you will be prompted to request quota if you have skipped this step. However when deploying via template or script, the lack of quota will result in a failed deployment.
Quota for AVS is subscription and region specific, if you want to deploy AVS to multiple regions then you will need to request quota in each region.

### 2. Deploying the private cloud

During this step, you will deploy the template that provisions the base infrastructure. It is important to ensure that the parameters that are provided to the template (provided in a parameters file or inline) are configured to match desired networking configuration, and do not overlap with any existing networks. Changing the network ranges used once the private cloud is deployed will require the deletion of the Private Cloud.

### 3. Configuring connectivity

If you choose not to deploy connectivity as part of the private cloud deployment, the final step is to configure connectivity by following [AVS Networking](https://github.com/Azure/Enterprise-Scale-for-AVS/blob/main/BrownField/readme.md#avs-networking).

## Choosing the orchestration environment

The templates and scripts need to be executed from an execution environment, currently the supported environments are:

- [PowerShell or AzureCLI via Azure Cloud Shell](https://docs.microsoft.com/azure/cloud-shell/overview)

- [Local Azure PowerShell](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install#powershell)

- [Local Azure CLI](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install#azure-cli)

- Azure DevOps or Automation Pipeline

Alongside command-line deployment you can also choose to automate the deployment of an environment.

## Next Steps

Once all the prerequisites are complete, choose either head [greenfield deployment](AVS-Landing-Zone/GreenField) for a new AVS private cloud deployment or to [brownfield deployment](BrownField) for configuring additional components on an existing AVS private cloud.
