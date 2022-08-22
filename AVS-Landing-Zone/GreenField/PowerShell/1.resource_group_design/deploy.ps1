##################################################
#                                                #
#  Author : Fletcher Kelly                       #
#  Github : github.com/fskelly                   #
#  Purpose : AVS - Deploy resource groups sample #
#  Built : 11-July-2022                          #
#  Last Tested : 02-August-2022                  #
#  Language : PowerShell                         #
#                                                #
##################################################

## resource group variables
## Define location for resource groups
$technology = "avs"
$resourceGroupLocation = "germanywestcentral"

## Define resource groups
$resourceGroups = "$technology-$resourceGroupLocation-private_cloud_rg","$technology-$resourceGroupLocation-networking_rg","$technology-$resourceGroupLocation-operational_rg","$technology-$resourceGroupLocation-jumpbox_rg"

## Define tags to be used if needed
$tags = @{"deploymentMethod"="PowerShell"; "Can Be Deleted"="yes"; "Technology"="AVS"; "Onwer"="flkelly"}

## create a loop to create resource groups
foreach ($resourceGroup in $resourceGroups) {
  ## Create resource group
  $resourceGroupName = $resourceGroup
  $rg = New-AzResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation -Tag $tags
  ## Uncomment line below to add tags
  ## New-AzTag -ResourceId $rg.ResourceId -Tag $tags
  $resourceGropupMessage = "Resource group " + $resourceGroupName + " created successfully"
  Write-Output $resourceGropupMessage
}