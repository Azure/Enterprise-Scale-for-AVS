$resourceGroup = "<Resource group name of the private cloud>"
$privateCloudLinkName = "<Name of the Private Cloud Link that will be created>"
$privateCloudName = "<Name of the existing primary private cloud, must exist within this resource group>"
$linkedPrivateCloudId = "<Full resource id of the secondary private cloud, must be in the same region as the primary>"

New-AzVMwareCloudLink -Name $privateCloudLinkName -PrivateCloudName $privateCloudName -ResourceGroupName $resourceGroup -LinkedCloud $linkedPrivateCloudId
