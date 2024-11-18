. ./New-Recommendation.ps1

function New-NSXT-Password-Rotation-Recommendation {
    param (
        [string]$sddcName
    )

    return New-Recommendation -Category "Identity" `
        -Observation "NSX-T Manager password has not been rotated in the last 90 days for SDDC '$sddcName'." `
        -Recommendation "Rotate the NSX-T Manager password." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-vCenter-Password-Rotation-Recommendation {
    param (
        [string]$sddcName
    )

    return New-Recommendation -Category "Identity" `
        -Observation "vCenter Server password has not been rotated in the last 90 days for SDDC '$sddcName'." `
        -Recommendation "Rotate the vCenter Server password." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}
function New-NoPIMLicense-Recommendation {
    
    return New-Recommendation -Category "Identity" `
        -Observation "Tenant doesn't have licenses needed for PIM." `
        -Recommendation "The tenant needs to have Microsoft Entra ID P2 or Microsoft Entra ID Governance license." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-No-ActivePIMAccess-Recommendation {
    param (
        [string]$sddcName
    )   
    return New-Recommendation -Category "Identity" `
        -Observation "There is no eligible PIM access for AVS SDDC." `
        -Recommendation "SDDC '$sddcName' should have eligible PIM access." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NoExternalIdentitySource-Recommendation {
    param (
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Identity" `
        -Observation "SDDC '$sddcName' has no external identity source configured." `
        -Recommendation "Configure external identity source." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-ExternalIdentitySource-Recommendation {
    param (
        [string]$sddcName,
        [string]$externalIdentitySource
    )
    
    return New-Recommendation -Category "Identity" `
        -Observation "SDDC '$sddcName' has '$externalIdentitySource' as an external identity source." `
        -Recommendation "Ensure BaseDNGroups and BaseDNUsers are configured with only those groups/users who need access to SDDC." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "Low"
}

function New-LDAPIdentitySource-Recommendation {
    param (
        [string]$sddcName,
        [string]$ldapServer
    )
    
    return New-Recommendation -Category "Identity" `
        -Observation "SDDC '$sddcName' has '$ldapServer' as an LDAP identity source." `
        -Recommendation "Configure Identity Source to use LDAPS" `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-LDAPSIdentitySource-Recommendation {
    param (
        [string]$sddcName,
        [string]$ldapServer
    )
    
    return New-Recommendation -Category "Identity" `
        -Observation "SDDC '$sddcName' has '$ldapServer' as an LDAPS identity source." `
        -Recommendation "Ensure you check and renew LDAPS certificate before expiry." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "Low"
}
function New-NoGlobalReach-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' doesn't have active ExpressRoute GlobalReach connection." `
        -Recommendation "ExpressRoute GLobalReach is recommended for connectivity with on-premises environment." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-SingleGlobalReach-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' has only one active ExpressRoute GlobalReach connection." `
        -Recommendation "SDDC should have multiple ExpressRoute GLobalReach connections for resilient connectivity with on-premises environment." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-MultipleGlobalReach-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' has multiple active ExpressRoute GlobalReach connection." `
        -Recommendation "Use AS PATH Prepend when advertising routes from on-premises to avoid asymmetric routing." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NoAuthKeyRedemption-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' has not redeemed any ER Auth Key." `
        -Recommendation "Use ER Auth Key Redemption for connectivity with Azure." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-MultipleAuthKeyRedemption-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' has multiple redemptions of ER Auth Key." `
        -Recommendation "Ensure multiple Auth Key redemptions do not cause IP address conflict." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}
function New-NoManagedSNAT-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' has no internet connectivity." `
        -Recommendation "Ensure default route is injected from either Azure or on-premises." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}
function New-ManagedSNAT-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is using AVS Managed SNAT for internet connectivity." `
        -Recommendation "AVS Managed SNAT is not a preferred solution for outbound to internet traffic for production workloads." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NSXTPIP-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is using public IP @ NSX-T edge for internet connectivity." `
        -Recommendation "Ensure that proper No-NAT, SNAT and DNAT rules are configured." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-ZoneRedundantGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is conected to a zone-redundant ER gateway." `
        -Recommendation "Monitor network latency sensitive workloads for performance issues." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "Low"
}
function New-NonZoneRedundantGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is conected to a non zone-redundant ER gateway." `
        -Recommendation "Connect AVS SDDC to zone-redundant ER gateway for resiliency." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-FastPathGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is conected to a FastPath enabled ER gateway." `
        -Recommendation "Ensure that peered VNets and hub VNet are in same region." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "Low"
}
function New-NonFastPathGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is conected to a non-FastPath enabled ER gateway." `
        -Recommendation "Connect AVS SDDC to FastPath enabled ER gateway to improve data path performance." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-ZoneRedundantvWANGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is conected to a zone-redundant ER gateway in Azure vWAN." `
        -Recommendation "Monitor network latency sensitive workloads for performance issues." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "Low"
}

function New-NonFastPathvWANGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is conected to a non-FastPath enabled ER gateway in Azure vWAN." `
        -Recommendation "Connect AVS SDDC to FastPath enabled ER gateway to improve data path performance." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-DefaultDNSZone-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is using default DNS Zone." `
        -Recommendation "Configure custom DNS Zone for SDDC." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-CustomDNSZone-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is using custom DNS Zone." `
        -Recommendation "Test DNS resolution is responding within acceptable timeframe." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "Low"
}

function New-NoDHCP-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is not using DHCP." `
        -Recommendation "Configure DHCP for SDDC." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-CustomDHCP-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is using custom DHCP." `
        -Recommendation "Ensure DHCP is configured on AVS segments." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "Low"
}

function New-NoPIMLogs-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has no PIM logs." `
        -Recommendation "Ensure PIM logs are enabled for SDDC." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NoEntraIDDiagnostics-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has no Entra ID diagnostics." `
        -Recommendation "Ensure Entra ID diagnostics are enabled for SDDC for long term storage requirements." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NoCustomUsers-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' is not configured with custom users for access." `
        -Recommendation "Ensure custom users are added to SDDC for role based access control." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NoCustomGroups-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' is not configured with custom groups for access." `
        -Recommendation "Ensure custom groups are added to SDDC for role based access control." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NoDomainJoin-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "A VM in SDDC '$sddcName' is not domain joined." `
        -Recommendation "Ensure that all VMs in SDDC are domain joined for centralized identity/policy management." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NoUserDefinedDistributedFirewall-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' is not configured with user defined NSX-T filtering." `
        -Recommendation "Ensure that NSX-T distributed firewall rules are defined for SDDC for security." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-DisabledGatewayFirewall-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has at least one disabled gateway firewall." `
        -Recommendation "Ensure that gateway firewall is enabled for SDDC for security." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NoDDoSProtectionPlan-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' is connected to an Azure VNet which has no DDoS protection plan." `
        -Recommendation "Ensure that DDoS protection plan is enabled for the VNet connected with SDDC for security." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NovSANEncryption-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has no vSAN encryption." `
        -Recommendation "Ensure that vSAN encryption is enabled on SDDC for security." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NoVMEncryption-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "A VM in SDDC '$sddcName' has no encryption." `
        -Recommendation "Ensure that VM encryption is enabled for VMs in SDDC for security." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-AccessControl-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has multiple Azure role assignments." `
        -Recommendation "Ensure that access control is limited to under 2 for direct and inherited scope for SDDC for security." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-DisabledAlert-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has at least one disabled alert for critical metric." `
        -Recommendation "Ensure that alert for critical metric is enabled on SDDC for security." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NoRecipientForAlert-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has at least one alert with no recipient." `
        -Recommendation "Ensure that alert for critical metric has recipient for notification on SDDC for security." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-MissingAlerts-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has missing alerts for critical metrics." `
        -Recommendation "Ensure that alerts are configured for critical metrics on SDDC for security." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NoAlerts-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has no alerts configured for critical metrics." `
        -Recommendation "Ensure that alerts are configured for critical metrics on SDDC for security." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-ArcNotProvisioned-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "Azure Arc is not provisioned for SDDC '$sddcName'." `
        -Recommendation "Provision Azure Arc on SDDC for security patch and update management." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-vSANForContentLibrary-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Management" `
        -Observation "vSAN is used for Content Library in SDDC '$sddcName'." `
        -Recommendation "vSAN should be used for VM disks for efficient storage use." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NoAVSDiagnostics-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Management" `
        -Observation "AVS Diagnostic setting is not configured for SDDC '$sddcName'." `
        -Recommendation "Configure AVS Diagnostic setting for SDDC for monitoring and troubleshooting." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NoAVSSysLogDiagnostic-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Management" `
        -Observation "AVS Syslog Diagnostic setting is not configured for SDDC '$sddcName'." `
        -Recommendation "Configure AVS Syslog Diagnostic setting for SDDC for monitoring and troubleshooting." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-vSANPolicyNotFTT2-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Management" `
        -Observation "vSAN policy for SDDC '$sddcName' is not set to FTT=2 for cluster size larger than 3." `
        -Recommendation "Ensure that vSAN policy is set to FTT=2 for cluster size larger than 3 for data resiliency." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-SRMNotProvisioned-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "BCDR" `
        -Observation "SRM is not provisioned for SDDC '$sddcName'." `
        -Recommendation "Provision SRM on SDDC for disaster recovery." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-LowUtilizationforERGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "BCDR" `
        -Observation "ER Gateway for SDDC '$sddcName' has low utilization, which is an indicator for missing backup for guest VMs in SDDC." `
        -Recommendation "Configure backup for guest VMs in SDDC." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "Medium"
}

function New-LowUtilizationforvWANERGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "BCDR" `
        -Observation "vWAN ER Gateway for SDDC '$sddcName' has low utilization, which is an indicator for missing backup for guest VMs in SDDC." `
        -Recommendation "Configure backup for guest VMs in SDDC." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "Medium"
}

function New-NoResourceLock-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Automation" `
        -Observation "SDDC '$sddcName' has no resource lock." `
        -Recommendation "Ensure that resource lock is configured for SDDC to prevent accidental deletion." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}

function New-NoAutomatedDeployment-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Automation" `
        -Observation "SDDC '$sddcName' has no deployments using ARM or Bicep scripts." `
        -Recommendation "Automate SDDC changes/additions using consistent deployments." `
        -LinkText "TBD" `
        -LinkUrl "https://docs.microsoft.com/en-us/azure/azure-vmware/overview" `
        -Priority "High"
}