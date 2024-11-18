. ./Test-Resource-Lock.ps1
. ./Test-Deployment.ps1
function Test-Automation-DesignArea {
    param (
        [SecureString]$token,
        [SecureString]$graphToken,
        [string]$tenant,
        [PSCustomObject]$sddc
    )

    try {
        # Test Resource Lock
        Write-Host "Testing Resource Lock"
        Test-Resource-Lock -token $token -sddc $sddc

        # Test Automated Deployment
        Write-Host "Testing Automated Deployment"
        Test-Deployment -token $token -sddc $sddc
    }
    catch {
        Write-Error "Test Automation Design Area Failed: $_"
        return
    }
}