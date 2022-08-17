# Resource Group Design

High level around Enterprise Scale for AVS.  

1. What is the idea behind it?  
1. Why should you use it?  
1. What are we doing differently with this series?  

## Objective

Deploy the base resource groups needed as per the design below, we are focusing on the green highlighted aspects.

![azure-vmware-eslz-rg-focus](files/images/azure-vmware-eslz-architecture-resource_group.png)

## [Az CLI deployment](files/azcli/deploy.sh)

```bash
## define resource groups to be created
resourceGroups=(private_cloud_rg1 networking_rg1 operations_rg1 jumpbox_rg1)

## Define location for resource groups
resourceGroupLocation=northeurope

for resourceGroup in "${resourceGroups[@]}"; 
    do echo "$resourceGroup"; 
    az group create --name $resourceGroup --location $resourceGroupLocation;
    az group update --name $resourceGroup --set tags.deploymentMethod=azcli tags."Can Be Deleted"=yes tags.Technology=AVS;
    echo "Resource group $resourceGroup created successfully";
    done
```

## [PowerShell deployment](files/powershell/deploy.ps1)

```powershell
## Define resource groups
$resourceGroups = "private_cloud_rg","networking_rg","operational_rg","jumpbox_rg"

## Define location for resource groups
$resourceGroupLocation = "northeurope"

## Define tags to be used if needed
$tags = @{"deploymentMethod"="PowerShell"; "Can Be Deleted"="yes"; "Technology"="AVS"}

## create a loop to create resource groups
foreach ($resourceGroup in $resourceGroups) {
  ## Create resource group
  $resourceGroupName = $resourceGroup
  $rg = New-AzResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation 
  New-AzTag -ResourceId $rg.ResourceId -Tag $tags
  write-host "Resource group $resourceGroupName created successfully"
}
```

## [Bicep](files/bicep/main.bicep)

```bash
param resourceGroups array = [
  'private_cloud_rg2'
  'networking_rg2'
  'operational_rg2'
  'jumpbox_rg2'
]

param resourceGroupLocation string = 'northeurope'

param resourceTags object = {
  'deploymentMethod': 'Bicep'
  'Can Be Deleted': 'yes'
  'Technology': 'AVS'
}

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = [for resourceGroup in resourceGroups: {
  name: resourceGroup
  location: resourceGroupLocation
  tags: resourceTags
}]


output deployedResourceGroups array = resourceGroups

```

[Deploy With Bicep - AZ CLI Deployment](files/bicep/deploy.sh)  

```bash
## location to be deployed into
deploymentLocation=northeurope

## bicep Deployment
## Bicep File name
bicepFile=main.bicep
## naming our deployment based on file name and date
deploymentName=${bicepFile}-$(date +"%d%m%Y-%H%M%S")"-deployment"
az deployment sub create -n $deploymentName -l ${deploymentLocation} -c -f $bicepFile 
```

[Deploy With Bicep - PowerShell Deployment](files/powershell/deploy.ps1)

```powershell
## location to be deployed into
$deploymentLocation = "northeurope"

## bicep Deployment
## Bicep File name
$bicepFile = ".\main.bicep"
$deploymentName = ($bicepFile).Substring(2) + "-" +(get-date -Format ddMMyyyy-hhmmss) + "-deployment"
#New-AzSubscriptionDeployment -TemplateFile $bicepFile -Location $deploymentLocation -Name $deploymentName
New-AzDeployment -name $deploymentName -location $deploymentLocation -templateFile $bicepFile
```

## Files for download

[Deploy with Azure CLI](files/azcli/deploy.sh)  
[Bicep File](files/bicep/main.bicep)  
[Deploy With Bicep - PowerShell Deployment](files/bicep/deploy.ps1)  
[Deploy With Bicep - AZ CLI Deployment](files/bicep/deploy.sh)  
[Deploy with Powershell](files/powershell/deploy.ps1)
