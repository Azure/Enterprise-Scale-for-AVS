. ./Get-AVS-Credentials.ps1
. ./Test-Identity-DesignArea.ps1
. ./Test-Networking-DesignArea.ps1
. ./Test-Security-DesignArea.ps1
. ./Test-Management-DesignArea.ps1
. ./Test-BCDR-DesignArea.ps1
. ./Test-Automation-DesignArea.ps1
. ./Test-HCX-DesignArea.ps1
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
        # Test Identity Design Area
        Write-Host "Testing Identity Design Area"
        Test-Identity-DesignArea -token $token -tenant $tenant -sddc $sddc

        # Test Networking Design Area
        Write-Host "Testing Networking Design Area"
        Test-Networking-DesignArea -token $token -graphToken $graphToken `
                -tenant $tenant -sddc $sddc `
                -allgatewayConnections $allgatewayConnections `
                -allvWANgateways $allvWANgateways

        # Test Security Design Area
        Write-Host "Testing Security Design Area"
        Test-Security-DesignArea -token $token -graphToken $graphToken `
                -tenant $tenant -sddc $sddc -avsVMcredentials $avsVMcredentials `
                -allgatewayConnections $allgatewayConnections

        # Test Management Design Area
        Write-Host "Testing Management Design Area"
        Test-Management-DesignArea -token $token -graphToken $graphToken `
                -tenant $tenant -sddc $sddc

        # Test BCDR Design Area
        Write-Host "Testing BCDR Design Area"
        Test-BCDR-DesignArea -token $token -graphToken $graphToken `
                -tenant $tenant -sddc $sddc

        # Test Automation Design Area
        Write-Host "Testing Automation Design Area"
        Test-Automation-DesignArea -token $token -graphToken $graphToken `
                -tenant $tenant -sddc $sddc
                
        # Test HCX Design Area
        Write-Host "Testing HCX Design Area"
        Test-HCX-DesignArea -token $token -sddc $sddc        

    }
    catch {
        Write-Error "Test All Design Areas Failed: $_"
        return
    }
}