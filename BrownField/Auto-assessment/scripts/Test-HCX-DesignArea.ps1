. ./Test-HCX-Addon.ps1
. ./Test-HCX-NE-HA.ps1
function Test-HCX-DesignArea {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )
    try {
        # Test HCX Addon
        Write-Host "Testing HCX Addon"
        Test-HCX-Addon -token $token -sddc $sddc

        # Test HCX Network Extension HA
        Write-Host "Testing HCX Network Extension HA"
        Test-HCX-NE-HA -token $token -sddc $sddc
    }
    catch {
        Write-Error "Test HCX Design Area Failed: $_"
        return
    }
}