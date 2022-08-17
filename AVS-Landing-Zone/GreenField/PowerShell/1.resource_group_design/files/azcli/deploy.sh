## define resource groups to be created
resourceGroups=(private_cloud_rg1 networking_rg1 operations_rg1 jumpbox_rg1)

## Define location for resource groups
resourceGroupLocation=germanywestcentral

for resourceGroup in "${resourceGroups[@]}"; 
    do echo "$resourceGroup"; 
    az group create --name $resourceGroup --location $resourceGroupLocation;
    az group update --name $resourceGroup --set tags.deploymentMethod=azcli tags."Can Be Deleted"=yes tags.Technology=AVS;
    echo "Resource group $resourceGroup created successfully";
    done