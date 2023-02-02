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

## Variables are based upon varibales.json
#$variables = Get-Content .\AVS-Landing-Zone\GreenField\PowerShell\variables\variables.json | ConvertFrom-Json
$variables = Get-Content ..\variables\variables.json | ConvertFrom-Json

## Define resource groups
$resourceGroups = $variables.ResourceGroups

## Define tags to be used if needed
## tags can be modified to suit your needs, another example below.
$tags = @{"Environment"="Development";"Owner"="Fletcher Kelly";"CanBeDeleted"="True";"DeploymentMethod"="PowerShell"}

## create a loop to create resource groups
foreach ($resourceGroup in $resourceGroups) {
  ## Create resource group
  $resourceGroupName = $resourceGroup.name
  $resourceGroupLocation = $resourceGroup.location
  $rg = New-AzResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation -Tag $tags
  $resourceGropupMessage = "Resource group " + $resourceGroupName + " created successfully"
  Write-Output $resourceGropupMessage
}

## Important link around azure-partner-customer-usage-attribution
## https://docs.microsoft.com/en-gb/azure/marketplace/azure-partner-customer-usage-attribution#notify-your-customers

<# 
Notification for SDK or API deployments
When you deploy <PARTNER> software, Microsoft can identify the installation of <PARTNER> software with the deployed Azure resources. Microsoft can correlate these resources used to support the software. Microsoft collects this information to provide the best experiences with their products and to operate their business. The data is collected and governed by Microsoft's privacy policies, located at https://www.microsoft.com/trustcenter. 
#>

## Telemetry enabled by default, Can be disabled by change the value of the telemetry parameter to false

$telemetry = $true

if ($telemetry) {
  ## https://docs.microsoft.com/en-gb/azure/marketplace/azure-partner-customer-usage-attribution#notify-your-customers
    Write-Output "Telemetry enabled"
    $telemetryId = "pid-4c6f5558-ec2a-449b-9e68-7530d7ee8b1e"
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent($telemetryId)
} else {
    Write-Host "Telemetry disabled"
}