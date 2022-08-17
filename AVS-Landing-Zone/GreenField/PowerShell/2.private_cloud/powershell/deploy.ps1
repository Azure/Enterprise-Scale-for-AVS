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


## Do yo have AVS Module installed?
if (Get-Module -ListAvailable -Name Az.VMware)
{ write-output "Module exists"
} else {
    write-output "Module does not exist"
    write-output "Installing Module"
    Install-Module -Name Az.VMware
}

## deploying new private cloud

## TODO hard coded variables for now - need to be removed
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

$deploySRM = $true
if ($deploySRM) {
$srmKey = ""
$vrInstances = "1"

#$privateCloud = Get-AzVMwarePrivateCloud -ResourceGroupName $privateCloudRgName -Name $cloudName

# Deploy SRM
$srmProperties = New-AzVMwareAddonSrmPropertiesObject -LicenseKey $srmKey
New-AzVMwareAddon -PrivateCloudName $cloudName -ResourceGroupName $privateCloudRgName -Property $srmProperties

# Deploy vSphere Replication
$vrsProperties = New-AzVMwareAddonVrPropertiesObject -VrsCount $vrInstances
New-AzVMwareAddon -PrivateCloudName $cloudName -ResourceGroupName $privateCloudRgName -Property $vrsProperties
}

$deployHCX = $true
if ($deployHCX) {

    ## TODO - try find equivalent PS code
    az vmware addon hcx create --resource-group $privateCloudRgName --private-cloud $cloudName --offer "VMware MaaS Cloud Provider"
}