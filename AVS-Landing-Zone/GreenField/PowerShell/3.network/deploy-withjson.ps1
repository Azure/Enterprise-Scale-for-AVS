###############################################
#                                             #
#  Author : Fletcher Kelly                    #
#  Github : github.com/fskelly                #
#  Purpose : AVS - Deploy networking sample   #
#  Built : 11-July-2022                       #
#  Last Tested : 02-August-2022               #
#  Language : PowerShell                      #
#                                             #
###############################################

$variables = Get-Content ..\variables\variables.json | ConvertFrom-Json
$networking = $variables.Networking

## hub and spoke
$deployHuabAndSpoke = $networking.hubAndSpoke.deploy
if ($deployHuabAndSpoke -eq "true") {
    Write-Output "Deploying Hub and Spoke"
    . .\3.network\hub-and-spoke\deploy-withjson.ps1
} else {
    write-Output "Skipping Hub and Spoke"
}

## virtual wan
$deployVirtualWan = $networking.virtualWan.deploy
if ($deployVirtualWan -eq "true") {
    Write-Output "Deploying Virtual Wan"
    . .\3.network\virtual-wan\deploy-withjson.ps1
} else {
    write-Output "Skipping Virtual Wan"
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
    $telemetryId = "pid-b3e5a0bb-b96b-4250-84a1-39eca087d10f"
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent($telemetryId)
} else {
    Write-Host "Telemetry disabled"
}

