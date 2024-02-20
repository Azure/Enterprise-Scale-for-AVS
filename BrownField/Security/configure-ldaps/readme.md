# Configuring LDAPS for Azure VMware Solution

## Overview

This guide will give you the required information to configure LDAPS for your Azure VMware Solution (AVS) environment.

## Prerequisites

1. Active Directory Domain Services (ADDS) is deployed in your environment.
2. [Active Directory Certificate Services (ADCS)](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/hh831740(v=ws.11) ) is deployed in your environment.
3. [Configure Group Policy to Autoenroll and Deploy Certificates](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-firewall/configure-group-policy-to-autoenroll-and-deploy-certificates), configured for default domain policy and default domain controller policy.

## What the script will do

1. Download and install the required tools
    - [OpenSSL](https://www.openssl.org/)
    - [Microsoft Visual C++ Redistributable](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170)
1. Run required OpenSSL commands against the required domain controllers
1. Export the certificate from the domain controller into the configured extraction folder.
1. Create the Storage Account in Azure based upon configuration settings.
1. Uploads the certificates as blobs into the Azure Storage Account.
1. Generate the required SAS URLs for the certificates.

## What the script will **NOT** do

1. [Configure NSX-T DNS for resolution to your Active Directory Domain](https://learn.microsoft.com/en-us/azure/azure-vmware/configure-identity-source-vcenter#configure-nsx-t-dns-for-resolution-to-your-active-directory-domain)
2. The run-command for **New-LDAPSIdentitySource** needs to be run from the portal. Fill in the required information for your domain name, credentials to be used, BaseDNUsers and BaseDNGroups. For the SASURL, please make sure you create a single string based upon both URLs returned from the script. [Add Active Directory over LDAP with SSL](https://learn.microsoft.com/en-us/azure/azure-vmware/configure-identity-source-vcenter#add-active-directory-over-ldap-with-ssl)

**Example:** SASURL1,SASURL2

**The example below will NOT work, only a sample, please use your own values**  

`https://myaccount.blob.core.windows.net/pictures/profile.jpg?sv=2013-08-15&st=2013-08-16&se=2013-08-17&sr=c&sp=r&rscd=file;%20attachment&rsct=binary&sig=YWJjZGVmZw%3d%3d&sig=a39%2BYozJhGp6miujGymjRpN8tsrQfLo9Z3i8IRyIpnQ%3d` **,** `https://myaccount1.blob.core.windows.net/pictures/profile.jpg?sv=2013-08-15&st=2013-08-16&se=2013-08-17&sr=c&sp=r&rscd=file;%20attachment&rsct=binary&sig=YWJjZGVmZw%3d%3d&sig=a39%2BYozJhGp6miujGymjRpN8tsrQfLo9Z3i8IRyIpnQ%3d`

The full script can be found [here](script.ps1). It is designed to be run in snippets. Open the file and run each SNIPPET, there are 5 SNIPPETS in total and the file should be run to completion in one terminal window.
