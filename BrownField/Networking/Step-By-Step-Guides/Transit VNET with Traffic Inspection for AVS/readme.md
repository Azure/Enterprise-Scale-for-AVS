---
title: Enterprise-scale network topology and connectivity for Azure VMware Solution
description: 
author: sblair, fguerri
ms.author: 
ms.date: 
ms.topic: 
ms.service: cloud-adoption-framework
ms.subservice: scenario
ms.custom: 
---

#Use a Third-party NVA in a Hub VNet for inspecting traffic between AVS, Azure VNets, and the Internet

This article is a step-by-step guide for using a third-party NVA in a Hub Virtual Network to inspect traffic between AVS and Azure VNets. The NVA will also inspect traffic between AVS and the internet. 



The architecture will have an on-premises data center and an AVS SDDC each connected to Azure Expressroute circuit.  

Note: Your 0.0.0.0/0 route by default will be advertised on-prem from AVS via Global Reach between the two peer circuits. In order to inspect traffic and the default route flow through a third-party network virtual appliance, you will need to apply route filtering on-prem to deny the default route. 

Since the default route can still flow through on-prem, you can add a route filter on-prem to make sure you're only receiving traffic inspected through the NVA appliances. 

Prerequisites:
- SDDC with ER Circuit
- On-Premise environment to test route filter blocking  (optional)

 
It is not required for the resources listed above to be in the same Azure subscription, nor in subscriptions associated with the same AAD tenant. This guide will deploy the following:
-	An Azure Virtual Network, referred to as the “Hub Virtual Network”
-	An Azure Virtual Network, referred to as the “Spoke Virtual Network” peered to the Hub VNet
-	An Expressroute Gateway that terminates in the Hub VNet
-	A connection between the Expressroute gateway in the Hub VNet and the AVS-provided circuit
-	Two Palo Alto BGPv4-capable NVA’s with 3 NIC's each: trusted, untrusted and management 
-	An Azure Route Server hosted in the Hub VNet

At the end of this step-by-step, your environment will mirror the diagram below:


<<<<<<< HEAD
![nva.png](/.attachments/nva-199add93-9f05-444c-a56b-014a0c3ee079.png)
=======
![nva.png](https://raw.githubusercontent.com/Azure/Enterprise-Scale-for-AVS/main/BrownField/Networking/Step-By-Step-Guides/Transit%20VNET%20with%20Traffic%20Inspection%20for%20AVS/media/nva.png)
>>>>>>> 8e2b30dd8fbba57756406fbc4525a5cb4448eb1b



 

The connectivity occurs through the express route circuits and peering of hub and spoke vnets. The resources below do not have to be in the same subscription or regions**. The expressroute gateway SKU should be premium to maximize the AVS circuit and leverage FastPath for high-throughput scenarios but can be standard for testing. 

The following address prefixes must be allocated within the Hub Virtual Network:
-	/27 or larger for both gateway and route server subnets 
-	/28 prefix for the trust, untrust, and magement firewall subnets 

**IMPORTANT** All the prefixes listed in the table must not overlap with any other prefixes used in the AVS private cloud, the connected spokes, or in any remote site(s) connected over Expressroute.

##Step #0 - Define variables


```
hubRgName="hubrg"
hubVnetName="hub-vnet"
spokeVnetName="spoke-vnet"
hubLocation="southeastasia"
hubVnetPrefixes="10.10.10.0/24"
spokeVnetPrefixes="10.11.10.0/24"
spokeSubnetPrefix="10.11.10.0/27"
hubGwSubnetPrefix="10.10.10.0/27"
hubArsSubnetPrefix="10.10.10.32/27"
hubFwTrustSubnetPrefix="10.10.10.64/28"
hubFwUntrustSubnetPrefix="10.10.10.80/28"
hubFwManagementSubnetPrefix="10.10.10.96/28"
fw0TrustIp="10.10.10.68"
fw1TrustIp="10.10.10.69"
fw0UntrustIp="10.10.10.84"
fw1UntrustIp="10.10.10.85"
fw0MgmtIp="10.10.10.100"
fw1MgmtIp="10.10.10.101"
spokeIp="10.11.10.30"
nvaAsn="65111"
```


##Step #1 – Provision the Hub Vnet and required subnets

```
az group create --name $hubRgName --location $hubLocation



az network vnet create \
        --name $hubVnetName \
        --address-prefixes $hubVnetPrefixes \
        --resource-group $hubRgName \
        --location $hubLocation

 

az network vnet subnet create \
        --name hubFwTrustSubnet  \
        --address-prefixes $hubFwTrustSubnetPrefix \
        --resource-group $hubRgName \
        --vnet-name $hubVnetName

az network vnet subnet create \
        --name hubFwUntrustSubnet  \
        --address-prefixes $hubFwUntrustSubnetPrefix  \
        --resource-group $hubRgName \
        --vnet-name $hubVnetName

az network vnet subnet create \
        --name hubFwManagementSubnet  \
        --address-prefixes $hubFwManagementSubnetPrefix \
        --resource-group $hubRgName \
        --vnet-name $hubVnetName




```

##Create Network Security Groups
```
az network nsg create --resource-group $hubRgName--location $hubLocation--name fwmgmtnsg
```
// Add steps to use bastion for inbound management access. 
// Add steps to allow IP's from outside and resources from the inside


##Step 1 - Provision the BGP-capable NVAs

For this step, you will create a BGP capable NVA. It is recommended to deploy a highly available NVA pair. The approach presented in this article is horizontally-scalable up to the maximum number of BGP peers supported by Azure Route Server. Each NVA must have a NIC to retrieve traffic from AVS and push back out to the gateway. Additional interfaces can be configured as needed (e.g for management purposes). IP forwarding is turned on for the nic ip so that traffic is sent from the source ip address to the destination ip address. 


### Deploy NICs


```
az network nic create --name fw0-trust-nic \
        --resource-group $hubRgName \
        --location $hubLocation \
        --vnet $hubVnetName \
        --subnet hubFwTrustSubnet \
        --ip-forwarding true \
        --private-ip-address $fw0TrustIp

az network nic create --name fw0-untrust-nic \
        --resource-group $hubRgName \
        --location $hubLocation \
        --vnet $hubVnetName \
        --subnet hubFwUntrustSubnet \
        --ip-forwarding true \
        --private-ip-address $fw0UntrustIp

az network nic create --name fw0-mgmt-nic \
        --resource-group $hubRgName \
        --location $hubLocation \
        --vnet $hubVnetName \
        --subnet hubFwManagementSubnet \
        --ip-forwarding true \
        --private-ip-address $fw0MgmtIp

az network nic create --name fw1-trust-nic \
        --resource-group $hubRgName \
        --location $hubLocation \
        --vnet $hubVnetName \
        --subnet hubFwTrustSubnet \
        --ip-forwarding true \
        --private-ip-address $fw1TrustIp

az network nic create --name fw1-untrust-nic \
        --resource-group $hubRgName \
        --location $hubLocation \
        --vnet $hubVnetName \
        --subnet hubFwUntrustSubnet \
        --ip-forwarding true \
        --private-ip-address $fw1UntrustIp

az network nic create --name fw0-mgmt-nic \
        --resource-group $hubRgName \
        --location $hubLocation \
        --vnet $hubVnetName \
        --subnet hubFwManagementSubnet \
        --ip-forwarding true \
        --private-ip-address $fw1MgmtIp

```
### Deploy NVAs in an availability set

```
az vm availability-set create --name hub-fw-set --resource-group $hubRgName --location $hubLocation
az network public-ip create \
        --name mgmt-pip1 \
        --resource-group $hubRgName \
        --dns-name fw1mgmtdns \
        --sku Standard \
        --version IPv4 \
        --zone 1 2 3 \
        --location $hubLocation

az network public-ip create \
        --name mgmt-pip2 \
        --resource-group $hubRgName \
        --dns-name fw2mgmtdns \
        --sku Standard \
        --version IPv4 \
        --zone 1 2 3 \
        --location $hubLocation
```
```
az network nic update -g $hubRgName -n fw0-mgmt-nic --network-security-group fwmgmtnsg
az network nic update -g $hubRgName -n fw1-mgmt-nic --network-security-group fwmgmtnsg
 
```
```
### Define username and password for the NVAs
nvaUser="bgpadmin"
````


### Define VM size for the NVAs

```
nvaSize="Standard_D3_V2"
nvaImage="UbuntuLTS"
```
```
az vm create --name bgpnvavm01 \
        --resource-group $hubRgName \
        --image $nvaImage \
        --size $nvaSize \
        --availability-set hub-fw-set \
        --admin-username $nvaUser \
        --ssh-key-value ~/.ssh/id_rsa.pub \ 
        --storage-sku Standard_LRS \
        --nics fw0-trust-nic fw0-untrust-nic fw0-mgmt-nic

az vm create --name bgpnvavm02 \
        --resource-group $hubRgName \
        --image $nvaImage \
        --size $nvaSize \
        --availability-set hub-fw-set \
        --admin-username $nvaUser \
        --ssh-key-value ~/.ssh/id_rsa.pub \  
        --storage-sku Standard_LRS \
        --nics fw1-trust-nic fw1-untrust-nic fw1-mgmt-nic
```

 

Now that the hub and spoke vnets are fully provisioned, peer them. 
```
vNet1Id=$(az network vnet show --resource-group $hubRgName --name $hubVnetName --query id --out tsv)

vNet2Id=$(az network vnet show --resource-group $hubRgName --name $spokeVnetPrefixes --query id --out tsv)
```
```
az network vnet peering create \
        --name hubtospoke \
        --resource-group $hubRgName \
        --vnet-name $hubVnetName \
        --remote-vnet $vNet2Id \
        --allow-vnet-access

az network vnet peering create \
        --name spoketohub \
        --resource-group $hubRgName \
        --vnet-name $spokeVnetName \
        --remote-vnet $vNet1Id \
        --allow-vnet-access
```


## Step #2 - Provision the Expressroute Gateway in the Hub VNet
In this step you are going to create the Expressroute gateway. This is where your AVS managed circuit will establish a connection to have traffic access the Hub Virtual network. This will require granting permission to this gateway via the circuit’s authorization key. Follow the instructions below to locate the circuits identifier and create the authorization key: https://docs.microsoft.com/en-us/azure/azure-vmware/tutorial-configure-networking#connect-expressroute-to-the-virtual-network-gateway

Note: Gateway creation can take up to 40mins


```
ergwSku="Choose the appropriate SKU, e.g. HighPerformance"
avsManagedErCircuitId="AVS managed Expressroute circuit ID"
avsManagederCircuitAuthKey="AVS managed Expressroute authorization key"
```



### Deploy Expressroute Gateway

```
az network public-ip create \
        --name hub-ergw-pip \
        --resource-group $hubRgName \
        --sku Standard \
        --version IPv4 \
        --zone 1 2 3 \
        --location $hubLocation
```



```
az network vnet-gateway create \
        --name hub-ergw \
        --vnet $hubVnetName \
        --resource-group $hubRgName \
        --gateway-type Expressroute \
        --sku $ergwSku \
        --public-ip-addresses hub-ergw-pip
```


### Connect Expressroute Gateway to AVS managed Expressroute circuit

```
hubErgwId=$(az network vnet-gateway show --name hub-ergw --resource-group $hubRgName --query id --output tsv)
az network vpn-connection create \
        --name hub-to-avs \
        --resource-group $hubRgName \
        --vnet-gateway1 $hubErgwId \
        --express-route-circuit2 $avsManagedErCircuitId \
        --authorization-key $avsManagederCircuitAuthKey
```



##Step 3 - Provision the BGP-capable NVAs

For this step, you will create a BGP capable NVA. It is recommended to deploy a highly available NVA pair. The approach presented in this article is horizontally-scalable up to the maximum number of BGP peers supported by Azure Route Server. Each NVA must have a NIC to retrieve traffic from AVS and push back out to the gateway. Additional interfaces can be configured as needed (e.g for management purposes). IP forwarding is turned on for the nic ip so that traffic is sent from the source ip address to the destination ip address. 





### Deploy NVAs in an availability set

```
az vm availability-set create --name bgp-nva-aset --resource-group $hubRgName --location $hubLocation
az vm create --name bgp-nva-0 \
        --resource-group $hubRgName \
        --location $hubLocation \
        --image $nvaImage \
        --size $nvaSize \
        --availability-set bgp-nva-aset \
        --authentication-type password \
        --admin-username $nvaUser \
        --admin-password $nvaPassword \
        --storage-sku Standard_LRS \
        --nics nva0-nic nva0-ex-nic
```
 


```
az vm create --name bgp-nva-1 \
        --resource-group $hubRgName \
        --location $hubLocation \
        --image $nvaImage \
        --size $nvaSize \
        --availability-set bgp-nva-aset \
        --authentication-type password \
        --admin-username $nvaUser \
        --admin-password $nvaPassword \
        --storage-sku Standard_LRS \
        --nics nva1-nic nva1-ex-nic
```
 

## Step #4 - Provision the Azure Route Server in the Hub VNet
In this step, you will deploy an Azure Route Server instance in the Hub Vnet. This will require the ER gateway in the hub vnet to have already been provisioned (See Step 2). Once deployed, the route server must be updated to enable branch-to-branch traffic to configure route exchange. This will allow the two express route gateways which both terminated in the same virtual network to exchange routes. You will then create BGP peers from Azure Route Server to the Network Virtual Appliances. 

### Retrive Id of the RouteServerSubnet

```
trArsSubnetId=$(az network vnet subnet show \
        --name RouteServerSubnet \
        --vnet-name $hubVnetName \
        --resource-group $hubRgName \
        --query id --output tsv)
```


### Deploy Azure Route Server

```
az network public-ip create --name hub-ars-pip --resource-group $hubRgName --version IPv4 --sku Standard --zone 1 2 3 --location $hubLocation
az network routeserver create \
        --hosted-subnet $trArsSubnetId \
        --name hub-ars \
        --resource-group $hubRgName \
        --location $hubLocation \
        --public-ip-address hub-ars-pip
az network routeserver update --name hub-ars --resource-group $hubRgName --allow-b2b-traffic
```


### Define peerings with the BGP-capable NVAs

```
az network routeserver peering create --name nva0 \
        --routeserver hub-ars \
        --resource-group $hubRgName \
        --peer-ip $nva0Ip \
        --peer-asn $nvaAsn
az network routeserver peering create --name nva1 \
        --routeserver hub-ars \
        --resource-group $hubRgName \
        --peer-ip $nva1Ip \
        --peer-asn $nvaAsn
```


### Step 5 – Configure Routing on the BGP Capable NVA
Connect to the Quagga VM using the public IP address and credential used to create the VM. Once logged in, enter sudo su to switch to super user and run the following script: 
https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.network/route-server-quagga/scripts/quaggadeploy.sh 

`#!/bin/bash`

#
```
# NOTE:
## before running the script, customize the values of variables suitable for your deployment. 
## asn_quagga: Autonomous system number assigned to quagga
## bgp_routerId: IP address of quagga VM
## bgp_network1: first network advertised from quagga to the router server (inclusive of subnetmask)
## bgp_network2: second network advertised from quagga to the router server (inclusive of subnetmask)
## bgp_network3: third network advertised from quagga to the router server (inclusive of subnetmask)
## routeserver_IP1: first IP address of the router server 
## routeserver_IP2: second IP address of the router server

asn_quagga=65001
bgp_routerId=10.1.4.10
bgp_network1=10.10.10.64/27
routeserver_IP1=10.10.10.36
routeserver_IP2=10.10.10.37



sudo apt-get -y update

## Install the Quagga routing daemon
echo "Installing quagga"
sudo apt-get -y install quagga

##  run the updates and ensure the packages are up to date and there is no new version available for the packages
sudo apt-get -y update --fix-missing

## Enable IPv4 forwarding
echo "net.ipv4.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf 
echo "net.ipv4.conf.default.forwarding=1" | sudo tee -a /etc/sysctl.conf 
sysctl -p

## Create a folder for the quagga logs
echo "creating folder for quagga logs"
sudo mkdir -p /var/log/quagga && sudo chown quagga:quagga /var/log/quagga
sudo touch /var/log/zebra.log
sudo chown quagga:quagga /var/log/zebra.log

## Create the configuration files for Quagga daemon
echo "creating empty quagga config files"
sudo touch /etc/quagga/babeld.conf
sudo touch /etc/quagga/bgpd.conf
sudo touch /etc/quagga/isisd.conf
sudo touch /etc/quagga/ospf6d.conf
sudo touch /etc/quagga/ospfd.conf
sudo touch /etc/quagga/ripd.conf
sudo touch /etc/quagga/ripngd.conf
sudo touch /etc/quagga/vtysh.conf
sudo touch /etc/quagga/zebra.conf

## Change the ownership and permission for configuration files, under /etc/quagga folder
echo "assign to quagga user the ownership of config files"
sudo chown quagga:quagga /etc/quagga/babeld.conf && sudo chmod 640 /etc/quagga/babeld.conf
sudo chown quagga:quagga /etc/quagga/bgpd.conf && sudo chmod 640 /etc/quagga/bgpd.conf
sudo chown quagga:quagga /etc/quagga/isisd.conf && sudo chmod 640 /etc/quagga/isisd.conf
sudo chown quagga:quagga /etc/quagga/ospf6d.conf && sudo chmod 640 /etc/quagga/ospf6d.conf
sudo chown quagga:quagga /etc/quagga/ospfd.conf && sudo chmod 640 /etc/quagga/ospfd.conf
sudo chown quagga:quagga /etc/quagga/ripd.conf && sudo chmod 640 /etc/quagga/ripd.conf
sudo chown quagga:quagga /etc/quagga/ripngd.conf && sudo chmod 640 /etc/quagga/ripngd.conf
sudo chown quagga:quaggavty /etc/quagga/vtysh.conf && sudo chmod 660 /etc/quagga/vtysh.conf
sudo chown quagga:quagga /etc/quagga/zebra.conf && sudo chmod 640 /etc/quagga/zebra.conf

## initial startup configuration for Quagga daemons are required
echo "Setting up daemon startup config"
echo 'zebra=yes' > /etc/quagga/daemons
echo 'bgpd=yes' >> /etc/quagga/daemons
echo 'ospfd=no' >> /etc/quagga/daemons
echo 'ospf6d=no' >> /etc/quagga/daemons
echo 'ripd=no' >> /etc/quagga/daemons
echo 'ripngd=no' >> /etc/quagga/daemons
echo 'isisd=no' >> /etc/quagga/daemons
echo 'babeld=no' >> /etc/quagga/daemons

echo "add zebra config"
cat <<EOF > /etc/quagga/zebra.conf
!
interface eth0
!
interface lo
!
ip forwarding
!
line vty
!
EOF


echo "add quagga config"
cat <<EOF > /etc/quagga/bgpd.conf
!
router bgp $asn_quagga
 bgp router-id $bgp_routerId
 network $bgp_network1
 network $bgp_network2
 network $bgp_network3
 neighbor $routeserver_IP1 remote-as 65515
 neighbor $routeserver_IP1 soft-reconfiguration inbound
 neighbor $routeserver_IP2 remote-as 65515
 neighbor $routeserver_IP2 soft-reconfiguration inbound
!
 address-family ipv6
 exit-address-family
 exit
!
line vty
!
EOF

## to start daemons at system startup
echo "enable zebra and quagga daemons at system startup"
systemctl enable zebra.service
systemctl enable bgpd.service

## run the daemons
echo "start zebra and quagga daemons"
systemctl start zebra 
systemctl start bgpd  


}
```



Check the routes learned from route server using this command:

//TBD

<Insert results>

Next, checked the routes learned by the quagga device. In the shell, type `vtysh` followed by `show ip bgp`

<insert results>

##Test connectivity with traffic inspection from AVS to Spoke Networks



##Confirm avs traffic to the internet is filtered through the NVA
```
az network routeserver peering list-learned-routes \
  --resource-group $RG \
  --routeserver RouteServer \
  --name NVA1
```
````
az network nic show-effective-route-table \
  --resource-group $RG --name BackendVMNic -o table
````


## Confirm traffic from AVS to Azure spokes is going through the NVA
````
az network routeserver peering list-learned-routes \
  --resource-group $RG \
  --routeserver RouteServer \
  --name NVA1

az network nic show-effective-route-table \
  --resource-group $RG --name BackendVMNic -o table

````

## Create quagga nva on prem. Create a route filter with a prefix-list to block quad 0. 

`ip prefix-list DEMO-PRFX permit hubVnetPrefixes="10.10.10.0/24`




