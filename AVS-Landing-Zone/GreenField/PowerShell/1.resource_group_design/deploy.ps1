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
## other examples - to add technology, simply add $owner to the tags
# $tags = @{"deploymentMethod"="PowerShell"; "Technology"="AVS"; "Onwer"="flkelly"}
$tags = @{"deploymentMethod"="PowerShell"; "Technology"="AVS"}

## create a loop to create resource groups
foreach ($resourceGroup in $resourceGroups) {
  ## Create resource group
  $resourceGroupName = $resourceGroup
  New-AzResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation -Tag $tags
  #New-AzTag -ResourceId $rg.ResourceId -Tag $tags
  write-host "Resource group " -NoNewline 
  write-host $resourceGroupName -NoNewline -ForegroundColor Green 
  write-host " created successfully"
}