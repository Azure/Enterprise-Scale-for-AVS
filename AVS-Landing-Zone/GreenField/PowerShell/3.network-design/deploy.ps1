###############################################
#                                             #
#  Author : Fletcher Kelly                    #
#  Github : github.com/fskelly                #
#  Purpose : AVS - Deploy networking sample   #
#  Built : 11-July-2022                       #
#  Last Tested : 02-August-2022               #
#  Language : PowerShell                      #
#                                             #
###############################################

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

##Global variables
$technology = "avs"
$resourceGroupLocation = "germanywestcentral"

## variables
$vnetName = "$technology-$resourceGroupLocation-vnet1"
$vnetLocation = "germanywestcentral"
$vnetCidr = "10.0.0.0/16"
$frontEndName = "frontend"

## resource group variables
## Define location for resource groups
$networkingRgName = "$technology-$resourceGroupLocation-networking_rg"

## Virtual Network Variables
$frontEndSubnetCidr = "10.0.1.0/26"
$AzureBastionSubnetCidr = "10.0.1.64/26"
$GatewaySubnetCidr = "10.0.1.128/26"

## Virtual Network Deployment
$frontendSubnet = New-AzVirtualNetworkSubnetConfig -Name $frontEndName -AddressPrefix $frontEndSubnetCidr
$bastionSubnet = New-AzVirtualNetworkSubnetConfig -Name AzureBastionSubnet -AddressPrefix $AzureBastionSubnetCidr
$gatewaySubnet = New-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -AddressPrefix $GatewaySubnetCidr
$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $networkingRgName -Location $vnetLocation -AddressPrefix $vnetCidr -Subnet $frontendSubnet,$bastionSubnet,$gatewaySubnet

## virtual network gateway variables
$pipName = "$technology-$resourceGroupLocation-vng-pip1"
$pipSKU = "Standard"
$pipAllocationMethod = "Static"
$vngName = "$technology-$resourceGroupLocation-exr-gateway"

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
$gatewayIpConfigName = "$technology-$resourceGroupLocation-ExRgwNetworkConfig"

$config = @{
    Name = $gatewayIpConfigName
    SubnetId = $gatewaySubnetConfig.Id
    PublicIpAddressId = $gwPublicIp.Id
}
$ngwipconfig = New-AzVirtualNetworkGatewayIpConfig @config

$gatewaySKU = "ErGw1AZ"
$vpnType = "PolicyBased"
$gatewayType = "ExpressRoute"

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

## Authourization variables
$cloudName = "azps_test_cloud"
$authName = "$technology-$resourceGroupLocation-$cloudName-authorization"
$privateCloudRgName = "$technology-$resourceGroupLocation-private_cloud_rg"
$avsAuth = New-AzVMwareAuthorization -Name $authName -PrivateCloudName $cloudName -ResourceGroupName $privateCloudRgName

## ExpressRoute connection variables
$authKey = $avsAuth.Key
$avsPeerCircuitURI = $avsAuth.ExpressRouteId
New-AzVirtualNetworkGatewayConnection -ResourceGroupName $networkingRgName -VirtualNetworkGateway1 $exrVirtualNetworkGateway -Name avs-er-connection -AuthorizationKey $authKey -PeerId $avsPeerCircuitURI -ConnectionType ExpressRoute -Location $vnetLocation

## Advanced option
## false is the default, change to $true to deploy VPN
$deployVpn = $false
if ($deployVpn) {

    ## VPN gateway variables
    $vngName = "$technology-$resourceGroupLocation-vpn-gateway"
    $pip1Name = "$technology-$resourceGroupLocation-vpn-pip1"
    $pip2Name = "$technology-$resourceGroupLocation-vpn-pip2"
    $gatewayType = "Vpn"
    $enableBGP = $true
    $vpnType = "RouteBased"
    $vngSKU = "VpnGw1Az"
    $vngASN = "65515"

    $vnet = Get-AzVirtualNetwork -ResourceGroupName $networkingRgName -Name $vnetName
    $subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name 'GatewaySubnet' 

    ##need 2 PIPs for the gateway
    $vngPip1 = New-AzPublicIpAddress -Name $pip1Name -ResourceGroupName $networkingRgName -Location $vnetLocation -AllocationMethod Static -Zone 1,2,3 -IpAddressVersion IPv4 -Sku Standard
    $vngPip2 = New-AzPublicIpAddress -Name $pip2Name -ResourceGroupName $networkingRgName -Location $vnetLocation -AllocationMethod Static -Zone 1,2,3 -IpAddressVersion IPv4 -sku Standard
    $gwIpconfig1 = New-AzVirtualNetworkGatewayIpConfig -SubnetId $subnet.Id -PublicIpAddressId $vngPip1.Id -Name "$technology-$resourceGroupLocation-ipconfig1"
    $gwIpconfig2 = New-AzVirtualNetworkGatewayIpConfig -SubnetId $subnet.Id -PublicIpAddressId $vngPip2.Id -Name "$technology-$resourceGroupLocation-ipconfig2"

    $newgw = New-AzVirtualNetworkGateway -Name $vngName -ResourceGroupName $networkingRgName -IpConfigurations $gwIpconfig1, $gwIpconfig2 -GatewayType $gatewayType -EnableBgp $enableBGP -VpnType $vpnType -GatewaySku $vngSKU -Asn $vngASN -EnableActiveActiveFeature -Location $resourceGroupLocation
    
    $vnet = get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $networkingRgName

    ## Azure Route Server variables
    $arsPrefix = "10.0.2.0/26"
    $arsSubnet = @{
        Name = 'RouteServerSubnet'
        VirtualNetwork = $vnet
        AddressPrefix = $arsPrefix
    }
    $arsSubnetConfig = Add-AzVirtualNetworkSubnetConfig @arsSubnet
    $vnet | Set-AzVirtualNetwork
    $vnetInfo = get-azvirtualnetwork -ResourceGroupName $networkingRgName -name $vnetName
    $arsSubnetId = (Get-AzVirtualNetworkSubnetConfig -Name RouteServerSubnet -VirtualNetwork $vnetInfo).Id

    $arsPipName = "$technology-$resourceGroupLocation-ars-pip1"
    $arspipSKU = "Standard"
    $arsPipAllocationMethod = "Static"
    $arsip = @{
        Name = $arsPipName
        ResourceGroupName = $networkingRgName
        Location = $vnetLocation
        Sku = $arspipSKU 
        AllocationMethod = $arsPipAllocationMethod
        IpAddressVersion = 'IPv4'
        Zone = 1,2,3
    }

    $arsPublicIp = New-AzPublicIpAddress @arsip
    $arsName = "$technology-$resourceGroupLocation-azure-route-server"
    New-AzRouteServer -ResourceGroupName $networkingRgName -RouteServerName $arsName -PublicIpAddress $arsPublicIp -HostedSubnet $arsSubnetId -Location $vnetLocation

    $arsBranchtoBranchEnable = @{
        RouteServerName = $arsName
        ResourceGroupName = $networkingRgName
        AllowBranchToBranchTraffic = $true
    }  
    Update-AzRouteServer @arsBranchtoBranchEnable

 }
