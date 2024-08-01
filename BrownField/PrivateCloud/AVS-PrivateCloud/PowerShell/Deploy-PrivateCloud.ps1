$resourceGroup = "<Name of the Resource Group>"
$location = ""

$privateCloudName = "<Name of the Private Cloud>"
$addressBlock = "x.y.z.0/22"
$clusterSize = 3
$sku = "AV36P"

New-AzVMwarePrivateCloud -Name $privateCloudName `
                            -ResourceGroupName $resourceGroup `
                            -Location $location `
                            -ManagementClusterSize $clusterSize `
                            -NetworkBlock $addressBlock `
                            -Sku $sku