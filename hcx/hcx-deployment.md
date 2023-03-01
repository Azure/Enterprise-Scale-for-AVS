# HCX Deployment Scenarios

## HCX over VPN

For the purposes of this article, VPN will also include connections via 3rd party SD-WAN solutions.

HCX over a VPN connection is fully supported on Azure VMware Solution. VMware has a set of minimum requirements for support which can be found here: [Network Underlay Minimum Requirements](https://docs.vmware.com/en/VMware-HCX/4.2/hcx-user-guide/GUID-8128EB85-4E3F-4E0C-A32C-4F9B15DACC6D.html).

A minimum MTU size of 1150 is required. Microsoft recommends setting the MTU to 1300 in the Uplink and Replication Network Profiles.

![HCX over VPN](.\images\hcx-vpn.png)

### Requirements for HCX over VPN

|On-Premises|HCX Connector|Interconnect (IX)|Network Extension (NE)|
|-----|-----|-----|-----|
|IP Addresses |<p style="padding-left: 20px;">- 1 IP from Management Network <sup>1</sup> <sup>2</sup></p> <p style="padding-left: 20px;">- 1 IP from Uplink Network <sup>1</sup> <sup>2</sup></p>|<p style="padding-left: 20px;">- 1 IP from Management Network <sup>1</sup> <sup>2</sup></p> <p style="padding-left: 20px;">- 1 IP from Uplink Network <sup>1</sup> <sup>2</sup></p> <p style="padding-left: 20px;">- 1 IP from Replication Network <sup>1</sup> <sup>2</sup></p> <p style="padding-left: 20px;">- 1 IP from vMotion Network <sup>4</sup>|<p style="padding-left: 20px;">- 1 IP from Management Network <sup>1</sup> <sup>2</sup></p> <p style="padding-left: 20px;">- 1 IP from Uplink Network <sup>1</sup> <sup>2</sup></p>|
|Ports - Uplink|Outbound TCP 443 <sup>3</sup> <p style="padding-left: 20px;">- https://connect.hcx.vmware.com</p> <p style="padding-left: 20px;">- https://hybridity-depot.vmware.com</p> <p style="padding-left: 20px;">- https://avs-hcx-url (Obtained from Azure Portal)</p>|Outbound UDP 4500 <sup>3</sup> <p style="padding-left: 20px;">- TNT**XX**-HCX-UPLINK network profile range of IPs obtained from HCX Network Profiles in AVS side</p>|Outbound UDP 4500 <sup>3</sup> <p style="padding-left: 20px;">- TNT**XX**-HCX-UPLINK network profile range of IPs obtained from HCX Network Profiles in AVS side</p>|
|Other|<p style="padding-left: 20px;">- Proxy Information (if applicable)</p> <p style="padding-left: 20px;">- DNS Server IP</p> <p style="padding-left: 20px;">- NTP Server IP</p> <p style="padding-left: 20px;">- User with vCenter Admin rights</p> <p style="padding-left: 20px;">- HCX License Key (From Azure Portal)</p>|<p style="padding-left: 20px;">- 100 Mbps minimum available bandwidth</p>|<p style="padding-left: 20px;">- 1 NE Appliance per vDS</p> <p style="padding-left: 20px;">- 8 networks can be extended per appliance</p> <p style="padding-left: 20px;">- Cannot extend network where appliances are deployed</p> <p style="padding-left: 20px;">- Cannot extend Management Network</p>|

#### MTUs for Network Profiles
|Management|Uplink|Replication|vMotion|
|-----|-----|-----|-----|
1500<sup>5</sup>|1300|1300|9000 (Default)|

- <sup>1</sup> Appliances can be deployed on a separate network from the Management Network as long as appliances have unrestricted access to the Management Network.
- <sup>2</sup> Managemen/Uplink/Replication Networks can be the same network.
- <sup>3</sup> Just outbound needed.
- <sup>4</sup> Must be a VM Port Group, cannot e a VMKernel PG.
- <sup>5</sup> If Management Network will also serve as Uplink and/or Replication Network, set this to 1300.

## HCX over ExpressRoute

![HCX over ExpressRoute](.\images\hcx-er.png)

### Requirements for HCX over Express Route

|On-Premises|HCX Connector|Interconnect (IX)|Network Extension (NE)|
|-----|-----|-----|-----|
|IP Addresses |<p style="padding-left: 20px;">- 1 IP from Management Network <sup>1</sup> <sup>2</sup></p> <p style="padding-left: 20px;">- 1 IP from Uplink Network <sup>1</sup> <sup>2</sup></p>|<p style="padding-left: 20px;">- 1 IP from Management Network <sup>1</sup> <sup>2</sup></p> <p style="padding-left: 20px;">- 1 IP from Uplink Network <sup>1</sup> <sup>2</sup></p> <p style="padding-left: 20px;">- 1 IP from Replication Network <sup>1</sup> <sup>2</sup></p> <p style="padding-left: 20px;">- 1 IP from vMotion Network <sup>4</sup>|<p style="padding-left: 20px;">- 1 IP from Management Network <sup>1</sup> <sup>2</sup></p> <p style="padding-left: 20px;">- 1 IP from Uplink Network <sup>1</sup> <sup>2</sup></p>|
|Ports - Uplink|Outbound TCP 443 <sup>3</sup> <p style="padding-left: 20px;">- https://connect.hcx.vmware.com</p> <p style="padding-left: 20px;">- https://hybridity-depot.vmware.com</p> <p style="padding-left: 20px;">- https://avs-hcx-url (Obtained from Azure Portal)</p>|Outbound UDP 4500 <sup>3</sup> <p style="padding-left: 20px;">- TNT**XX**-HCX-UPLINK network profile range of IPs obtained from HCX Network Profiles in AVS side</p>|Outbound UDP 4500 <sup>3</sup> <p style="padding-left: 20px;">- TNT**XX**-HCX-UPLINK network profile range of IPs obtained from HCX Network Profiles in AVS side</p>|
|Other|<p style="padding-left: 20px;">- Proxy Information (if applicable)</p> <p style="padding-left: 20px;">- DNS Server IP</p> <p style="padding-left: 20px;">- NTP Server IP</p> <p style="padding-left: 20px;">- User with vCenter Admin rights</p> <p style="padding-left: 20px;">- HCX License Key (From Azure Portal)</p>|<p style="padding-left: 20px;">- 100 Mbps minimum available bandwidth</p>|<p style="padding-left: 20px;">- 1 NE Appliance per vDS</p> <p style="padding-left: 20px;">- 8 networks can be extended per appliance</p> <p style="padding-left: 20px;">- Cannot extend network where appliances are deployed</p> <p style="padding-left: 20px;">- Cannot extend Management Network</p>|

#### MTUs for Network Profiles
|Management|Uplink|Replication|vMotion|
|-----|-----|-----|-----|
9000 (Default)|9000 (Default)|9000 (Default)|9000 (Default)|

- <sup>1</sup> Appliances can be deployed on a separate network from the Management Network as long as appliances have unrestricted access to the Management Network.
- <sup>2</sup> Managemen/Uplink/Replication Networks can be the same network.
- <sup>3</sup> Just outbound needed.
- <sup>4</sup> Must be a VM Port Group, cannot e a VMKernel PG.

## HCX over Public IP

![HCX over Public IP](.\images\hcx-pip.png)

HCX can be enabled over public IP. Microsoft recommends this option when customers connect to Azure via VPN in order to avoid the “double tunneling” effect that HCX over VPN provides. If this is not an acceptable option, please use HCX over VPN recommendation.

Official documentation on enabling HCX over public IP can be found in Microsoft’s official documentation: [Enable HCX over the internet](https://learn.microsoft.com/en-us/azure/azure-vmware/enable-hcx-access-over-internet).

### Prerequisites for enabling HCX over Public IP

- Select “Connect using Public IP down to the NSX-T Edge” for Internet Connectivity in the AVS Private Cloud.
-	Create 2 blocks of Public IP blocks:
    - /32 for HCX Cloud Manager (1 address)
    - /29 for new Uplink Network Profile (8 addresses)
-	Add NAT rules to NSX-T T1 Gateway:
    - DNAT rule – Public IP for HCX Manager as Source, Private IP for HCX Manager in AVS as Destination.
    - SNAT rule – Private IP for HCX Manager in AVS as Source, dummy private IP (made up IP) as Destination.
-	Create T1 Gateway Firewall Policies:
    - On-Premises IP as Source, HCX Manager assigned to Public IP as Destination.
        - Action: Allow
    - Any as Source, HCX Manager assigned to Public IP as Destination.
        - Action: Drop
-	Create Public IP network segment on NSX-T
    - /30 Segment from /29 block created for Uplink Network Profile
-	Create new HCX Uplink Network Profile in AVS using the /29 block of IPs previously created.
-	When creating Site Pairing from On-Premises HCX Connector, enter the Public IP address assigned to HCX Manager on AVS side.
-	When creating Service Mesh from On-Premises HCX Connector, select the newly created Uplink Network Profile from the /29 block of IPs.

### Requirements for HCX over Public IP

|On-Premises|HCX Connector|Interconnect (IX)|Network Extension (NE)|
|-----|-----|-----|-----|
|IP Addresses |<p style="padding-left: 20px;">- 1 IP from Management Network <sup>1</sup> <sup>2</sup></p> <p style="padding-left: 20px;">- 1 IP from Uplink Network <sup>1</sup> <sup>2</sup></p>|<p style="padding-left: 20px;">- 1 IP from Management Network <sup>1</sup> <sup>2</sup></p> <p style="padding-left: 20px;">- 1 IP from Uplink Network <sup>1</sup> <sup>2</sup></p> <p style="padding-left: 20px;">- 1 IP from Replication Network <sup>1</sup> <sup>2</sup></p> <p style="padding-left: 20px;">- 1 IP from vMotion Network <sup>4</sup>|<p style="padding-left: 20px;">- 1 IP from Management Network <sup>1</sup> <sup>2</sup></p> <p style="padding-left: 20px;">- 1 IP from Uplink Network <sup>1</sup> <sup>2</sup></p>|
|Ports - Uplink|Outbound TCP 443 <sup>3</sup> <p style="padding-left: 20px;">- https://connect.hcx.vmware.com</p> <p style="padding-left: 20px;">- https://hybridity-depot.vmware.com</p> <p style="padding-left: 20px;">- https://avs-hcx-url (Obtained from Azure Portal) - This will be the public IP address assigned to HCX Manager on AVS side</p>|Outbound UDP 4500 <sup>3</sup> <p style="padding-left: 20px;">- New PUBLIC IP network profile created with range of IPs obtained from HCX Network Profiles on AVS side</p>|Outbound UDP 4500 <sup>3</sup> <p style="padding-left: 20px;">- New PUBLIC IP network profile created with range of IPs obtained from HCX Network Profiles on AVS side</p>|
|Other|<p style="padding-left: 20px;">- Proxy Information (if applicable)</p> <p style="padding-left: 20px;">- DNS Server IP</p> <p style="padding-left: 20px;">- NTP Server IP</p> <p style="padding-left: 20px;">- User with vCenter Admin rights</p> <p style="padding-left: 20px;">- HCX License Key (From Azure Portal)</p>|<p style="padding-left: 20px;">- 100 Mbps minimum available bandwidth</p>|<p style="padding-left: 20px;">- 1 NE Appliance per vDS</p> <p style="padding-left: 20px;">- 8 networks can be extended per appliance</p> <p style="padding-left: 20px;">- Cannot extend network where appliances are deployed</p> <p style="padding-left: 20px;">- Cannot extend Management Network</p>|

#### MTUs for Network Profiles
|Management|Uplink|Replication|vMotion|
|-----|-----|-----|-----|
|1500|1500|1500|9000 (Default)|

- <sup>1</sup> Appliances can be deployed on a separate network from the Management Network as long as appliances have unrestricted access to the Management Network.
- <sup>2</sup> Managemen/Uplink/Replication Networks can be the same network.
- <sup>3</sup> Just outbound needed.
- <sup>4</sup> Must be a VM Port Group, cannot e a VMKernel PG.
