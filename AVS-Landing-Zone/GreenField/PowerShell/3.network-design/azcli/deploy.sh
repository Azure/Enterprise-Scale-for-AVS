##vnet variables
vnetName=vnet1
vnetLocation=germanywestcentral
vnetCidr=10.0.0.0/16

## subnet variables
frontEndName=frontend
frontEndAddressPrefix=10.0.1.0/26
bastionSubnetName=AzureBastionSubnet
bastionSubnetPrefix=10.0.1.64/26
gatewaySubnetName=GatewaySubnet
gatewaySubnetPrefix=10.0.1.128/26

## TODO hard coded variables for now - need to be removed
rgName=networking_rg1

## Deployment
az network vnet create --name $vnetName --resource-group $rgName --location $vnetLocation --address-prefix $vnetCidr 
vnetId=$(az network vnet show --resource-group $rgName --name $vnetName --query id -o tsv) && echo $vnetId

## Create subnets
az network vnet subnet create --resource-group $rgName --vnet-name $vnetName --name $frontEndName --address-prefixes $frontEndAddressPrefix
az network vnet subnet create --resource-group $rgName --vnet-name $vnetName --name $bastionSubnetName --address-prefixes $bastionSubnetPrefix
az network vnet subnet create --resource-group $rgName --vnet-name $vnetName --name $gatewaySubnetName --address-prefixes $gatewaySubnetPrefix

## PIP Variables
pipName=vng-pip1
pipSKU=Standard
pipAllocationMethod=Static
vngName=vng1
zone="1 2 3"

## Deploy PIP
gwPublicIp=$(az network public-ip create --resource-group $rgName --name $pipName --zone $zone --sku $pipSKU --allocation-method $pipAllocationMethod --location $vnetLocation) && echo $gwPublicIp

##Variables needed for ergw
gwPipId=$(az network public-ip show -n $pipName -g $rgName --query id -o tsv) && echo $gwPipId
gatewaySubnetId=$(az network vnet subnet show --resource-group $rgName --vnet-name $vnetName --name $gatewaySubnetName --query id -o tsv) && echo $gatewaySubnetId

## VNG Variables
gatewayIpConfigName=ExRgwNetworkConfig
gatewaySKU=ErGw1AZ
gatewayType=ExpressRoute
vpnType=RouteBased

# Create ER Gateway and connect it to circuit
echo "Creating ER Gateway..."
#az network vnet subnet create -g $rgName --vnet-name $vnetName -n GatewaySubnet --address-prefix $gatewaySubnetPrefix -o none
#az network public-ip create -g $rgName -n $pipName --allocation-method Dynamic --sku $gatewaySKU -l $vnetLocation -o none
az network vnet-gateway create --resource-group $rgName --name $vngName --gateway-type $gatewayType --sku $gatewaySKU --location $vnetLocation --vnet $vnetName --public-ip-addresses $pipName --output none

##Circuit variables
erProvider=Megaport
erPop=Paris
erCircuitName="er-$erPop"
erCircuitSku=Standard

# Create ER circuit
az network express-route create --name $erCircuitName --peering-location $erPop --resource-group $rgName --output none --bandwidth 50 Mbps --provider $erProvider -l $vnetLocation --sku-family MeteredData --sku-tier $erCircuitSku
circuitId=$(az network express-route show -n $erCircuitName -g $rgName -o tsv --query id) && echo $circuitId

service_key=$(az network express-route show -n $erCircuitName -g $rgName --query serviceKey -o tsv)

#not working
az network vpn-connection create --name "${vngName}-${erPop}" --resource-group $rgName --location $vnetLocation --vnet-gateway1 $vngName --express-route-circuit2 $circuitId -o none