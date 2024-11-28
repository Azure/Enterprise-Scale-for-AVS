. ./New-Recommendation.ps1

function New-NSXT-Password-Rotation-Recommendation {
    param (
        [string]$sddcName
    )

    return New-Recommendation -Category "Identity" `
        -Observation "NSX-T Manager password has not been rotated in the last 90 days for SDDC '$sddcName'." `
        -Recommendation "Rotate the NSX-T Manager password." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/rotate-cloudadmin-credentials?tabs=azure-portal#reset-your-nsx-manager-credentials" `
        -Priority "High"
}

function New-vCenter-Password-Rotation-Recommendation {
    param (
        [string]$sddcName
    )

    return New-Recommendation -Category "Identity" `
        -Observation "vCenter Server password has not been rotated in the last 90 days for SDDC '$sddcName'." `
        -Recommendation "Rotate the vCenter Server password." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/rotate-cloudadmin-credentials?tabs=azure-portal#reset-your-vcenter-server-credentials" `
        -Priority "High"
}
function New-NoPIMLicense-Recommendation {
    
    return New-Recommendation -Category "Identity" `
        -Observation "Tenant doesn't have licenses needed for PIM." `
        -Recommendation "The tenant needs to have Microsoft Entra ID P2 or Microsoft Entra ID Governance license." `
        -LinkUrl "https://learn.microsoft.com/entra/id-governance/privileged-identity-management/groups-assign-member-owner" `
        -Priority "High"
}

function New-No-ActivePIMAccess-Recommendation {
    param (
        [string]$sddcName
    )   
    return New-Recommendation -Category "Identity" `
        -Observation "There is no eligible PIM access for AVS SDDC." `
        -Recommendation "SDDC '$sddcName' should have eligible PIM access." `
        -LinkUrl "https://learn.microsoft.com/entra/id-governance/privileged-identity-management/groups-assign-member-owner" `
        -Priority "Medium"
}

function New-NoExternalIdentitySource-Recommendation {
    param (
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Identity" `
        -Observation "SDDC '$sddcName' has no external identity source configured." `
        -Recommendation "Configure external identity source." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-identity-and-access-management" `
        -Priority "Medium"
}

function New-ExternalIdentitySource-Recommendation {
    param (
        [string]$sddcName,
        [string]$externalIdentitySource
    )
    
    return New-Recommendation -Category "Identity" `
        -Observation "SDDC '$sddcName' has '$externalIdentitySource' as an external identity source." `
        -Recommendation "Ensure BaseDNGroups and BaseDNUsers are configured with only those groups/users who need access to SDDC." `
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
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/configure-identity-source-vcenter" `
        -Priority "Low"
}
function New-NoGlobalReach-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' doesn't have active ExpressRoute GlobalReach connection." `
        -Recommendation "ExpressRoute GLobalReach is recommended for connectivity with on-premises environment." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/on-premises-connectivity" `
        -Priority "High"
}

function New-SingleGlobalReach-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' has only one active ExpressRoute GlobalReach connection." `
        -Recommendation "SDDC should have multiple ExpressRoute GlobalReach connections for resilient connectivity with on-premises environment." `
        -LinkUrl "https://learn.microsoft.com/azure/expressroute/design-architecture-for-resiliency" `
        -Priority "Medium"
}

function New-MultipleGlobalReach-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' has multiple active ExpressRoute GlobalReach connection." `
        -Recommendation "Use AS PATH Prepend when advertising routes from on-premises to avoid asymmetric routing." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/architecture-network-design-considerations" `
        -Priority "High"
}

function New-NoAuthKeyRedemption-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' has not redeemed any ER Auth Key." `
        -Recommendation "Use ER Auth Key Redemption for connectivity with Azure." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/tutorial-configure-networking" `
        -Priority "Low"
}

function New-MultipleAuthKeyRedemption-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' has multiple redemptions of ER Auth Key." `
        -Recommendation "Ensure multiple Auth Key redemptions do not cause IP address conflict." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/tutorial-configure-networking" `
        -Priority "Low"
}
function New-NoManagedSNAT-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' has no internet connectivity." `
        -Recommendation "Ensure default route is injected from either Azure or on-premises." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/network-design-guide-internet-outbound-connectivity" `
        -Priority "Low"
}
function New-ManagedSNAT-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is using AVS Managed SNAT for internet connectivity." `
        -Recommendation "AVS Managed SNAT is not a preferred solution for outbound to internet traffic for production workloads." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/network-design-guide-internet-outbound-connectivity" `
        -Priority "Medium"
}

function New-NSXTPIP-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is using public IP @ NSX-T edge for internet connectivity." `
        -Recommendation "Ensure that proper No-NAT, SNAT and DNAT rules are configured." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/enable-public-ip-nsx-edge" `
        -Priority "High"
}

function New-ZoneRedundantGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is conected to a zone-redundant ER gateway." `
        -Recommendation "Monitor network latency sensitive workloads for performance issues." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/virtual-network-connectivity" `
        -Priority "Low"
}
function New-NonZoneRedundantGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is conected to a non zone-redundant ER gateway." `
        -Recommendation "Connect AVS SDDC to zone-redundant ER gateway for resiliency." `
        -LinkUrl "https://learn.microsoft.com/azure/vpn-gateway/about-zone-redundant-vnet-gateways" `
        -Priority "High"
}

function New-FastPathGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is conected to a FastPath enabled ER gateway." `
        -Recommendation "Ensure that peered VNets and hub VNet are in same region." `
        -LinkUrl "https://learn.microsoft.com/azure/expressroute/about-fastpath" `
        -Priority "Low"
}
function New-NonFastPathGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is conected to a non-FastPath enabled ER gateway." `
        -Recommendation "Connect AVS SDDC to FastPath enabled ER gateway to improve data path performance." `
        -LinkUrl "https://learn.microsoft.com/azure/expressroute/about-fastpath" `
        -Priority "Medium"
}

function New-ZoneRedundantvWANGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is conected to a zone-redundant ER gateway in Azure vWAN." `
        -Recommendation "Monitor network latency sensitive workloads for performance issues." `
        -LinkUrl "https://learn.microsoft.com/azure/virtual-wan/virtual-wan-expressroute-about" `
        -Priority "Low"
}

function New-NonFastPathvWANGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is conected to a non-FastPath enabled ER gateway in Azure vWAN." `
        -Recommendation "Connect AVS SDDC to FastPath enabled ER gateway to improve data path performance." `
        -LinkUrl "https://learn.microsoft.com/azure/virtual-wan/virtual-wan-expressroute-about" `
        -Priority "Low"
}

function New-DefaultDNSZone-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is using default DNS Zone." `
        -Recommendation "Configure custom DNS Zone for SDDC." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/configure-dns-azure-vmware-solution" `
        -Priority "High"
}

function New-CustomDNSZone-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is using custom DNS Zone." `
        -Recommendation "Test DNS resolution is responding within acceptable timeframe." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/configure-dns-azure-vmware-solution" `
        -Priority "Low"
}

function New-NoDHCP-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is not using DHCP." `
        -Recommendation "Configure DHCP for SDDC." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/configure-dhcp-azure-vmware-solution" `
        -Priority "High"
}

function New-CustomDHCP-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Networking" `
        -Observation "SDDC '$sddcName' is using custom DHCP." `
        -Recommendation "Ensure DHCP is configured on AVS segments." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/configure-dhcp-azure-vmware-solution" `
        -Priority "Low"
}

function New-NoPIMLogs-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "Azure subscription containing SDDC '$sddcName' has no PIM logs." `
        -Recommendation "Ensure PIM logs are enabled on Azure subscription containing SDDC." `
        -LinkUrl "https://learn.microsoft.com/entra/id-governance/privileged-identity-management/groups-audit" `
        -Priority "Medium"
}

function New-NoEntraIDDiagnostics-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has no Entra ID diagnostics." `
        -Recommendation "Ensure Entra ID diagnostics are enabled for SDDC for long term storage requirements." `
        -LinkUrl "https://learn.microsoft.com/entra/identity/monitoring-health/howto-configure-diagnostic-settings" `
        -Priority "High"
}

function New-NoCustomUsers-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' is not configured with custom users for access." `
        -Recommendation "Ensure custom users are added to SDDC for role based access control." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/configure-identity-source-vcenter" `
        -Priority "High"
}

function New-NoCustomGroups-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' is not configured with custom groups for access." `
        -Recommendation "Ensure custom groups are added to SDDC for role based access control." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/configure-identity-source-vcenter" `
        -Priority "High"
}

function New-NoDomainJoin-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "A VM in SDDC '$sddcName' is not domain joined." `
        -Recommendation "Ensure that all VMs in SDDC are domain joined for centralized identity/policy management." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/configure-identity-source-vcenter" `
        -Priority "Medium"
}

function New-NoUserDefinedDistributedFirewall-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' is not configured with user defined NSX-T filtering." `
        -Recommendation "Ensure that NSX-T distributed firewall rules are defined for SDDC for security." `
        -LinkUrl "https://techcommunity.microsoft.com/blog/azuremigrationblog/firewall-integration-in-azure-vmware-solution/2254961" `
        -Priority "High"
}

function New-DisabledGatewayFirewall-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has at least one disabled gateway firewall." `
        -Recommendation "Ensure that gateway firewall is enabled for SDDC for security." `
        -LinkUrl "https://techcommunity.microsoft.com/blog/azuremigrationblog/firewall-integration-in-azure-vmware-solution/2254961" `
        -Priority "High"
}

function New-NoDDoSProtectionPlan-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' is connected to an Azure VNet which has no DDoS protection plan." `
        -Recommendation "Ensure that DDoS protection plan is enabled for the VNet connected with SDDC for security." `
        -LinkUrl "https://learn.microsoft.com/azure/ddos-protection/ddos-protection-overview" `
        -Priority "High"
}

function New-NovSANEncryption-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has no vSAN encryption." `
        -Recommendation "Ensure that vSAN encryption is enabled on SDDC for security." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/configure-customer-managed-keys?tabs=azure-portal" `
        -Priority "High"
}

function New-NoVMEncryption-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "A VM in SDDC '$sddcName' has no encryption." `
        -Recommendation "Ensure that VM encryption is enabled for VMs in SDDC for security." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/configure-customer-managed-keys?tabs=azure-portal" `
        -Priority "High"
}

function New-AccessControl-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has multiple Azure role assignments." `
        -Recommendation "Ensure that access control is limited to under 3 for direct and inherited scope for SDDC for security." `
        -LinkUrl "https://learn.microsoft.com/azure/role-based-access-control/best-practices" `
        -Priority "High"
}

function New-DisabledAlert-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has at least one disabled alert for critical metric." `
        -Recommendation "Ensure that alert for critical metric is enabled on SDDC for security." `
        -LinkUrl "https://azure.github.io/azure-monitor-baseline-alerts/patterns/specialized/avs/" `
        -Priority "High"
}

function New-NoRecipientForAlert-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has at least one alert with no recipient." `
        -Recommendation "Ensure that alert for critical metric has recipient for notification on SDDC for security." `
        -LinkUrl "https://azure.github.io/azure-monitor-baseline-alerts/patterns/specialized/avs/" `
        -Priority "High"
}

function New-MissingAlerts-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has missing alerts for critical metrics." `
        -Recommendation "Ensure that alerts are configured for critical metrics on SDDC for security." `
        -LinkUrl "https://azure.github.io/azure-monitor-baseline-alerts/patterns/specialized/avs/" `
        -Priority "High"
}

function New-NoAlerts-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "SDDC '$sddcName' has no alerts configured for critical metrics." `
        -Recommendation "Ensure that alerts are configured for critical metrics on SDDC for security." `
        -LinkUrl "https://azure.github.io/azure-monitor-baseline-alerts/patterns/specialized/avs/" `
        -Priority "High"
}

function New-ArcNotProvisioned-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Security" `
        -Observation "Azure Arc is not provisioned for SDDC '$sddcName'." `
        -Recommendation "Provision Azure Arc on SDDC for security patch and update management." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/deploy-arc-for-azure-vmware-solution?tabs=windows" `
        -Priority "Medium"
}

function New-vSANForContentLibrary-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Management" `
        -Observation "vSAN is used for Content Library in SDDC '$sddcName'." `
        -Recommendation "vSAN should be used for VM disks for efficient storage use." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-management-and-monitoring" `
        -Priority "High"
}

function New-NoAVSDiagnostics-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Management" `
        -Observation "AVS Diagnostic setting is not configured for SDDC '$sddcName'." `
        -Recommendation "Configure AVS Diagnostic setting for SDDC for monitoring and troubleshooting." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-management-and-monitoring" `
        -Priority "High"
}

function New-NoAVSSysLogDiagnostic-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Management" `
        -Observation "AVS Syslog Diagnostic setting is not configured for SDDC '$sddcName'." `
        -Recommendation "Configure AVS Syslog Diagnostic setting for SDDC for monitoring and troubleshooting." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-management-and-monitoring" `
        -Priority "High"
}

function New-vSANPolicyNotFTT2-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Management" `
        -Observation "vSAN policy for SDDC '$sddcName' is not set to FTT=2 for cluster size larger than 3." `
        -Recommendation "Ensure that vSAN policy is set to FTT=2 for cluster size larger than 3 for data resiliency." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-management-and-monitoring" `
        -Priority "High"
}

function New-SRMNotProvisioned-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "BCDR" `
        -Observation "SRM is not provisioned for SDDC '$sddcName'." `
        -Recommendation "Provision SRM on SDDC for disaster recovery." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-business-continuity-and-disaster-recovery" `
        -Priority "Medium"
}

function New-LowUtilizationforERGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "BCDR" `
        -Observation "ER Gateway for SDDC '$sddcName' has low utilization, which is an indicator for missing backup for guest VMs in SDDC." `
        -Recommendation "Configure backup for guest VMs in SDDC." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-business-continuity-and-disaster-recovery" `
        -Priority "Medium"
}

function New-LowUtilizationforvWANERGateway-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "BCDR" `
        -Observation "vWAN ER Gateway for SDDC '$sddcName' has low utilization, which is an indicator for missing backup for guest VMs in SDDC." `
        -Recommendation "Configure backup for guest VMs in SDDC." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-business-continuity-and-disaster-recovery" `
        -Priority "Medium"
}

function New-NoResourceLock-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Automation" `
        -Observation "SDDC '$sddcName' has no resource lock." `
        -Recommendation "Ensure that resource lock is configured for SDDC to prevent accidental deletion." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-platform-automation-and-devops" `
        -Priority "High"
}

function New-NoAutomatedDeployment-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Automation" `
        -Observation "SDDC '$sddcName' has no deployments using ARM or Bicep scripts." `
        -Recommendation "Automate SDDC changes/additions using consistent deployments." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-platform-automation-and-devops" `
        -Priority "Medium"
}

function New-NoServiveHealthAlert-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Management" `
        -Observation "SDDC '$sddcName' has no Service Health Alert configured." `
        -Recommendation "Ensure that Service Health Alert is configured for SDDC for monitoring." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-management-and-monitoring" `
        -Priority "High"
}

function New-DisabledServiveHealthAlert-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Management" `
        -Observation "SDDC '$sddcName' has at least one disabled Service Health Alert." `
        -Recommendation "Ensure that Service Health Alert is enabled for SDDC for monitoring." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-management-and-monitoring" `
        -Priority "High"
}

function New-NoRecipientForServiveHealthAlert-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Management" `
        -Observation "SDDC '$sddcName' has at least one Service Health Alert with no recipient." `
        -Recommendation "Ensure that Service Health Alert has recipient for notification on SDDC for monitoring." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-management-and-monitoring" `
        -Priority "High"
}

function New-ClusterCountNearLimit-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Management" `
        -Observation "SDDC '$sddcName' has cluster count near the limit of 16." `
        -Recommendation "Ensure that cluster count is within the limit of 16 for SDDC." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-management-and-monitoring" `
        -Priority "Medium"
}

function New-NodeCountNearLimit-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "Management" `
        -Observation "SDDC '$sddcName' has node count nearing the limit of 96." `
        -Recommendation "Ensure that node count is within the limit of 96 for SDDC." `
        -LinkUrl "https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/azure-vmware/eslz-management-and-monitoring" `
        -Priority "Medium"
}

function New-HCXNotProvisioned-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "HCX" `
        -Observation "HCX is not provisioned for SDDC '$sddcName'." `
        -Recommendation "Provision HCX on SDDC for workload mobility." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/configure-vmware-hcx" `
        -Priority "Medium"
}

function New-NoHCXNEHA-Recommendation {
    param(
        [string]$sddcName
    )
    
    return New-Recommendation -Category "HCX" `
        -Observation "SDDC '$sddcName' has no HCX Network Extension High Availability configured for at least one HCX Service Mesh." `
        -Recommendation "Ensure that HCX Network Extension High Availability is cofnigured on all HCX Service Meshes." `
        -LinkUrl "https://learn.microsoft.com/azure/azure-vmware/configure-hcx-network-extension-high-availability" `
        -Priority "High"
}