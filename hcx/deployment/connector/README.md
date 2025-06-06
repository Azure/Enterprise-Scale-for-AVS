# Automated Deployment and Configuration for HCX Connector

This PowerShell solution provides automated deployment and configuration of VMware HCX Connector in an on-premises vSphere environment for integration with Azure VMware Solution (AVS).

## Introduction

The HCX Connector Automated Deployment solution streamlines the process of:
- Deploying VMware HCX Connector OVA to on-premises vCenter
- Configuring HCX with proper location, vCenter integration, SSO, licensing, and role mappings
- Establishing connectivity between on-premises infrastructure and Azure VMware Solution

This automation eliminates manual configuration steps and ensures consistent deployments across environments.

## Prerequisites

### Infrastructure Requirements
- **On-premises vSphere environment** with vCenter Server 6.5 or later
- **Network connectivity** to Azure VMware Solution
- **Administrator privileges** on vCenter Server
- **PowerShell 5.1 or later** with execution policy allowing script execution
- **Network segment** pre-configured for HCX Connector VM deployment
- **Available IP address** for HCX Connector VM (recommended: use .9 in fourth octet)

### Software Requirements
- **VMware HCX Connector OVA file** (download from HCX Manager portal or through a support ticket to Microsoft)
- **HCX License Key** from Azure VMware Solution HCX Add-on
- **Active Directory group** for HCX administrative access

### Azure VMware Solution Requirements
- **Azure VMware Solution** private cloud deployed
- **HCX Add-on** enabled in Azure VMware Solution
- **HCX license key** obtained from Azure portal
- **Network connectivity** between on-premises and Azure VMware Solution

### Network Requirements
- **Port 9443** accessible for HCX Connector management interface
- **Appropriate firewall rules** for HCX traffic (refer to [Azure VMware Solution HCX documentation](https://learn.microsoft.com/azure/azure-vmware/configure-vmware-hcx#prerequisites))
- **DNS resolution** for vCenter and HCX endpoints

## Deployment Steps

### Step 1: Download and Prepare Files
1. Download the VMware HCX Connector OVA file
2. Clone or download this repository to your deployment/jumpbox machine
3. Ensure the deployment machine has fast network access to vCenter Server

### Step 2: Configure Parameters
Edit the `Main.parameters.ps1` file with your environment-specific values:

```powershell
# vCenter Configuration
$vCenter = "https://vcenter.example.com/"
$vCenterUserName = "administrator@vsphere.local"
$datastoreName = "YourDatastore"

# Content Library Configuration
$contentLibraryName = "vsphere-content-library"
$contentLibraryitemName = "HCX-Connector"
$applianceFilePath = "C:\Path\To\VMware-HCX-Connector-4.x.x.x-xxxxxxx.ova"

# HCX VM Configuration
$hcxUrl = "https://10.1.1.9:9443/"
$segmentName = "Management-Network"
$applianceVMName = "HCX-Connector-VM"
$applianceVMIP = "10.1.1.9"
$applianceVMGatewayIP = "10.1.1.1"

# HCX Configuration
$hcxAdminGroup = "domain\HCX-Administrators"
$hcxLicenseKey = "YOUR-HCX-LICENSE-KEY"
```

### Step 3: Execute Deployment
Run the main deployment script:

```powershell
# Navigate to the script directory
cd C:\<PATH>\<TO>\<MAIN.PS1>

# Execute the main script
.\Main.ps1

# you will be prompted for vCenter password

# OR
.\Main.ps1 -vCenterPassword (Read-Host -AsSecureString -Prompt "Enter vCenter Password")

```

### Step 4: Monitor Deployment Progress
The script will automatically:
1. Create or verify content library existence
2. Upload HCX Connector OVA to content library
3. Deploy HCX Connector VM from OVA
4. Wait for HCX services to start
5. Configure HCX location settings
6. Integrate with vCenter Server
7. Configure SSO integration
8. Apply HCX license key
9. Set up role mappings for administrative access
10. Restart HCX services to complete configuration

## Post-deployment Steps

### Verification Tasks

1. Ensure that you get an output as shown below.

```
Supply values for the following parameters:
vCenterPassword: *********
Content Library 'vsphere-content-library' created successfully.
Content Library Item 'HCX-Connector' created successfully.
Uploading HCX Installation file.
Creating upload session.
Starting upload to https://10.1.1.2:443/cls/data/53da6d7a-e17d-4c52-a56c-43ad1436b994/VMwar
e-HCX-Connector-4.11.0.0-24457397.ova
File: C:\Users\jumpboxadmin\Downloads\VMware-HCX-Connector-4.11.0.0-24457397.ova
File size: 5550837760 bytes (5.17 GB)
Starting file upload using Invoke-WebRequest...
Upload job started (Job ID: 7). Monitoring progress...
File being uploaded: VMware-HCX-Connector-4.11.0.0-24457397.ova (5293.7 MB)
Upload in progress | Elapsed: 0.5 min | Job: Running
Session: ACTIVE | Est. progress: ~20% | ETA: ~2.0 min
Upload in progress | Elapsed: 1.0 min | Job: Running
Session: ACTIVE | Est. progress: ~39% | ETA: ~2.0 min
Upload in progress | Elapsed: 1.5 min | Job: Running
Session: ACTIVE | Est. progress: ~59% | ETA: ~1.0 min
Upload job finished | Total time: 2.0 min | Job: Completed
Upload job completed, skipping session status check
Upload job completed, ending monitoring loop
Upload job completed in 2.0 minutes
HCX OVA File Upload completed successfully!
Waiting for upload to be fully processed...
Validating upload...
Upload validation successful. Completing upload session...
Upload session completed successfully!
Creating HCX Appliance VM from OVA...Done!
HCX Appliance VM deployment completed successfully.

Starting HCX configuration for URL: https://10.1.1.9:9443/
HCX service is still booting up, retrying in 1 minute...
HCX service is still booting up, retrying in 1 minute...
HCX service is still booting up, retrying in 1 minute...
HCX service is still booting up, retrying in 1 minute...
HCX service is still booting up, retrying in 1 minute...
HCX URL is reachable: https://10.1.1.9:9443/
HCX Location set successfully: EU West 2 (London).
vCenter Certificate imported in HCX successfully.
HCX vCenter configuration completed successfully.
HCX SSO configuration completed successfully.
Polling HCX License Key activation status (timeout: 10 minutes)...
HCX License Key activation in progress. Status: INITIATED - Checking again in 10 seconds...
HCX License Key activation in progress. Status: INITIATED - Checking again in 10 seconds...
HCX License Key activation in progress. Status: INITIATED - Checking again in 10 seconds...
HCX License Key activation in progress. Status: INITIATED - Checking again in 10 seconds...
HCX License Key activation in progress. Status: INITIATED - Checking again in 10 seconds...
HCX License Key activation in progress. Status: INITIATED - Checking again in 10 seconds...
HCX License Key activation in progress. Status: INITIATED - Checking again in 10 seconds...
HCX License Key activation in progress. Status: INITIATED - Checking again in 10 seconds...
HCX License Key activation in progress. Status: INITIATED - Checking again in 10 seconds...
HCX License Key activation in progress. Status: INITIATED - Checking again in 10 seconds...
HCX License Key activation in progress. Status: INITIATED - Checking again in 10 seconds...
HCX License Key activation in progress. Status: INITIATED - Checking again in 10 seconds...
HCX License Key activation in progress. Status: INITIATED - Checking again in 10 seconds...
HCX License Key activation in progress. Status: INITIATED - Checking again in 10 seconds...
HCX License Key activation in progress. Status: INITIATED - Checking again in 10 seconds...
HCX License Key has been successfully activated.
HCX Role Mappings configured successfully.
Starting HCX service restart process...
Starting App Engine restart process...
Checking App Engine status...
Stopping App Engine...
App Engine component stopped successfully.
Starting App Engine again...
Waiting for App Engine to start... (Attempt 1/10)
App Engine is running again.
g again.            rocess completed successfully.
App Engine restart pnt restart process...
rocess completed sucnt status...
cessfully.          nt...
Starting Web Componed successfully.
nt restart process..nt again...
.                   onent to start... (Attempt 1/15)
Checking Web Componeonent to start... (Attempt 2/15)
nt status...        onent to start... (Attempt 3/15)
Stopping Web Componeonent to start... (Attempt 4/15)
nt...               ning again.
Web Component stoppeed successfully.
d successfully.     onfiguration completed successfully.
Starting Web ComponeCX at: https://10.1.1.9:9443/
nt again...
Waiting for Web Comp
onent to start... (A
ttempt 1/15)
Waiting for Web Comp
onent to start... (A
ttempt 2/15)
Waiting for Web Comp
onent to start... (Attempt 3/15)
Waiting for Web Component to start... (Attempt 4/15)
Web Component is running again.
HCX services restarted successfully.
HCX deployment and configuration completed successfully.
You can now access HCX at: https://10.1.1.9:9443/
PS C:\avs\OVF>
```
2. **Access HCX Manager**: Navigate to the HCX URL (e.g., `https://10.1.1.9:9443/`)
3. **Login Verification**: Use vCenter credentials to log into HCX Manager
4. **License Status**: Verify HCX license is properly applied and active
5. **Service Status**: Confirm all HCX services are running correctly

### Azure VMware Solution Integration
1. **Site Pairing**: Pair the on-premises HCX Connector with Azure VMware Solution HCX Cloud Manager
2. **Service Mesh**: Create service mesh between sites
3. **Network Extension**: Configure network extension profiles as needed
4. **Migration Planning**: Plan and execute workload migrations

### Security Configuration
1. **Firewall Rules**: Configure necessary firewall rules for HCX traffic
2. **Access Control**: Validate role-based access control is functioning
3. **Network Segmentation**: Implement appropriate network security policies

### Monitoring and Maintenance
1. **Health Monitoring**: Set up monitoring for HCX services and connectivity
2. **Log Analysis**: Configure log collection and analysis for troubleshooting
3. **Backup Configuration**: Back up HCX configuration settings
4. **Update Planning**: Plan for HCX Connector updates and maintenance windows

## Next Steps

Use the additional guidance below on getting started with HCX.

[VMware HCX For Azure VMware Solution (AVS)](../../README.md)