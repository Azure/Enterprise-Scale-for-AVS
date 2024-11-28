. ./Test-HCX-Addon.ps1
. ./Test-HCX-NE-HA.ps1
. ./Test-HCX-StretchedVLANs.ps1
function Test-HCX-DesignArea {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )
    try {
        # Test HCX Addon
        Write-Host "Testing HCX Addon"
        $hcxStatus = Test-HCX-Addon -token $token -sddc $sddc

        if ($hcxStatus -and $hcxStatus -eq "HCXProvisioned") {
            # Test HCX Network Extension HA
            Write-Host "Testing HCX Network Extension HA"
            Test-HCX-NE-HA -token $token -sddc $sddc

            # Test HCX Stretched VLANs
            Write-Host "Testing HCX Stretched VLANs"
            Test-HCX-StretchedVLANs -token $token -sddc $sddc
        }
        
    }
    catch {
        Write-Error "Test HCX Design Area Failed: $_"
        return
    }
}