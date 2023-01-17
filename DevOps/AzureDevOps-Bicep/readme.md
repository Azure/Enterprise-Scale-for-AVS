# Azure DevOps - Deploying Greenfield via Bicep

This guide provides a sample implementation for deploying the Greenfield Bicep modules via Azure DevOps. 

## Pre-reading

Prior to starting with this guide it is recommended to read:
- [Getting Started](../../GettingStarted.md) 
- [How to deploy Bicep using Azure CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-cli)
- [Azure DevOps Pipelines - Getting Started](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/pipelines-get-started?view=azure-devops)

## Considerations

As the Azure VMware Solution deployment process may take multiple hours to deploy or update, it is important to consider how we execute the deployment tasks, below shows a strategy of utilizing self-hosted agents to remove the per-pipeline limits. The Azure DevOps documentation provides guidance on when you should use your own build agent.  

While the guide below is designed to guide you through an implementation process, this can be modified to meet the needs of your organisation, and ideally should be aligned with your internal DevOps process. Under the hood an Azure VMware Solution deployment is the same as any ARM based Azure service, so the same patterns and practices apply. For example, this guide recommends creating a new Repository for your Azure VMware Solution templates, but an existing repository and trigger paths could be used as an alternative.

## Prerequisites

Before you begin, you'll require:
- An Azure DevOps Organization and [Project](https://learn.microsoft.com/en-us/azure/devops/organizations/projects/about-projects?view=azure-devops) to create the repository and pipeline within, with permissions to create a repository and pipeline.

- A [self-hosted agent](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops&tabs=browser) that can be leveraged for the deployment process, or if the deployment will run for less than 6 hours, a Microsoft hosted agent may be used.

- An Azure Subscription with [allocated quota](https://learn.microsoft.com/en-us/azure/azure-vmware/request-host-quota-azure-vmware-solution) to deploy an Azure VMware Solution private cloud within your [preferred region](https://aka.ms/avsregions).

- A [service principal](https://learn.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli) configured with contributor rights to your Azure Subscription. This should be added as a [service connection](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml).

- Documented [parameter values](../../AVS-Landing-Zone/GreenField/Bicep/ESLZDeploy.parameters.json) for an Enterprise Scale for AVS deployment.

## Step 1 - Configuring your repository

- To begin, create a repository within your Azure DevOps Project. This can be found by selecting the "Repos" option in Azure DevOps, and from the top drop-down menu selecting "New Repository".

- Using the "Git" repository type, enter a repository name, and tick the "Add a README" box (this will initialize the repository with a default main branch and readme file).

- Click the "Clone" button, and using your Git client of choice, clone the repository to your local machine.

## Step 2 – Configuring the template

- Using the same process as above, clone the Enterprise Scale for AVS repository to your local computer.  
_For this process we will be using the Greenfield Bicep templates that come as part of Enterprise Scale for AVS, but this same process can also be applied to the Terraform or ARM template folder if desired._  

- Navigate to the [AVS-LandingZone/GreenField/Bicep](../../AVS-Landing-Zone/GreenField/Bicep/) folder and copy all of the files within into the repository you cloned in Step 1. These files should be at the root of the repository. _(Note: if you change the path of these files, you will need to update the pipeline.)_  
_By default, the template comes with an example parameters file. You have the option to either pass in the configuration within the Pipeline YAML file or check in the parameters as a separate file. For this guide we will be creating a development parameters file, but this process can be repeated for test and production, or alternative regions, allowing a single template to be deployed to multiple environments or regions._

- Fill in the parameters file (`ESLZDeploy.parameters.json`) to match your desired configuration, making sure that the address space you define for the Private Cloud and other networks does not overlap with existing networks in Azure or on-premises.
_The JumpboxPassword can be removed from this file, as we will be passing it in at deploy time._

- Once saved, check-in and push the code using your Git client of choice. You can confirm the code has been pushed by navigating to the repository in Azure DevOps.

## Step 3 – Building the pipeline

- Create a file named `avs-pipeline.yml` within your repository and copy in the contents of the [avs-pipeline.yml](./avs-pipeline.yml) found with this guide. This will be used for our pipeline definition, providing a simple starting point. You can modify this pipeline for multiple environments and staged deployments as required.

- Within the `avs-pipeline.yml` file, modify the following values:
  - `azureServiceConnectionName` - This should be set to match the name of service connection setup as part of the prerequisites.
  - `location` - This should be modified to match the region you wish to deploy to.
  - `pool: name` - This should be modified to match the build agent pool you wish to use for deployment.
  - `environment` - This should be modified to represent the name of the enviroment you are deploying to, this will be used to add a deployment gate.

- Once completed, ensure the files are saved and push all changes via your Git client. It is recommended to check within Azure DevOps to ensure the files have successfully been pushed.
_For this example, we have pushed straight to the main branch, but you do have the option to push to a feature branch and then merge changes in via Pull Requests._

## Step4 – Creating the environment

- Navigate to the "Environments" section under "Pipelines" within Azure DevOps

- Click "New environment" and fill in the environments name you setup in Step 3 (by default this is `AVS-Production`). Leave the Resource type set to "None" for the moment.

- If you would like to set up an approval process for this environments (so deployments don’t automatically roll out):
  - Click the 3 dots in the top right corner and select "Approvals and checks". 
  - From this menu you can add an "Approvals" gate, allowing you to define who should control if a deployment should be released to this environments.

## Step 5 – Creating the pipeline
- Navigate to the "Pipelines" section within Azure DevOps and select "New pipeline"

- Select "Azure Repos Git" as the code source, select the repository you created in Step 1.

- Choose "Existing Azure Pipelines YAML file", and from the drop down select the `/avs-pipeline.yml` file. Click continue.

- Before running the pipeline we need to add a secret variable for the jumpbox password. Select the Variables button in the top right, click "add a new variable", and add a new variable named `JumpboxPassword`. Select the "Keep this value secret" option before clicking ok. Click Save.  
__Important: You will need ensure this password meets the [minimum requirements for VM passwords](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm-)__  
_If you are not deploying a jumpbox as part of this process, you can either skip this step and remove the jumpboxPassword parameter from the pipeline yml file or configure it with a blank value._

- In the top right corner, select click "Run" to create the pipeline and kick off execution. If you want to save the pipeline but not run it, use the drop-down next to Run and select Save.

- Once the pipeline has started, you may need to authorize access to certain resources. From the "Pipelines" option within Azure DevOps, click on the pipeline you created and then click on the latest run. If there is a prompt asking for permission, click the view button and permit access to the service connection and queue. You will only need to do this when modifying either the service connection name, or the agent pool the task should run on.

- Within the pipeline you should see 2 stages, one for build (template validation), and one for the deployment. You can modify the pipeline to add additional environments, and using the Environments section under Pipelines you can control release gating.

## Helpful Links:
- [Azure VMware Solution ESLZ DevOps Guidance](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-platform-automation-and-devops)
- [Azure VMware Solution ESLZ Repository](https://github.com/Azure/Enterprise-Scale-for-AVS)
- [Azure DevOps Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/?view=azure-devops)
