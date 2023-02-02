###############################################################
#                                                             #
#  Author : Fletcher Kelly                                    #
#  Github : github.com/fskelly                                #
#  Purpose : AVS - Deploy networking sample - Hub and Spoke   #
#  Built : 11-July-2022                                       #
#  Last Tested : 14-November-2022                             #
#  Language : PowerShell                                      #
#                                                             #
###############################################################

## variables (from variables.json)
$variables = Get-Content ..\variables\variables.json | ConvertFrom-Json
$networking = $variables.Networking
$vnetName = $networking.hubAndSpoke.hubvnetname
$vnetLocation = $networking.hubAndSpoke.location
$vnetCidr = $networking.hubAndSpoke.hubvnetcidr
$frontEndName = $networking.hubAndSpoke.subnets.frontend.name
$networkingRgName = $networking.hubAndSpoke.resourcegroupname
$frontEndSubnetCidr = $networking.hubAndSpoke.subnets.frontend.cidr
$AzureBastionSubnetCidr = $networking.hubAndSpoke.subnets.azurebastion.cidr
$GatewaySubnetCidr = $networking.hubAndSpoke.subnets.gateway.cidr

## Virtual Network Deployment
$frontendSubnet = New-AzVirtualNetworkSubnetConfig -Name $frontEndName -AddressPrefix $frontEndSubnetCidr
$bastionSubnet = New-AzVirtualNetworkSubnetConfig -Name AzureBastionSubnet -AddressPrefix $AzureBastionSubnetCidr
$gatewaySubnet = New-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -AddressPrefix $GatewaySubnetCidr
$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $networkingRgName -Location $vnetLocation -AddressPrefix $vnetCidr -Subnet $frontendSubnet,$bastionSubnet,$gatewaySubnet

## virtual network gateway variables
$pipName = $variables.Networking.hubAndSpoke.virtualnetworkgateway.pip.name
$pipSKU = $variables.Networking.hubAndSpoke.virtualnetworkgateway.pip.sku
$pipAllocationMethod = $variables.Networking.hubAndSpoke.virtualnetworkgateway.pip.pipallocationmethod
$vngName = $variables.Networking.hubAndSpoke.virtualnetworkgateway.name
$pipIpAddressVersion = $variables.Networking.hubAndSpoke.virtualnetworkgateway.pip.ipaddressversion
$ip = @{
    Name = $pipName
    ResourceGroupName = $networkingRgName
    Location = $vnetLocation
    Sku = $pipSKU 
    AllocationMethod = $pipAllocationMethod
    IpAddressVersion = 'IPv4'
    Zone = 1,2,3
}

## Azure VNG deployment
$gwPublicIp = New-AzPublicIpAddress @ip
$gatewaySubnetConfig = Get-AzVirtualNetworkSubnetConfig -name 'gatewaysubnet' -VirtualNetwork $vnet
$gatewayIpConfigName = $networking.hubAndSpoke.virtualnetworkgateway.configname

$config = @{
    Name = $gatewayIpConfigName
    SubnetId = $gatewaySubnetConfig.Id
    PublicIpAddressId = $gwPublicIp.Id
}
$ngwipconfig = New-AzVirtualNetworkGatewayIpConfig @config

$gatewaySKU = $networking.hubAndSpoke.virtualnetworkgateway.sku
$vpnType = $networking.hubAndSpoke.virtualnetworkgateway.vpnType
$gatewayType = $networking.hubAndSpoke.virtualnetworkgateway.gatewaytype

$gwConfig = @{
    Name = $vngName
    ResourceGroupName = $networkingRgName
    Location = $vnetLocation
    IpConfigurations = $ngwipconfig
    GatewayType = $gatewayType
    VpnType = $vpnType
    GatewaySku = $gatewaySKU
}
$exrVirtualNetworkGateway = New-AzVirtualNetworkGateway @gwConfig



$deployExrAuth = $networking.hubAndSpoke.expressrouteauthorization.deploy
## ExpressRoute connection variables
if ($deployExrAuth -eq "true") {
    ## Authourization variables
    $cloudName = $privateCloud.privatecloudname
    $authName = $privateCloud.location + "-" + $cloudName + "-authorization"
    $privateCloudRgName = $privateCloud.resourcegroupname
    $avsAuth = New-AzVMwareAuthorization -Name $authName -PrivateCloudName $cloudName -ResourceGroupName $privateCloudRgName
    write-Output "Deploying ExpressRoute Authorization"
    $authKey = $avsAuth.Key
    $avsPeerCircuitURI = $avsAuth.ExpressRouteId
    New-AzVirtualNetworkGatewayConnection -ResourceGroupName $networkingRgName -VirtualNetworkGateway1 $exrVirtualNetworkGateway -Name avs-er-connection -AuthorizationKey $authKey -PeerId $avsPeerCircuitURI -ConnectionType ExpressRoute -Location $vnetLocation
} else {
    write-Output "Skipping ExpressRoute Authorization"
}

## Advanced option
## false is the default, change to $true to deploy VPN
$deployVpn = $variables.Networking.hubAndSpoke.vpndeploy.deploy
if ($deployVpn -eq "true") {

    ## VPN gateway variables
    $vpn = $variables.Networking.hubAndSpoke.vpndeploy
    $vngName = $vpn.vpngateway.name
    $pip1Name = $vpn.vpngateway.publicips.pip1.name
    $pip2Name = $vpn.vpngateway.publicips.pip2.name
    $gatewayType = $vpn.vpngateway.gatewaytype
    $enableBGP = $true
    $vpnType = $vpn.vpngateway.vpnType
    $vngSKU = $vpn.vpngateway.sku
    $vngASN = $vpn.vpngateway.asn

    $vnet = Get-AzVirtualNetwork -ResourceGroupName $networkingRgName -Name $vnetName
    $subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name 'GatewaySubnet' 

    ##need 2 PIPs for the gateway
    $vngPip1 = New-AzPublicIpAddress -Name $pip1Name -ResourceGroupName $networkingRgName -Location $vnetLocation -AllocationMethod Static -Zone 1,2,3 -IpAddressVersion IPv4 -Sku Standard
    $vngPip2 = New-AzPublicIpAddress -Name $pip2Name -ResourceGroupName $networkingRgName -Location $vnetLocation -AllocationMethod Static -Zone 1,2,3 -IpAddressVersion IPv4 -sku Standard
    $gwIpconfig1 = New-AzVirtualNetworkGatewayIpConfig -SubnetId $subnet.Id -PublicIpAddressId $vngPip1.Id -Name $vpn.vpngateway.publicips.pip1.configname
    $gwIpconfig2 = New-AzVirtualNetworkGatewayIpConfig -SubnetId $subnet.Id -PublicIpAddressId $vngPip2.Id -Name $vpn.vpngateway.publicips.pip2.configname

    $newgw = New-AzVirtualNetworkGateway -Name $vngName -ResourceGroupName $networkingRgName -IpConfigurations $gwIpconfig1, $gwIpconfig2 -GatewayType $gatewayType -EnableBgp $enableBGP -VpnType $vpnType -GatewaySku $vngSKU -Asn $vngASN -EnableActiveActiveFeature -Location $resourceGroupLocation
    
    $vnet = get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $networkingRgName

    ## Azure Route Server variables
    $arsPrefix = $vpn.vpngateway.subnets.RouteServerSubnet.cidr
    $arsSubnet = @{
        Name = $vpn.vpngateway.subnets.RouteServerSubnet.name
        VirtualNetwork = $vnet
        AddressPrefix = $arsPrefix
    }
    $arsSubnetConfig = Add-AzVirtualNetworkSubnetConfig @arsSubnet
    $vnet | Set-AzVirtualNetwork
    $vnetInfo = get-azvirtualnetwork -ResourceGroupName $networkingRgName -name $vnetName
    $arsSubnetId = (Get-AzVirtualNetworkSubnetConfig -Name RouteServerSubnet -VirtualNetwork $vnetInfo).Id

    $arsPipName = $vpn.vpngateway.azurerouteserver.pip.name
    $arspipSKU = $vpn.vpngateway.azurerouteserver.pip.sku
    $arsPipAllocationMethod = $vpn.vpngateway.azurerouteserver.pip.pipallocationmethod
    $arsPipipAddressVersion = $vpn.vpngateway.azurerouteserver.pip.ipaddressversion
    $arsip = @{
        Name = $arsPipName
        ResourceGroupName = $networkingRgName
        Location = $vnetLocation
        Sku = $arspipSKU 
        AllocationMethod = $arsPipAllocationMethod
        IpAddressVersion = $arsPipipAddressVersion
        Zone = 1,2,3
    }

    $arsPublicIp = New-AzPublicIpAddress @arsip
    $arsName = $vpn.vpngateway.azurerouteserver.name
    New-AzRouteServer -ResourceGroupName $networkingRgName -RouteServerName $arsName -PublicIpAddress $arsPublicIp -HostedSubnet $arsSubnetId -Location $vnetLocation

    $arsBranchtoBranchEnable = @{
        RouteServerName = $arsName
        ResourceGroupName = $networkingRgName
        AllowBranchToBranchTraffic = $true
    }  
    Update-AzRouteServer @arsBranchtoBranchEnable

 }

 ## Important link around azure-partner-customer-usage-attribution
## https://docs.microsoft.com/en-gb/azure/marketplace/azure-partner-customer-usage-attribution#notify-your-customers

<# 
Notification for SDK or API deployments
When you deploy <PARTNER> software, Microsoft can identify the installation of <PARTNER> software with the deployed Azure resources. Microsoft can correlate these resources used to support the software. Microsoft collects this information to provide the best experiences with their products and to operate their business. The data is collected and governed by Microsoft's privacy policies, located at https://www.microsoft.com/trustcenter. 
#>

## Telemetry enabled by default, Can be disabled by change the value of the telemetry parameter to false
$telemetry = $true

if ($telemetry) {
  ## https://docs.microsoft.com/en-gb/azure/marketplace/azure-partner-customer-usage-attribution#notify-your-customers
    Write-Output "Telemetry enabled"
    $telemetryId = "pid-b3e5a0bb-b96b-4250-84a1-39eca087d10f"
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent($telemetryId)
} else {
    Write-Host "Telemetry disabled"
}