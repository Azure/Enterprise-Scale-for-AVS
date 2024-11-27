. ./Test-HCX-NE-HA.ps1
function Test-HCX-DesignArea {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )
    try {
        # Test vSAN Storage Policy
        Write-Host "Testing HCX Network Extension HA"
        Test-HCX-NE-HA -token $token -sddc $sddc
    }
    catch {
        Write-Error "Test HCX Design Area Failed: $_"
        return
    }
}