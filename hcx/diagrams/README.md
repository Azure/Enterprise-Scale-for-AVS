# Suggested Scripts for Build-Out of draw.io hcx-options diagram

Feel free to download the draw.io diagram [here](./diagrams/hcx-options.drawio).

In the diagram there are 4 options (tabs):

1. Re-IP
2. Duplicate Networks
3. Network Extension wo/MON (without)
4. Network Extension w/MON (with)

![draw.io Layers](../images/drawio-layers.png)

Ensure you have layers view enabled in draw.io by clicking **View->Layers** from the menu bar.

As shown in the above picture, you can see an *eye* either turned on or off. Clicking a turned off eye will enable that specific layer. Clicking a turned on eye icon will remove the layer from showing. Start with **Background** turned on.

## Option 1: Re-IP Steps

|**Step**|**Layer**|**<span style="color:green">ON</span>/<span style="color:red">OFF</span>**|**Notes**|
|--------|---------|----------|---------|
|1|AVS Deployment|**<span style="color:green">ON</span>**|Here you have the opportunity to explain the components that get deployed once AVS is deployed.|
|2|AVS L2 10.10 Network|**<span style="color:green">ON</span>**|Explain an L2 network is created in NSX-T and a VM connected to it.|
|3|Azure VNET|**<span style="color:green">ON</span>**|Customer's Azure VNET which AVS will connect to.|
|4|On-Prem|**<span style="color:green">ON</span>**|Customer's on-prem environment, with ER connected to their Azure VNET.|
|5|ER Global Reach|**<span style="color:green">ON</span>**|Explain ER Global Reach connection from AVS.|
|6|ER to VNET|**<span style="color:green">ON</span>**|Explain ER to VNET connection from AVS.|
|7|Interconnection|**<span style="color:green">ON</span>**|Explain this is only there to show the interconnectivy between on-prem and AVS and to use the space to make the diagram look less busy and more readable.|
|8|HCX On-Prem|**<span style="color:green">ON</span>**|Explain HCX Connector needs to be deployed on-premises.|
|9|HCX Site Pairing|**<span style="color:green">ON</span>**|Explain the next step is to establish the HCX Site Pairing.|
|10|HCX-IX|**<span style="color:green">ON</span>**|Next step is to deploy the HCX Service Mesh which will deploy the appliances in pairs, starting with the Interconnect appliance (IX).|
|11|HCX-WO|**<span style="color:green">ON</span>**|HCX Wan Optimization (WO) appliance is next|
|12|HCX-NE|**<span style="color:green">ON</span>**|HCX Network Extension(NE) also gets deployed with the Service Mesh|
|13|HCX-IX Tunnel|**<span style="color:green">ON</span>**|IX Tunnel gets established between the two IX appliances once successfully deployed. This is the tunnel that manages the migration/replication traffic.|
|14|HCX-NE Tunnel|**<span style="color:green">ON</span>**|NE Tunnel gets established between the two NE appliances once successfully deployed. This is the tunnel that manages the communication traffic for VMs on extended L2 networks.|
|15|AVS VM to VNET Flow|**<span style="color:green">ON</span>**|Demonstrates the path the flow of communication utilizes between the VM in the AVS L2 network and the customer's Azure VNET.|
|16|AVS VM to VNET Flow|**<span style="color:red">OFF</span>**|Demonstrates the path the flow of communication utilizes between the VM in the AVS L2 network and the customer's Azure VNET.|
|17|OnPrem to VNET Flow|**<span style="color:green">ON</span>**|Demonstrates the path the flow of communication utilizes between an on-premises VM and a VM in the customer's Azure VNET.|
|18|OnPrem to VNET Flow|**<span style="color:red">OFF</span>**|Demonstrates the path the flow of communication utilizes between an on-premises VM and a VM in the customer's Azure VNET.|
|19|OnPrem to AVS Flow|**<span style="color:green">ON</span>**|Demonstrates the path the flow of communication utilizes between an on-premises VM and a VM in AVS.|
|20|OnPrem to AVS Flow|**<span style="color:red">OFF</span>**|Demonstrates the path the flow of communication utilizes between an on-premises VM and a VM in AVS.|
|21|Create new NSX-T Segment|**<span style="color:green">ON</span>**|Demonstrates the creation of an NSX-T Network Segment in AVS with a CIDR different from any Network on-premises or in Azure.|
|22|HCX Bulk Migration|**<span style="color:green">ON</span>**|Initiate Bulk Migration of on-premises VMs.|
|23|HCX Bulk Migration Complete|**<span style="color:green">ON</span>**|Migration of VMs completes.|
|24|HCX Bulk Migration|**<span style="color:red">OFF</span>**|Initiate Bulk Migration of on-premises VMs. Turn off to demonstrate completion of migration.|
|25|Retire L2 OnPrem Segment|**<span style="color:green">ON</span>**|This will mimic the on-premises network being removed/retired.|
|26|New Flow-Migrated VMs|**<span style="color:green">ON</span>**|This will show the path the flow of communication utilizes for the newly migrated and re-IP'ed VMs in AVS back to on-premises VMs|

## Option 2: Duplicate Networks

|**Step**|**Layer**|**<span style="color:green">ON</span>/<span style="color:red">OFF</span>**|**Notes**|
|--------|---------|----------|---------|
|1|AVS Deployment|**<span style="color:green">ON</span>**|Here you have the opportunity to explain the components that get deployed once AVS is deployed.|
|2|AVS L2 10.10 Network|**<span style="color:green">ON</span>**|Explain an L2 network is created in NSX-T and a VM connected to it.|
|3|Azure VNET|**<span style="color:green">ON</span>**|Customer's Azure VNET which AVS will connect to.|
|4|On-Prem|**<span style="color:green">ON</span>**|Customer's on-prem environment, with ER connected to their Azure VNET.|
|5|ER Global Reach|**<span style="color:green">ON</span>**|Explain ER Global Reach connection from AVS.|
|6|ER to VNET|**<span style="color:green">ON</span>**|Explain ER to VNET connection from AVS.|
|7|Interconnection|**<span style="color:green">ON</span>**|Explain this is only there to show the interconnectivy between on-prem and AVS and to use the space to make the diagram look less busy and more readable.|
|8|HCX On-Prem|**<span style="color:green">ON</span>**|Explain HCX Connector needs to be deployed on-premises.|
|9|HCX Site Pairing|**<span style="color:green">ON</span>**|Explain the next step is to establish the HCX Site Pairing.|
|10|HCX-IX|**<span style="color:green">ON</span>**|Next step is to deploy the HCX Service Mesh which will deploy the appliances in pairs, starting with the Interconnect appliance (IX).|
|11|HCX-WO|**<span style="color:green">ON</span>**|HCX Wan Optimization (WO) appliance is next|
|12|HCX-NE|**<span style="color:green">ON</span>**|HCX Network Extension(NE) also gets deployed with the Service Mesh|
|13|HCX-IX Tunnel|**<span style="color:green">ON</span>**|IX Tunnel gets established between the two IX appliances once successfully deployed. This is the tunnel that manages the migration/replication traffic.|
|14|HCX-NE Tunnel|**<span style="color:green">ON</span>**|NE Tunnel gets established between the two NE appliances once successfully deployed. This is the tunnel that manages the communication traffic for VMs on extended L2 networks.|
|15|AVS VM to VNET Flow|**<span style="color:green">ON</span>**|Demonstrates the path the flow of communication utilizes between the VM in the AVS L2 network and the customer's Azure VNET.|
|16|AVS VM to VNET Flow|**<span style="color:red">OFF</span>**|Demonstrates the path the flow of communication utilizes between the VM in the AVS L2 network and the customer's Azure VNET.|
|17|OnPrem to VNET Flow|**<span style="color:green">ON</span>**|Demonstrates the path the flow of communication utilizes between an on-premises VM and a VM in the customer's Azure VNET.|
|18|OnPrem to VNET Flow|**<span style="color:red">OFF</span>**|Demonstrates the path the flow of communication utilizes between an on-premises VM and a VM in the customer's Azure VNET.|
|19|OnPrem to AVS Flow|**<span style="color:green">ON</span>**|Demonstrates the path the flow of communication utilizes between an on-premises VM and a VM in AVS.|
|20|OnPrem to AVS Flow|**<span style="color:red">OFF</span>**|Demonstrates the path the flow of communication utilizes between an on-premises VM and a VM in AVS.|
|21|Create new disconnected NSX-T Segment|**<span style="color:green">ON</span>**|Demonstrates the creation of a disconeected NSX-T Network Segment in AVS with the same CIDR as the network on-premises being recreated.|
|22|HCX Bulk Migration|**<span style="color:green">ON</span>**|Initiate Bulk Migration of on-premises VMs.|
|23|HCX Bulk Migration Complete|**<span style="color:green">ON</span>**|Migration of VMs completes.|
|24|HCX Bulk Migration|**<span style="color:red">OFF</span>**|Initiate Bulk Migration of on-premises VMs. Turn off to demonstrate completion of migration.|
|25|Retire L2 OnPrem Segment|**<span style="color:green">ON</span>**|This will mimic the on-premises network being removed/retired.|
|26|Connect Segment to T1|**<span style="color:green">ON</span>**|This will connect the previously created disconnected NSX-T Segment to the T1.|
|27|Update newly advertised BGP route|**<span style="color:green">ON</span>**|Newly duplicated network will advertise via BGP the new route, it must be updated.|
|28|New Flow-Migrated VMs to Source|**<span style="color:green">ON</span>**|This will show the path the flow of communication utilizes for the newly migrated VMs in the duplicated network on the AVS side back to on-premises VMs|
|29|AVS to AVS Flow|**<span style="color:green">ON</span>**|This will show the path the flow of communication utilizes for the newly migrated VMs in the duplicated network on the AVS side back to another VM in a different network on the AVS side.|
