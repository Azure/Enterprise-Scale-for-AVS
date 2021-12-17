# Parameters for deployment
param(
    [Parameter(Mandatory=$true)]
    [String]
    # The name of your (existing) private cloud
    $privateCloudName,

    [Parameter(Mandatory=$true)]
    [String]
    # The name of your (existing) private cloud's resource group
    $PrivateCloudResourceGroup,
    
    [Parameter(Mandatory=$true)]
    [String]
    # The name of the (existing) ER Gateway
    $GatewayName,
    
    [Parameter(Mandatory=$true)]
    [String]
    # The name of the (existing) ER Gateway's resource group
    $GatewayResourceGroup,
    
    [Parameter(Mandatory=$true)]
    [String]
    # The Azure region for the connection resource
    $location
)

$ConnectionName = "$privateCloudName-ExR-Connection"

# Get Private Cloud and create ExR authorisation key, must be a circuit owner
$privatecloud = Get-AzVMwarePrivateCloud -Name $privateCloudName -ResourceGroupName $PrivateCloudResourceGroup
$peerid = $privatecloud.CircuitExpressRouteId

Write-Host -ForegroundColor Yellow "Generating Authorization Key"
$exrauthkey = New-AzVMwareAuthorization -Name "$privateCloudName-authkey" -PrivateCloudName $privatecloud.name -ResourceGroupName $PrivateCloudResourceGroup 
$exrgwtouse = Get-AzVirtualNetworkGateway -Name $GatewayName -ResourceGroupName $GatewayResourceGroup

# Create AVS Private Cloud connection to ExpressRoute
Write-Host -ForegroundColor Yellow "Connecting AVS Private Cloud $privateCloudName to Azure Virtual Network Gateway "$exrgwtouse.name""
New-AzVirtualNetworkGatewayConnection -Name $ConnectionName -ResourceGroupName $GatewayResourceGroup -Location $location -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key

# Check ExpressRoute connection status
while ($currentprovisioningstate -ne "Succeeded")
{
    $timeStamp = Get-Date -Format "hh:mm"
    "$timestamp - Current Status: $currentprovisioningstate "
    Start-Sleep -Seconds 20
    $provisioningstate = Get-AzVirtualNetworkGatewayConnection -Name $ConnectionName -ResourceGroupName $GatewayResourceGroup
    $currentprovisioningstate = $provisioningstate.ProvisioningState
} 

if ($currentprovisioningstate -eq "Succeeded")
{
    Write-host -ForegroundColor Green "Connection was created successfully"
}
else {
    Write-host -ForegroundColor Red "Connection was not created succesfully"
}
