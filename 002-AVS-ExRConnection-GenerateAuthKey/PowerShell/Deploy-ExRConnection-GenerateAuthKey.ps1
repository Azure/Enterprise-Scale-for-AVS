# Parameters for deployment
$privateCloudName = "ExamplePrivateCloud"
$PrivateCloudResourceGroup = "ExampleResourceGroup"
$GatewayName = "ExampleGatewayName"
$GatewayResourceGroup = "ExampleGatewayResourceGroup"
$location = "ExampleLocation"
$ConnectionName = "$privateCloudNameer-ExR-Connection"

# Get Private Cloud and create ExR authorisation key, must be a circuit owner
$privatecloud = Get-AzVMWarePrivateCloud -Name $privateCloudName -ResourceGroupName $PrivateCloudResourceGroup
$peerid = $privatecloud.CircuitExpressRouteId

Write-Host -ForegroundColor Yellow "Generating Authorization Key"
$exrauthkey = New-AzVMWareAuthorization -Name "$privateCloudName-authkey" -PrivateCloudName $privatecloud.name -ResourceGroupName $PrivateCloudResourceGroup 
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
