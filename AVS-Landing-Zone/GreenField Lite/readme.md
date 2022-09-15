
|Greenfield Lite Deployment          |                           |
|:-------------------------------------|:------------------------: |
|Azure portal UI          |[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FAVS-Landing-Zone%2FGreenField%2520Lite%2FPortalUI%2FARM%2FGreenFieldLiteDeploy.deploy.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FAVS-Landing-Zone%2FGreenField%2520Lite%2FPortalUI%2FARM%2FGreenFieldLiteDeploy.PortalUI.json)      |


# AVS: Greenfield Lite Deployment

Greenfield Lite deployment of Azure VMware Solution is built specifically to allow for a quick and custom deployment of AVS while also including some important monitoring, and the ability to enable the AVS Addons.

## Prerequisites

To ensure this deployment is successful, it is recommended that all the instructions from the [Getting Started](../../GettingStarted.md) section are completed.

## What will be deployed?

This reference implementation will allow you to deploy a new AVS Private Cloud, or choose an existing private cloud and also allow the deployment of AVS addons and monitoring as per operational best practices. AVS will not be connected to any virtual network or be peered to any ExpressRoute link, these steps will have to be done manually post deployment. For a full automated AVS deployment with all connectivity options included, please see the Greenfield deployment [here](../Greenfield/readme.md)

The following components will be deployed:

| **Resource Type**                | **Resource Group**     | **Resource Name**     |
| :------------------------------- | :--------------------- | :-------------------- |
| **AVS Private Cloud**            | Custom Name | Custom Name      |
| **Monitoring**                   | Custom Name  | ${PrivateCloudName}-ActionGroup |

###### Note:  The deployment allows for custom naming of the AVS Private Cloud and Resource Group

Each component is discussed in detail below.

### AVS Private Cloud

This is the core component of deployment. AVS Private Cloud consists of one or more clusters. Each cluster contains at least three ESXi hosts/nodes. This deployment create a single private cloud with a single cluster with three nodes. A network address space with non-overlapping IP addresses between on-premise environment, Azure Virtual Network and private cloud needs to be provided at deployment time. Following add-ons are also possible to be deployed at the same time.

- HCX
- SRM

SRM license key and vSphere Replication server count needs to be provided if SRM add-on is selected to deployment. 

### Monitoring

Reference implementation deploys following components essential for AVS Private Cloud monitoring.

- Metric Alerts: These alerts track important metrics such as CPU, Memory and Storage utilization.
- Activity Log Alerts: These alerts monitor any service health related logs.  

These alerts are sent to Email address provided at the time of deployment.

## How to deploy this reference implementation

We have a few options available to deploy this AVS Landing zone:

- [ARM (Portal)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FAVS-Landing-Zone%2FGreenField%2520Lite%2FPortalUI%2FARM%2FGreenFieldLiteDeploy.deploy.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FAVS-Landing-Zone%2FGreenField%2520Lite%2FPortalUI%2FARM%2FGreenFieldLiteDeploy.PortalUI.json)
