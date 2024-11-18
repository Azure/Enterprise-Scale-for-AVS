. ./Test-ERGateway.ps1
. ./Test-vWAN-ERGateway.ps1
. ./Test-SRM.ps1
function Test-BCDR-DesignArea {
    param (
        [SecureString]$token,
        [SecureString]$graphToken,
        [string]$tenant,
        [PSCustomObject]$sddc,
        [System.Object[]]$allgatewayConnections,
        [System.Object[]]$allvWANgateways
    )
    try {
        # Test ER Gateway Backup
        Write-Host "Testing Backup over ER Gateway Connection"
        Test-ERGateway -token $token -sddc $sddc -allgatewayConnections $allgatewayConnections

        # Test vWAN Backup
        Write-Host "Testing Backup over vWAN Connection"
        Test-vWAN-ERGateway -token $token -sddc $sddc -allvWANgateways $allvWANgateways

        # Test SRM
        Write-Host "Testing SRM"
        Test-SRM -token $token -sddc $sddc
    }
    catch {
        Write-Error "Test BCDR Design Area Failed: $_"
        return
    }
}