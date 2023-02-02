###############################################################
#                                                             #
#  Author : Fletcher Kelly                                    #
#  Github : github.com/fskelly                                #
#  Purpose : AVS - Deploy networking sample - Virtual Wan     #
#  Built : 11-July-2022                                       #
#  Last Tested : 14-November-2022                             #
#  Language : PowerShell                                      #
#                                                             #
###############################################################


#new-azresourcegroup -name avs-northeurope-networking-rg -location northeurope
$variables = Get-Content ..\variables\variables.json | ConvertFrom-Json

$networking = $variables.Networking

$vwanLocaltion = $networking.virtualwan.location
$vwanName = $networking.virtualwan.name
$vwanRgName = $networking.virtualwan.resourcegroupname
$vwanHubName = $networking.virtualwan.hub.name
$hubCidr = $networking.virtualwan.hub.cidr
$vwanExrGatewayName = $networking.virtualwan.hub.exrgateway.name

$virtualWan = New-AzVirtualWan -ResourceGroupName $vwanRgName -Name $vwanName -Location $vwanLocaltion

$virtualHub = New-AzVirtualHub -VirtualWan $virtualWan -ResourceGroupName $vwanRgName -Name $vwanHubName -AddressPrefix $hubCidr -location $vwanLocaltion

$expressroutegatewayinhub = New-AzExpressRouteGateway -ResourceGroupName $vwanRgName -Name $vwanExrGatewayName -VirtualHubId $virtualHub.Id -MinScaleUnits 2

$privateCloud = $variables.PrivateCloud
$cloudName = $privateCloud.privatecloudname
$privateCloudRgName = $privateCloud.resourcegroupname
$authName = $privateCloud.expressrouteauthorization.name
$avsConnectionName = $privateCloud.expressrouteauthorization.name
$avsAuth = New-AzVMwareAuthorization -Name $authName -PrivateCloudName $cloudName -ResourceGroupName $privateCloudRgName

$authKey = $avsAuth.Key
$avsExrCircuitId = (Get-AzVMwarePrivateCloud -Name $cloudName -ResourceGroupName $privateCloudRgName).CircuitExpressRoutePrivatePeeringId

$deployExrAuth = $networking.virtualwan.expressrouteauthorization.deploy
## ExpressRoute connection variables
if ($deployExrAuth -eq "true") {
New-AzExpressRouteConnection -ResourceGroupName $vwanRgName -ExpressRouteGatewayName $vwanExrGatewayName -Name connection-1  -AuthorizationKey $authKey -ExpressRouteCircuitPeeringId $avsExrCircuitId
} else {
    Write-Output "Skipping ExpressRoute connection"
}
