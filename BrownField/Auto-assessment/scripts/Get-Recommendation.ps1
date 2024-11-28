. .\All-Recommendations.ps1

function Get-Recommendation {
    param (
        [string]$type,
        [string]$sddcName,
        [string]$externalIdentitySource = "",
        [string]$ldapServer = ""
    )

    switch ($type) {
        "NSXTPasswordRotation" { return New-NSXT-Password-Rotation-Recommendation -sddcName $sddcName }
        "vCenterPasswordRotation" { return New-vCenter-Password-Rotation-Recommendation -sddcName $sddcName }
        "NoPIMLicense" { return New-NoPIMLicense-Recommendation }
        "NoActivePIMRequests" { return New-No-ActivePIMAccess-Recommendation -sddcName $sddcName }
        "NoExternalIdentitySource" { return New-NoExternalIdentitySource-Recommendation -sddcName $sddcName }
        "ExternalIdentitySource" { return New-ExternalIdentitySource-Recommendation -sddcName $sddcName -externalIdentitySource $externalIdentitySource }
        "LDAPIdentitySource" { return New-LDAPIdentitySource-Recommendation -sddcName $sddcName -ldapServer $ldapServer }
        "LDAPSIdentitySource" { return New-LDAPSIdentitySource-Recommendation -sddcName $sddcName -ldapServer $ldapServer }
        "NoGlobalReachConnections" { return New-NoGlobalReach-Recommendation -sddcName $sddcName }
        "SingleGlobalReachConnection" { return New-SingleGlobalReach-Recommendation -sddcName $sddcName }
        "MultipleGlobalReachConnections" { return New-MultipleGlobalReach-Recommendation -sddcName $sddcName }
        "NoERAuthKeyRedemption" { return New-NoAuthKeyRedemption-Recommendation -sddcName $sddcName }
        "MultipleERAuthKeyRedemptions" { return New-MultipleAuthKeyRedemption-Recommendation -sddcName $sddcName }
        "NoManagedSNAT" { return New-NoManagedSNAT-Recommendation -sddcName $sddcName }
        "ManagedSNAT" { return New-ManagedSNAT-Recommendation -sddcName $sddcName }
        "NSXTPIP" { return New-NSXTPIP-Recommendation -sddcName $sddcName }
        "NonZoneRedundantGateway" { return New-NonZoneRedundantGateway-Recommendation -sddcName $sddcName }
        "NonFastPathGateway" { return New-NonFastPathGateway-Recommendation -sddcName $sddcName }
        "FastPathGateway" { return New-FastPathGateway-Recommendation -sddcName $sddcName }
        "ZoneRedundantGateway" { return New-ZoneRedundantGateway-Recommendation -sddcName $sddcName }
        "NonFastPathvWANGateway" { return New-NonFastPathvWANGateway-Recommendation -sddcName $sddcName }
        "ZoneRedundantvWANGateway" { return New-ZoneRedundantvWANGateway-Recommendation -sddcName $sddcName }
        "DefaultDNSZone" { return New-DefaultDNSZone-Recommendation -sddcName $sddcName }
        "CustomDNSZone" { return New-CustomDNSZone-Recommendation -sddcName $sddcName }
        "NoDHCP" { return New-NoDHCP-Recommendation -sddcName $sddcName }
        "CustomDHCP" { return New-CustomDHCP-Recommendation -sddcName $sddcName }
        "NoPIMLogs" { return New-NoPIMLogs-Recommendation -sddcName $sddcName }
        "NoEntraIDDiagnostics" { return New-NoEntraIDDiagnostics-Recommendation -sddcName $sddcName }
        "NoCustomUsers" { return New-NoCustomUsers-Recommendation -sddcName $sddcName }
        "NoCustomGroups" { return New-NoCustomGroups-Recommendation -sddcName $sddcName }
        "NoDomainJoin" { return New-NoDomainJoin-Recommendation -sddcName $sddcName }
        "NoUserDefinedDistributedFirewall" { return New-NoUserDefinedDistributedFirewall-Recommendation -sddcName $sddcName }
        "DisabledGatewayFirewall" { return New-DisabledGatewayFirewall-Recommendation -sddcName $sddcName }
        "NoDDoSProtectionPlan" { return New-NoDDoSProtectionPlan-Recommendation -sddcName $sddcName }
        "NovSANEncryption" { return New-NovSANEncryption-Recommendation -sddcName $sddcName }
        "NoVMEncryption" { return New-NoVMEncryption-Recommendation -sddcName $sddcName }
        "AccessControl" { return New-AccessControl-Recommendation -sddcName $sddcName }
        "DisabledAlert" { return New-DisabledAlert-Recommendation -sddcName $sddcName }
        "NoRecipientForAlert" { return New-NoRecipientForAlert-Recommendation -sddcName $sddcName }
        "MissingAlerts" { return New-MissingAlerts-Recommendation -sddcName $sddcName }
        "NoAlerts" { return New-NoAlerts-Recommendation -sddcName $sddcName }
        "ArcNotProvisioned" { return New-ArcNotProvisioned-Recommendation -sddcName $sddcName }
        "vSANForContentLibrary" { return New-vSANForContentLibrary-Recommendation -sddcName $sddcName }
        "NoAVSDiagnostics" { return New-NoAVSDiagnostics-Recommendation -sddcName $sddcName }
        "NoAVSSysLogDiagnostic" { return New-NoAVSSysLogDiagnostic-Recommendation -sddcName $sddcName }
        "vSANPolicyNotFTT2" { return New-vSANPolicyNotFTT2-Recommendation -sddcName $sddcName }
        "SRMNotProvisioned" { return New-SRMNotProvisioned-Recommendation -sddcName $sddcName }
        "LowUtilizationforERGateway" { return New-LowUtilizationforERGateway-Recommendation -sddcName $sddcName }
        "LowUtilizationforvWANERGateway" { return New-LowUtilizationforvWANERGateway-Recommendation -sddcName $sddcName }
        "NoResourceLock" { return New-NoResourceLock-Recommendation -sddcName $sddcName }
        "NoAutomatedDeployment" { return New-NoAutomatedDeployment-Recommendation -sddcName $sddcName }
        "NoServiveHealthAlert" { return New-NoServiveHealthAlert-Recommendation -sddcName $sddcName }
        "DisabledServiveHealthAlert" { return New-DisabledServiveHealthAlert-Recommendation -sddcName $sddcName }
        "NoRecipientForServiveHealthAlert" { return New-NoRecipientForServiveHealthAlert-Recommendation -sddcName $sddcName }
        "ClusterCountNearLimit" { return New-ClusterCountNearLimit-Recommendation -sddcName $sddcName }
        "NodeCountNearLimit" { return New-NodeCountNearLimit-Recommendation -sddcName $sddcName }
        "HCXNotProvisioned" { return New-HCXNotProvisioned-Recommendation -sddcName $sddcName }
        default { throw "Unknown recommendation type: $type" }
    }
}