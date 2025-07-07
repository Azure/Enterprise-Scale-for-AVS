# HCX Service Mesh Deployment for Azure VMware Solution (AVS)

## Introduction

This guide provides step-by-step instructions for deploying HCX Service Mesh between your on-premises VMware environment and Azure VMware Solution (AVS). The HCX Service Mesh enables seamless workload migration, disaster recovery, and hybrid cloud connectivity.

The deployment scripts automates the creation of:
- Site pairing between on-premises HCX Connector and AVS HCX Manager
- Network profiles for management, uplink, vMotion, and replication networks
- Compute profiles for migration workloads
- Service mesh configuration for workload mobility

## Prerequisites

### Azure Environment
- **Azure AD Tenant**: Access to Azure Active Directory tenant
- **Azure Subscription**: Active Azure subscription with appropriate permissions
- **Azure VMware Solution (AVS)**: Deployed SDDC with HCX Add-on enabled

### On-Premises Environment
- **VMware vCenter**: vCenter Server 6.7 or later
- **HCX Connector**: Deployed and configured HCX Connector appliance
  - If not deployed, follow the [HCX Connector deployment guide](https://github.com/Azure/Enterprise-Scale-for-AVS/blob/main/hcx/deployment/connector/README.md)
- **Network Segments**: Pre-configured network segments for:
  - Management network
  - Uplink network (or shared management/uplink)
  - vMotion network
  - Replication network

### Network Requirements
- **IP Address Ranges**: Available IP address ranges for each network profile
- **DNS Configuration**: Accessible DNS servers for name resolution
- **Firewall Rules**: Required ports open between on-premises and AVS as documented in [Azure VMware Solution HCX documentation](https://learn.microsoft.com/azure/azure-vmware/configure-vmware-hcx#prerequisites)
- **Bandwidth**: Recommended network bandwidth for migration traffic

### Authentication
- **HCX Connector Admin**: Administrative credentials for HCX Connector
- **Azure Permissions**: Contributor or equivalent permissions on AVS SDDC

## Deployment Steps

### Step 1: Configure Parameters

1. Navigate to the `hcx/deployment/servicemesh/scripts/` directory
2. Open `Main.parameters.ps1` and update the following parameters:

#### Azure Configuration
```powershell
$tenantId = "your-tenant-id"
$subscriptionId = "your-subscription-id"
$avsSddcName = "your-avs-sddc-name"
```

#### HCX Connector Configuration
```powershell
$hcxConnectorUserName = "administrator@your-domain.com"
$hcxConnectorServiceUrl = "https://your-hcx-ip-or-fqdn/"
$hcxConnectorMgmtUrl = "https://your-hcx-ip:9443/"
```

#### Network Profiles
Configure each network profile with appropriate values:

**Management Network:**
```powershell
$managementNetworkName = "OnPrem-management-1-1"
$managementNetworkStartIPAddress = "10.1.1.10"
$managementNetworkEndIPAddress = "10.1.1.16"
$managementNetworkGatewayIPAddress = "10.1.1.1"
$managementNetworkPrefixLength = 27
$managementNetworkDNSIPAddress = "1.1.1.1"
```

**Uplink Network:**
```powershell
$uplinkNetworkName = "OnPrem-uplink-1-1"
$uplinkNetworkStartIPAddress = "10.1.1.34"
$uplinkNetworkEndIPAddress = "10.1.1.40"
$uplinkNetworkGatewayIPAddress = "10.1.1.33"
$uplinkNetworkPrefixLength = 28
$uplinkNetworkDNSIPAddress = "1.1.1.1"
```

**vMotion Network:**
```powershell
$vmotionNetworkName = "OnPrem-vmotion-1-1"
$vmotionNetworkStartIPAddress = "10.1.1.74"
$vmotionNetworkEndIPAddress = "10.1.1.77"
$vmotionNetworkGatewayIPAddress = "10.1.1.65"
$vmotionNetworkPrefixLength = 27
$vmotionNetworkDNSIPAddress = "1.1.1.1"
```

**Replication Network:**
```powershell
$replicationNetworkName = "OnPrem-replication-1-1"
$replicationNetworkStartIPAddress = "10.1.1.106"
$replicationNetworkEndIPAddress = "10.1.1.109"
$replicationNetworkGatewayIPAddress = "10.1.1.97"
$replicationNetworkPrefixLength = 27
$replicationNetworkDNSIPAddress = "1.1.1.1"
```

#### Service Mesh Configuration
```powershell
$computeProfileName = "AVS-Migration-Compute-Profile"
$serviceMeshName = "AVS-Migration-Service-Mesh"
$useMgmtForUplinkInComputeProfile = $true
$useMgmtForUplinkInServiceMesh = $true
```

### Step 2: Execute Deployment Script

1. Open PowerShell as Administrator
2. Navigate to the script directory:
   ```powershell
   cd "c:\Enterprise-Scale-for-AVS-1\hcx\deployment\servicemesh\scripts\"
   ```
3. Execute the main deployment script:
   ```powershell
   .\Main.ps1
   ```
4. When prompted, enter the HCX Connector administrator password

### Step 3: Monitor Deployment Progress

The script will automatically:
- Authenticate to Azure and retrieve AVS HCX Manager details
- Create site pairing between on-premises HCX and AVS
- Create network profiles for all configured networks
- Create compute profile with specified networks
- Deploy HCX Service Mesh
- Verify deployment status which will look as shown below

```
cmdlet Main.ps1 at command pipeline position 1
Supply values for the following parameters:
hcxConnectorPassword: *********
Started Automated ServiceMesh creation...
Retrieving Azure tokens...
Retrieving AVS SDDC Details for 'XXXX-SDDC'
Checking for existing HCX pairing and creating new if it does not exists...
Found no HCX pairing with AVS HCX Manager. Creating a new pairing...
Created new Site Pairing 'hcx-cloud' successfully.
Checking for existing HCX Network Profiles and creating new if they do not exist...
Created 'management' HCX Network Profile successfully.
Created 'uplink' HCX Network Profile successfully.
Created 'replication' HCX Network Profile successfully.
Created 'vmotion' HCX Network Profile successfully.
Checking for existing HCX Compute Profile and creating new if it does not exist...
Waiting for Compute Profile creation to complete...
New HCX Compute Profile 'AVS-Migration-Compute-Profile' created successfully.
Checking for existing HCX Service Mesh and creating new if it does not exist...
Service Mesh creation task started...
Current Status: Initiated Service Mesh Deployment, next check in 1 minute...
Current Status: Deploying Interconnect Appliances., next check in 1 minute...
Current Status: Deploying Interconnect Appliances., next check in 1 minute...
Current Status: Deploying Interconnect Appliances., next check in 1 minute...
Current Status: Deploying Interconnect Appliances., next check in 1 minute...
New HCX Service Mesh 'AVS-Migration-Service-Mesh' created successfully.
Automated ServiceMesh creation completed successfully.
PS C:\Enterprise-Scale-for-AVS-1\hcx\deployment\servicemesh\scripts>
```

Monitor the console output for progress updates and any error messages.

## Post-deployment Steps

### Verify Deployment

1. **Check HCX Connector Dashboard**:
   - Log into HCX Connector at `https://your-hcx-ip-or-fqdn/`
   - Verify site pairing shows "Connected" status
   - Confirm network profiles are created
   - Confirm compute profile is created
   - Validate Service Mesh deployment

2. **Check AVS HCX Manager**:
   - Access AVS HCX Manager through vCenter
   - Verify incoming site pairing
   - Confirm Service Mesh status

3. **Test Connectivity**:
   - Verify network reachability between sites
   - Test vMotion connectivity
   - Validate replication network functionality

### Configure Additional Settings

1. **Network Extension** (if required):
   - Configure L2 network extension for specific VLANs
   - Set up network extension appliances

2. **Migration Policies**:
   - Configure migration scheduling policies
   - Set up resource allocation policies

3. **Monitoring and Alerting**:
   - Enable HCX monitoring
   - Configure alert notifications

## [Next Steps](../../README.md)

### Migration Planning
- **Assessment**: Use HCX assessment tools to analyze workloads
- **Migration Waves**: Plan migration in phases based on dependencies
- **Testing**: Perform test migrations with non-critical workloads

### Workload Migration
- **Bulk Migration**: Use HCX bulk migration for large-scale moves
- **vMotion**: Perform live migrations with zero downtime
- **Cold Migration**: Migrate powered-off VMs

### Optimization
- **Performance Tuning**: Optimize network and migration performance
- **Monitoring**: Implement comprehensive monitoring solution
- **Capacity Planning**: Plan for additional capacity requirements

### Security
- **Network Segmentation**: Implement proper network segmentation
- **Access Control**: Configure role-based access control
- **Compliance**: Ensure compliance with organizational policies
---

**Note**: This deployment creates the foundational HCX Service Mesh. Additional configuration may be required based on specific migration and disaster recovery requirements.