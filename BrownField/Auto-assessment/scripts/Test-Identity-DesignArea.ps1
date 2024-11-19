. ./Test-External-Identity-Source-Legacy.ps1
. ./Test-TenantElibility-For-PIM.ps1
. ./Test-PIM.ps1
. ./Test-NSXT-Password-Rotation.ps1
. ./Test-vCenter-Password-Rotation.ps1
function Test-Identity-DesignArea {
    param (
        [SecureString]$token,
        [string]$tenant,
        [PSCustomObject]$sddc
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
    }
    catch {
        Write-Error "Test Identity Design Area Failed: $_"
        return
    }
}