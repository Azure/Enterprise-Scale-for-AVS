. ./Get-ERGateway-Connections.ps1
. ./Get-vWAN-ERGateways.ps1
. ./Test-All-DesignAreas.ps1
. ./Test-Identity-DesignArea.ps1
. ./Test-Networking-DesignArea.ps1
. ./Test-Security-DesignArea.ps1
. ./Test-Management-DesignArea.ps1
. ./Test-BCDR-DesignArea.ps1
. ./Test-Automation-DesignArea.ps1
. ./Test-HCX-DesignArea.ps1
function Test-AVS-SDDC {
    param (
        [SecureString]$token,
        [SecureString]$graphToken,
        [string]$tenant,
        [PSCustomObject]$sddc,
        [System.Object[]]$designAreasToTest,
        [PSCredential] $avsVMcredentials
    )
    try {
        # Check Design Areas To Test
        if ($designAreasToTest.Count -eq 0) {

            # Get the ER Gateway connections
            $allGatewayConnections = Get-ERGateway-Connections -token $secureToken -subscriptionId $subscriptionId
        
            # Get the vWAN ER Gateways
            $allvWANgateways = Get-vWAN-ERGateways -token $secureToken -subscriptionId $subscriptionId

            Test-All-DesignAreas -token $token `
                                -graphToken $graphToken `
                                -tenant $tenant `
                                -sddc $sddc `
                                -allgatewayConnections $allgatewayConnections `
                                -allvWANgateways $allvWANgateways `
                                -avsVMcredentials $avsVMcredentials
        } else {
            foreach ($designArea in $designAreasToTest) {
                Write-Host "Testing Design area $([array]::IndexOf(@($designAreasToTest), $designArea) + 1) out of $($designAreasToTest.Count): $($designArea)"
                switch ($designArea) {
                    "Identity" {
                        # Test Identity Design Area
                        Test-Identity-DesignArea -token $token -tenant $tenant -sddc $sddc
                        break
                    }
                    "Networking" {
                        # Get the ER Gateway connections
                        $allGatewayConnections = Get-ERGateway-Connections -token $secureToken -subscriptionId $subscriptionId
        
                        # Get the vWAN ER Gateways
                        $allvWANgateways = Get-vWAN-ERGateways -token $secureToken -subscriptionId $subscriptionId
                        
                        # Test Networking Design Area
                        Test-Networking-DesignArea -token $token -graphToken $graphToken `
                                -tenant $tenant -sddc $sddc `
                                -allgatewayConnections $allGatewayConnections `
                                -allvWANgateways $allvWANgateways
                        break
                    }
                    "Security" {
                        # Get the ER Gateway connections
                        $allGatewayConnections = Get-ERGateway-Connections -token $secureToken -subscriptionId $subscriptionId
        
                        # Test Security Design Area
                        Test-Security-DesignArea -token $token -graphToken $graphToken `
                                -tenant $tenant -sddc $sddc -avsVMcredentials $avsVMcredentials `
                                -allgatewayConnections $allGatewayConnections
                        break
                    }
                    "Management" {
                        # Test Management Design Area
                        Test-Management-DesignArea -token $token -sddc $sddc
                        break
                    }
                    "BCDR" {
                        # Get the ER Gateway connections
                        $allGatewayConnections = Get-ERGateway-Connections -token $secureToken -subscriptionId $subscriptionId
        
                        # Get the vWAN ER Gateways
                        $allvWANgateways = Get-vWAN-ERGateways -token $secureToken -subscriptionId $subscriptionId
                        
                        # Test BCDR Design Area
                        Test-BCDR-DesignArea -token $token -sddc $sddc `
                            -$allgatewayConnections $allGatewayConnections `
                            -allvWANgateways $allvWANgateways
                        break
                    }
                    "Automation" {
                        # Test Automation Design Area
                        Test-Automation-DesignArea -token $token -sddc $sddc
                        break
                    }
                    "HCX" {
                        # Test HCX Design Area
                        Test-HCX-DesignArea -token $token -sddc $sddc
                        break
                    }
                    default {
                        Write-Error "Invalid Design Area: $designArea"
                    }
                }
            }
        }

        
    }
    catch {
        Write-Error "Failed to test AVS SDDCs: $_"
        return
    }
}