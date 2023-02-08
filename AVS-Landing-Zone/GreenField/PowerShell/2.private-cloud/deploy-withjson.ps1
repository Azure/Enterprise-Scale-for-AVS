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

## Variables are based upon varibales.json
#$variables = Get-Content .\AVS-Landing-Zone\GreenField\PowerShell\variables\variables.json | ConvertFrom-Json
$variables = Get-Content ..\variables\variables.json | ConvertFrom-Json

## Do yo have AVS Module installed?
if (Get-Module -ListAvailable -Name Az.VMware)
{ write-output "Module exists"
} else {
    write-output "Module does not exist"
    write-output "Installing Module"
    Install-Module -Name Az.VMware
}

## deploying new private cloud

## private cloud variables
$privateCloud = $variables.PrivateCloud
$sku = $privateCloud.sku
$networkBlock = $privateCloud.privatecloudnetworkcidr
$managementClusterSize = $privateCloud.clusternodecount
$cloudName = $privateCloud.privatecloudname
$privateCloudLocation = $privateCloud.location
$privateCloudRgName = $privateCloud.resourcegroupname

$cluster = @{
    Name = $cloudName
    ResourceGroupName = $privateCloudRgName
    NetworkBlock = $networkBlock
    Sku = $sku
    ManagementClusterSize = $managementClusterSize
    Location = $privateCloudLocation
}

## check to see if private cloud exists, if it does - STOP!!!
$check = Get-AzVMwarePrivateCloud -ResourceGroupName $privateCloudRgName -PrivateCloudName $cloudName -errorAction SilentlyContinue

## Azure private Cloud deployment deployment
if ($null -eq $check){
    $cluster = New-AzVMwarePrivateCloud @cluster
}else { 
    $message = "Private Cloud: " + $cloudName + " already exists - exiting to prevent overwriting / damaging existing deployment"
    write-output $message
    break }

$srmSettings = $variables.PrivateCloud.addons.addon | Where-Object {$_.id -eq "SRM"}

$deploySRM = $srmSettings.enable
if ($deploySRM -eq "true") {
    ## update SRM Key
    $srmKey = $srmSettings.key

    ## Checking if key is set
    if ($srmKey -eq "")
    {
        $srmErrorMessage = "SRM key is not set"
        write-output $srmErrorMessage
        break
    } else {
        # Deploy SRM
        $srmProperties = New-AzVMwareAddonSrmPropertiesObject -LicenseKey $srmKey
        New-AzVMwareAddon -PrivateCloudName $cloudName -ResourceGroupName $privateCloudRgName -Property $srmProperties
    }

    $vrInstances = "1"
    # Deploy vSphere Replication
    $vrsProperties = New-AzVMwareAddonVrPropertiesObject -VrsCount $vrInstances
    New-AzVMwareAddon -PrivateCloudName $cloudName -ResourceGroupName $privateCloudRgName -Property $vrsProperties
}

$hcxSettings = $variables.PrivateCloud.addons.addon | Where-Object {$_.id -eq "HCX"}
$deployHCX = $hcxSettings.enable
if ($deployHCX -eq "true") {
    az vmware addon hcx create --resource-group $privateCloudRgName --private-cloud $cloudName --offer "VMware MaaS Cloud Provider"
}