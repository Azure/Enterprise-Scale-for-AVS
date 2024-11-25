. ./Test-ContentLibrary.ps1
. ./Test-AVS-DiagSetting.ps1
. ./Test-vSAN-StoragePolicy.ps1
. ./Test-SRM.ps1
. ./Test-ServiceHealthAlert.ps1
function Test-Management-DesignArea {
    param (
        [SecureString]$token,
        [SecureString]$graphToken,
        [string]$tenant,
        [PSCustomObject]$sddc
    )
    try {
        # Test Service Health Alert
        Write-Host "Testing Service Health Alert"
        Test-ServiceHealth-Alert -token $token -sddc $sddc

        # Test Content Library
        Write-Host "Testing Content Library Storage"
        Test-ContentLibrary -token $token -sddc $sddc

        # Test AVS Diagnostic Settings
        Write-Host "Testing AVS Diagnostic Settings"
        Test-AVS-DiagSetting -token $token -sddc $sddc

        # Test vSAN Storage Policy
        Write-Host "Testing vSAN Storage Policy"
        Test-vSAN-StoragePolicy -token $token -sddc $sddc
    }
    catch {
        Write-Error "Test Management Design Area Failed: $_"
        return
    }
}