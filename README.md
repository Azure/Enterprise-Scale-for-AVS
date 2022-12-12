# Navigation Menu

* [Getting Started](GettingStarted.md)
* Deployment Scenarios
  * [Greenfield Deployment](AVS-Landing-Zone/GreenField/readme.md)
  * [Greenfield Lite Deployment](AVS-Landing-Zone/GreenField%20Lite/readme.md)
  * [Brownfield Deployment](BrownField/readme.md)
  * [Terraform modules for additional deployment scenarios and samples](terraform/readme.md)

---

# Enterprise-Scale for AVS

Welcome to the Enterprise Scale for Azure VMware Solution (AVS) repository

Enterprise-scale is an architectural approach and a reference implementation that enables effective construction and operationalization of landing zones on Azure, at scale. This approach aligns with the Azure roadmap and the Cloud Adoption Framework for Azure.

Enterprise-scale for AVS represents the strategic design path and target technical state for an Azure VMware Solution (AVS) deployment. This solution provides an architectural approach and reference implementation to prepare landing zone subscriptions for a scalable Azure VMware Solution (AVS) cluster. For the architectural guidance, check out [Enterprise-scale for AVS in Microsoft Docs](https://docs.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/enterprise-scale-landing-zone).

![Golden state platform foundation with AVS Landing Zone highlighted in red](./docs/images/azure-vmware-eslz-architecture.png)


The enterprise-scale for AVS only talks about with what gets deployed in the specific AVS landing zone subscription highlighted by the red box in the picture above. It is assumed that an appropriate platform foundation is already setup which may or may not be the official ESLZ platform foundation. This means that policies and governance should already be in place or should be setup after this implementation and are not a part of the scope this program. The policies applied to management groups in the hierarchy above the subscription will trickle down to the Enterprise-scale for AVS landing zone subscription.

This repository contains reference implementation scenarios based on a number of different scenarios. For each scenario, we have included both ARM and Bicep as the deployment languages

## This Repository

In this repository, you get access to various customer scenarios that can help accelerate the development and deployment of AVS clusters that conform with Enterprise-Scale for AVS best practices and guidelines. Each scenario aims to represent common customer experiences with the goal of accelerating the process of developing and deploying conforming AVS clusters using IaC as well as providing a step-by-step learning experience.

## AVS Greenfield Deployment

This deployment is best suited to those looking to provision a new AVS Private Cloud, the automation will let you choose and deploy the following:
- AVS Private Cloud
- Choose New or Existing virtual network (VNet)
- [Optional]: Deploy Azure Route Server for VPN Connections
- [Optional]: Deploy AVS Monitoring 
- [Optional]: Deploy HCX and SRM


|Greenfield deployment options:          |                           |
|:-------------------------------------|:------------------------: |
|Azure portal UI          |[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FAVS-Landing-Zone%2FGreenField%2FPortalUI%2FARM%2FESLZDeploy.deploy.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FAVS-Landing-Zone%2FGreenField%2FPortalUI%2FARM%2FESLZdeploy.PortalUI.json)      |
|Command line (Bicep/ARM)              |[![Powershell/Azure CLI](./docs/images/powershell.png)](https://github.com/Azure/Enterprise-Scale-for-AVS/tree/main/AVS-Landing-Zone/GreenField/Bicep)          |
|Terraform                             |[![Terraform](./docs/images/terraform.png)](https://github.com/Azure/Enterprise-Scale-for-AVS/tree/main/AVS-Landing-Zone/GreenField/Terraform)                  |

## AVS Greenfield Lite Deployment

This deployment is a lite version of the full AVS Greenfield Deployment and will deploy the following:
- New AVS Private Cloud - Allows for a custom resource group name and Private Cloud Name
- or Choose an existing AVS Private Cloud
- [Optional]: Deploy AVS Monitoring 
- [Optional]: Deploy HCX and SRM


|Greenfield Lite deployment:          |                           |
|:-------------------------------------|:------------------------: |
|Azure portal UI          |[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FAVS-Landing-Zone%2FGreenField%2520Lite%2FPortalUI%2FARM%2FGreenFieldLiteDeploy.deploy.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FEnterprise-Scale-for-AVS%2Fmain%2FAVS-Landing-Zone%2FGreenField%2520Lite%2FPortalUI%2FARM%2FGreenFieldLiteDeploy.PortalUI.json)      |


## Terraform modules for additional deployment scenarios and samples

We've created a number of additional Terraform modules for AVS related deployment activities. Details on these modules can be found in the [Terraform readme.](./terraform/readme.md) 

## Next Steps

Next steps, head to [Getting Started](GettingStarted.md) to review prerequisites and deployment options
