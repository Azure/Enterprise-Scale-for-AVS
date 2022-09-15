# How to build SDDCs in GBB subscription and Embedded Labs

## AVS SDDCs builds

The first thing to do is to clone Enrique Gonzalez's ESLZ-deployment repo:

<https://github.com/E-G-C/ESLZ-deployment>

> Please keep in mind these instructions have been built for the purpose of having Hands-On exercises for partners. Your use and setup may vary depending on your own needs, this is just guidance.

Once this repository has been copied to your local machine, there are some standards we at GPSUS use to deploy the SDDCs.

Limits: Up to 10 SDDCs can be deployed at once. Check with the other members of the ESLZ group to ensure there's enough capacity and in what regions.

Under the AVS\parameters folder, you will find 10 .json files. You are free to edit these as needed but the CIDRs we use are consitent numbering for a lot of the further automation to function properly, so keep this in mind when changing the CIDR definitions of these files.

### JSON files

![](/images/embedded1.png)

1. Each of these files represent one (1) SDDC. Up to 10 SDDCs at once could be deployed using this automation.
2. The first parameter to edit is the "Location" which represents the Azure region where the AVS SDDC will be deployed, in this example it's brazilsouth.
3. The prefix to assign to the resources/resource groups. For partner hands-on labs, we recommend including the partner name, for example: GPSUS-XYZ1 for the first AVS SDDC.
4. Add the private cloud IP space. We in GPSUS have standardized this with this format: 10.101.0.0/22 where the last digit of the secont octet represents the SDDC number, in this example the last '1' in 101.
5. VNetAddressSpace: same as #4 where the last digit of the second octet represents the SDDC number.
6. VNetGatewaySubnet.
7. AlertEmails: Enter your email to get notified when the AVS SDDC is completed.
8. DeployJumpbox: Enter 'true' if you would like the automation to deploy a Jumpbox for you, otherwise, enter 'false'.
9. JumpboxUsername: Enter a name for the admin user for your Jumpbox.
10. JumpboxPassword: Enter a desired password for your jumpbox.
11. JumpboxSubnet: Edit as desired.
12. BastionSubnet: Edit as desired.
13. VNetExists: Default value is 'false' and will create a VNet.
14. DeployHCX: Default value is 'false', change it if you would like the automation to enable HCX for you.
15. DeploySRM: Default value is 'false', change it if you would like the automation to enable SRM for you.

> SECTION NOT COMPLETED YET, WILL COMPLETE SOON

## Embedded Lab Builds

Files used to deploy embedded simulated on-premises environments to AVS SDDCs.

Download zip file and extract in a directory where you'll be working from in the assigned Jumpbox.

Location of zip file to download to Jumpbox:
https://gpsusstorage.blob.core.windows.net/avs-embedded-labs/avs-embedded-labs.zip

### Items needed to prepare Jumpbox

#### Install PowerShell Core

https://github.com/PowerShell/PowerShell

> Once installed, all further operations should be performed from PowerShell Core, not PowerShell. PowerShell Core should be a black icon with a black background, if you have a blue background, you're using the old version of PowerShell, it should have been added to your Start menu.

#### Install VMware PowerCLI

```
Install-Module VMware.PowerCLI -scope AllUsers -force -SkipPublisherCheck -AllowClobber
```
#### Additional Commands to Run
```
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false
```
```
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
```
```
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false
```
```
Set-ExecutionPolicy Unrestricted
```
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```
#### Install YAML PowerShell Module
```
Install-Module powershell-yaml
```

#### Edit nestedlabs.yml file

1. Open the nestedlabs.yml file with a text editor from your working directory.
2. Enter the information for:
    - AVS vCenter URL
    - AVS Username
    - AVS cloudadmin password
    - AVS NSX-T URL
    - AVS NSX-T Username
    - AVS NSX-T cloudadmin password

#### Ready for Deployment

At this point you're ready to start deploying the nested environments. You will run the following command from your Jumpbox's PowerShell Core window:
```
.\labdeploy.ps1 -group 1 -lab 1
```
> **IMPORTANT** - This numbering sequence (for groups and labs) where created for the purposes of enabling partner groups (many at a time), therefore it may not map directly to your needs.

The group and lab number you specify when you run the script will determine the IP address schemes of the nested environments very similar to the following table:


| **Group** | **Lab** | **vCenter IP** | **Username**                | **Password** | **Web workload IP** | **App Workload IP** |
| --------- | --------------- | -------------- | --------------------------- | ------------ | ------------------- | ------------------- |
| **X**         | **Y**               | 10.**X**.**Y**.3       | administrator@avs.lab | MSFTavs1! | 10.**X**.1**Y**.1/25        | 10.**X**.1**Y**.129/25      |

#### Example for Group 1 with 4 participants

| **Group** | **Lab** | **vCenter IP** | **Username**                | **Password** | **Web workload IP** | **App Workload IP** |
| --------- | --------------- | -------------- | --------------------------- | ------------ | ------------------- | ------------------- |
| 1         | 1               | 10.1.1.3       | administrator@avs.lab | MSFTavs1! | 10.1.11.1/25        | 10.1.11.129/25      |
| 1         | 2               | 10.1.2.3       | administrator@avs.lab | MSFTavs1! | 10.1.12.1/25        | 10.1.12.129/25      |
| 1         | 3               | 10.1.3.3       | administrator@avs.lab | MSFTavs1! | 10.1.13.1/25        | 10.1.13.129/25      |
| 1         | 4               | 10.1.4.3       | administrator@avs.lab | MSFTavs1! | 10.1.14.1/25        | 10.1.14.129/25      |
