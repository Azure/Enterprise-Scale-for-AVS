$resourceGroup = ""
$privateCloudName = ""

$srmKey = ""
$vrInstances = "1"

# Deploy SRM
$srmProperties = New-AzVMwareAddonSrmPropertiesObject -LicenseKey $srmKey
New-AzVMwareAddon -PrivateCloudName $privateCloudName -ResourceGroupName $resourceGroup -Property $srmProperties

# Deploy vSphere Replication
$vrsProperties = New-AzVMwareAddonVrPropertiesObject -VrsCount $vrInstances
New-AzVMwareAddon -PrivateCloudName $privateCloudName -ResourceGroupName $resourceGroup -Property $vrsProperties