# Use this script when to connect AVS Virtual Network Gateway to ExpressRoute using an existing ExpressRoute Id and Authorization Key

# Parameters for deployment
$GatewayName = "<Name of existing VNet Gateway>"
$GatewayResourceGroup = "<Resource Group name of existing VNet Gateway>"
$location = ""
$ConnectionName = "<Name for the new connection being created>"
$ExpressRouteAuthorizationKey = "<Existing ExpressRoute Authorization Key>"
$ExpressRouteId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/RGName/providers/Microsoft.Network/expressRouteCircuits/ERName/authorizations/ExampleAVSConnection"

# Get existing virtual network gateway
$exrgwtouse = Get-AzVirtualNetworkGateway -Name $GatewayName -ResourceGroupName $GatewayResourceGroup

# Create a new connection for the Express Route details that were provided
Write-Host -ForegroundColor Yellow "Connecting AVS Private Cloud to Azure Virtual Network Gateway "$exrgwtouse.name""
New-AzVirtualNetworkGatewayConnection -Name $ConnectionName -ResourceGroupName $GatewayResourceGroup -Location $location -VirtualNetworkGateway1 $exrgwtouse -PeerId $ExpressRouteId -ConnectionType ExpressRoute -AuthorizationKey $ExpressRouteAuthorizationKey

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
