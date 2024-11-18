. ./Test-PIM-Logs.ps1
. ./Test-EntraID-DiagSetting.ps1
. ./Test-ERGateway.ps1
. ./Test-Domainjoin.ps1
. ./Test-NSXT-DistributedFirewall.ps1
. ./Test-NSXT-GatewayFirewall.ps1
. ./Test-vSAN-encryption.ps1
. ./Test-AccessControl.ps1
. ./Test-Alerts.ps1
. ./Test-Arc.ps1
function Test-Security-DesignArea {
    param (
        [SecureString]$token,
        [SecureString]$graphToken,
        [string]$tenant,
        [PSCustomObject]$sddc,
        [PSCredential] $avsVMcredentials,
        [System.Object[]]$allgatewayConnections
    )
    try {
        # Test PIM Logs
        Write-Host "Testing PIM Logs"
        Test-PIM-Logs -graphToken $graphToken -sddc $sddc

        # Test EntraID Diagnostic Settings
        Write-Host "Testing EntraID Diagnostic Settings"
        Test-EntraID-DiagSetting -token $token

        #Test DDoS Protection
        Write-Host "Testing DDoS Protection"
        Test-ERGateway -token $token -sddc $sddc -allgatewayConnections $allgatewayConnections

        #Test Domain Join
        Write-Host "Testing Domain Join"
        Test-Domainjoin -token $token -sddc $sddc -avsVMcredentials $avsVMcredentials

        # Test NSXT Traffic Filtering
        Write-Host "Testing NSXT Traffic Filtering"
        Test-NSXT-DistributedFirewall -token $token -sddc $sddc

        # Test NSXT Gateway Firewall
        Write-Host "Testing NSXT Gateway Firewall"
        Test-NSXT-GatewayFirewall -token $token -sddc $sddc

        # Test vSAN Encryption
        Write-Host "Testing vSAN Encryption"
        Test-vSAN-encryption -sddc $sddc

        # Test Access Control
        Write-Host "Testing Azure Role Based Access Control"
        Test-AccessControl -token $token -sddc $sddc

        # Test Alerts
        Write-Host "Testing Alerts"
        Test-Alerts -token $token -sddc $sddc

        # Test Arc
        Write-Host "Testing Arc"
        Test-Arc -token $token -sddc $sddc
    }
    catch {
        Write-Error "Test Security Design Area Failed: $_"
        return
    }
}