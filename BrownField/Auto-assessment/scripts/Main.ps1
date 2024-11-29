. ./Install-ifNotExist-RequiredModules.ps1
. ./New-IfNotExist-AzureToken.ps1
. ./Invoke-APIRequest.ps1
. ./Get-AVS-SDDCs.ps1
. ./Test-AVS-SDDC.ps1
. ./Get-Tokens.ps1
. ./Export-RecommendationsToCSV.ps1
function Main {
    try {
        
        $tenantId = ""
        $subscriptionId = ""
        
        # Provide the names of the SDDCs to test
        # If the array is empty, all SDDCs in the subscription will be tested
        # Example: $namesofSddcsToTest = @()
        # If you want to test specific SDDCs, provide the names in comma-separated format
        # Example: $namesofSddcsToTest = @("prod-sddc", "uat-sddc")
        $namesofSddcsToTest = @()

        # Provide the design areas to test
        # If the array is empty, all design areas will be tested
        # Example: $designAreasToTest = @()
        # If you want to test specific design areas, provide the names in comma-separated format
        # Example: $designAreasToTest = @("Security", "Networking")
        # Possible values: "Identity", "Networking", "Security", "Management", "BCDR", "Automation", "HCX"
        $designAreasToTest = @()

        # Initialize the recommendations array. Leave this as is.
        $Global:recommendations = @()

        if ($tenantId -eq "" -or $subscriptionId -eq "") {
            Write-Error "Please provide the tenantId and subscriptionId values."
            return
        }

        # Check and install required modules
        Install-IfNotExist-RequiredModules

        # Get the tokens
        $tokens = Get-Tokens -TenantID $tenantId -SubscriptionID $subscriptionId

        if ($null -eq $tokens) {
            Write-Error "Failed to authenticate. Exiting script."
            return
        }

        $secureToken = $tokens.secureToken
        $secureGraphToken = $tokens.secureGraphToken
        
        # Provide a user dialog for the VM credentials
        if ($designAreasToTest.Count -eq 0 -or $designAreasToTest -contains "Security") {
            $avsVMcredentials = Get-Credential `
                -Message ([string]::Format("Please enter username and password for AVS guest VM. " +
                "This will be used to test Domain join"))
        }
        
        # Get the AVS SDDCs
        $sddcsToTest = Get-AVS-SDDCs -token $secureToken `
                            -subscriptionId $subscriptionId `
                            -namesofSddcsToTest $namesofSddcsToTest
        
        # Process each of the SDDCs
        foreach ($sddc in $sddcsToTest) {
            # Refresh the Token if it is about to expire
            $token = New-IfNotExist-AzureToken -tenantId $tenantId `
                        -subscriptionId $subscriptionId `
                        -token $tokens.Token

            Write-Host "Testing SDDC $([array]::IndexOf(@($sddcsToTest), $sddc) + 1) out of $($sddcsToTest.Count): $($sddc.name)"
            
            Test-AVS-SDDC -token $token.Token `
                    -graphToken $secureGraphToken `
                    -tenant $tenantId `
                    -sddc $sddc `
                    -designAreasToTest $designAreasToTest `
                    -avsVMcredentials $avsVMcredentials
            
        }

        # Export the recommendations to a CSV file
        Export-RecommendationsToCSV -recommendations $Global:recommendations `
                -designAreasToTest $designAreasToTest

        Write-Host "Script execution completed successfully!"
    }
    catch {
        Write-Error "Script execution failed! $_"
        return
    }
}

Main
