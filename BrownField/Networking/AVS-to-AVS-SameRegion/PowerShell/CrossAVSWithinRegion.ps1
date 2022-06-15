$resourceGroup = "ExampleResourceGroup"
$privateCloudLinkName = "ExamplePrivateCloudLink"
$privateCloudName = "ExamplePrivateCloud"
$linkedPrivateCloudId = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/exampleresourcegroup/providers/Microsoft.AVS/privateClouds/private_cloud2/"

New-AzVMwareCloudLink -Name $privateCloudLinkName -PrivateCloudName $privateCloudName -ResourceGroupName $resourceGroup -LinkedCloud $linkedPrivateCloudId
