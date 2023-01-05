###############################################
#                                             #
#  Author : Fletcher Kelly                    #
#  Github : github.com/fskelly                #
#  Purpose : AVS - Deploy private cloud       #
#  Built : 11-July-2022                       #
#  Last Tested : 25-July-2022                 #
#  Language : PowerShell                      #
#                                             #
###############################################


## Do you have AVS Module installed?
if (Get-Module -ListAvailable -Name Az.VMware)
{ write-output "Module exists"
} else {
    write-output "Module does not exist"
    write-output "Installing Module"
    Install-Module -Name Az.VMware
}

## deploying new private cloud
$technology = "avs"
$resourceGroupLocation = "germanywestcentral"
$privateCloudRgName = "$technology-$resourceGroupLocation-private_cloud_rg"

## private cloud variables
$sku = "av36"
$networkBlock = "192.168.48.0/22"
$managementClusterSize = "3"
$cloudName = "azps_test_cloud"
$privateCloudLocation = "germanywestcentral"

$cluster = @{
    Name = $cloudName
    ResourceGroupName = $privateCloudRgName
    NetworkBlock = $networkBlock
    Sku = $sku
    ManagementClusterSize = $managementClusterSize
    Location = $privateCloudLocation
}

## Azure private Cloud deployment deployment
$cluster = New-AzVMwarePrivateCloud @cluster

## false is the default, change to $true to deploy SRM
$deploySRM = $false
if ($deploySRM) {
    $srmKey = ""
    if ($srmKey -eq "")
    {
        $srmErrorMessage = "SRM key is not set"
        Write-Output $srmErrorMessage
    }
    else {
        # Deploy SRM
        $srmProperties = New-AzVMwareAddonSrmPropertiesObject -LicenseKey $srmKey
        New-AzVMwareAddon -PrivateCloudName $cloudName -ResourceGroupName $privateCloudRgName -Property $srmProperties
    }
}

$deployVRS = $false
# Deploy vSphere Replication

## false is the default, change to $true to deploy VRS
if ($deployVRS) {
    $vrInstances = "1"
    $vrsProperties = New-AzVMwareAddonVrPropertiesObject -VrsCount $vrInstances
    New-AzVMwareAddon -PrivateCloudName $cloudName -ResourceGroupName $privateCloudRgName -Property $vrsProperties
}

## false is the default, change to $true to deploy HCX
$deployHCX = $false
if ($deployHCX) {
    ## TODO - try find equivalent PS code
    az vmware addon hcx create --resource-group $privateCloudRgName --private-cloud $cloudName --offer "VMware MaaS Cloud Provider"
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
    $telemetryId = "pid-9e4a4112-75bc-47ed-afb6-960ab433dcea"
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent($telemetryId)
} else {
    Write-Host "Telemetry disabled"
}