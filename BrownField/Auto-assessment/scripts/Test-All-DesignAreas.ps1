. ./Get-AVS-Credentials.ps1
. ./Test-External-Identity-Source-Legacy.ps1
. ./Test-TenantElibility-For-PIM.ps1
. ./Test-PIM.ps1
. ./Test-NSXT-Password-Rotation.ps1
. ./Test-vCenter-Password-Rotation.ps1
. ./Test-GlobalReach.ps1
. ./Test-ERKeyRedemption.ps1
. ./Test-InternetConnectivity.ps1
. ./Test-ERGateway.ps1
. ./Test-vWAN-ERGateway.ps1
. ./Test-DNS.ps1
. ./Test-DHCP.ps1
. ./Test-PIM-Logs.ps1
. ./Test-EntraID-DiagSetting.ps1
. ./Test-Domainjoin.ps1
. ./Test-NSXT-DistributedFirewall.ps1
. ./Test-NSXT-GatewayFirewall.ps1
. ./Test-vSAN-encryption.ps1
. ./Test-AccessControl.ps1
. ./Test-Alerts.ps1
. ./Test-Arc.ps1
. ./Test-ContentLibrary.ps1
. ./Test-AVS-DiagSetting.ps1
. ./Test-vSAN-StoragePolicy.ps1
. ./Test-SRM.ps1
. ./Test-Resource-Lock.ps1
. ./Test-Deployment.ps1
. ./Test-ClusterNode-Size.ps1
function Test-All-DesignAreas {
    param (
        [SecureString]$token,
        [SecureString]$graphToken,
        [string]$tenant,
        [PSCustomObject]$sddc,
        [System.Object[]]$allgatewayConnections,
        [System.Object[]]$allvWANgateways,
        [PSCredential] $avsVMcredentials
    )
    try {

        #Test the external identity source
        Write-Host "Testing External Identity Source"
        Test-External-Identity-Source-Legacy -token $token -sddc $sddc

        #Test the Tenant eligibility for PIM
        #Test-TenantElibility-For-PIM -tenant $tenant

        #Test the PIM
        Write-Host "Testing Privileged Identity Management"
        Test-PIM -token $token -sddc $sddc                                           

        #Test the NSX-T password rotation
        Write-Host "Testing NSX-T Password Rotation"
        Test-NSXT-Password-Rotation -token $token -sddc $sddc

        #Test the vCenter password rotation
        Write-Host "Testing vCenter Password Rotation"
        Test-vCenter-Password-Rotation -token $token -sddc $sddc

        #Test Global Reach
        Write-Host "Testing Global Reach"
        Test-GlobalReach -token $token -sddc $sddc

        #Test ER Auth Key Redemption
        Write-Host "Testing ER Auth Key Redemption"
        Test-ERKeyRedemption -token $token -sddc $sddc

        #Test Internet Connectivity
        Write-Host "Testing Internet Connectivity"
        Test-InternetConnectivity -token $token -sddc $sddc

        #Test ER Gateway
        Write-Host "Testing ER Gateway Connections"
        Test-ERGateway -token $token -sddc $sddc -allgatewayConnections $allgatewayConnections

        #Test vWAN ER Gateway
        Write-Host "Testing vWAN Connections"
        Test-vWAN-ERGateway -token $token -sddc $sddc -allvWANgateways $allvWANgateways

        #Test DNS
        Write-Host "Testing DNS"
        Test-DNS -token $token -sddc $sddc

        # Test DHCP
        Write-Host "Testing DHCP"
        Test-DHCP -token $token -sddc $sddc

        # Test PIM Logs
        Write-Host "Testing PIM Logs"
        Test-PIM-Logs -graphToken $graphToken -sddc $sddc

        # Test EntraID Diagnostic Settings
        Write-Host "Testing EntraID Diagnostic Settings"
        Test-EntraID-DiagSetting -token $token

        #Test Domain Join
        Write-Host "Testing Domain Join"
        Test-Domainjoin -token $token -sddc $sddc

        # Test NSXT Traffic Filtering
        write-host "Testing NSXT Distributed Firewall"
        Test-NSXT-DistributedFirewall -token $token -sddc $sddc

        # Test NSXT Gateway Firewall
        write-host "Testing NSXT Gateway Firewall"
        Test-NSXT-GatewayFirewall -token $token -sddc $sddc

        # Test vSAN Encryption
        Write-Host "Testing vSAN Encryption"
        Test-vSAN-encryption -sddc $sddc

        # Test Access Control
        Write-Host "Testing Azure Role Based Access Control"
        Test-AccessControl -token $token -sddc $sddc

        # Test Metric Alerts
        Write-Host "Testing Metric Alerts"
        Test-Alerts -token $token -sddc $sddc

        # Test Service Health Alert
        Write-Host "Testing Service Health Alert"
        Test-ServiceHealth-Alert -token $token -sddc $sddc

        # Test Cluster and Node Counts
        Write-Host "Testing Cluster and Node Counts"
        Test-ClusterNode-Size -token $token -sddc $sddc

        # Test Arc
        Write-Host "Testing Arc"
        Test-Arc -token $token -sddc $sddc

        # Test Content Library
        Write-Host "Testing Content Library Storage"
        Test-ContentLibrary -token $token -sddc $sddc

        # Test AVS Diagnostic Settings
        Write-Host "Testing AVS Diagnostic Settings"
        Test-AVS-DiagSetting -token $token -sddc $sddc

        # Test vSAN Storage Policy
        Write-Host "Testing vSAN Storage Policy"
        Test-vSAN-StoragePolicy -token $token -sddc $sddc

        # Test SRM
        Write-Host "Testing SRM"
        Test-SRM -token $token -sddc $sddc

        # Test Resource Lock
        Write-Host "Testing Resource Lock"
        Test-Resource-Lock -token $token -sddc $sddc

        # Test Deployment
        Write-Host "Testing Automated Deployment"
        Test-Deployment -token $token -sddc $sddc
    }
    catch {
        Write-Error "Test All Design Areas Failed: $_"
        return
    }
}