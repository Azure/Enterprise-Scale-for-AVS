function Test-vSAN-StoragePolicy {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {
        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Get credentials
        $credentials = Get-AVS-Credentials -token $token -sddc $sddc

        # Define API endpoint for getting vSAN datastore
        $apiUrl = [string]::Format(
            "{0}" +
            "api/vcenter/datastore",
            $sddcDetails.vCenterUrl
        )

        # Make the request
        $response = Invoke-APIRequest -method "GET" `
                    -url $apiUrl `
                    -avsVcenter $sddcDetails.vCenterUrl `
                    -avsvCenterUserName $credentials.vCenterUsername `
                    -avsvCenterPassword $credentials.vCenterPassword

        # Check the response
        if ($response -and $response.type -eq "vsan") {
            # Define API endpoint for vSAN storage policy
            $datastoreStoragePolicyapiUrl = [string]::Format(
            "{0}api/vcenter/datastore/{1}/default-policy",
            $sddcDetails.vCenterUrl,
            $response.datastore
            )

            # Get the vSAN storage policy
            $datastoreStoragePolicy = Invoke-APIRequest -method "GET" `
                -url $datastoreStoragePolicyapiUrl `
                -avsVcenter $sddcDetails.vCenterUrl `
                -avsvCenterUserName $credentials.vCenterUsername `
                -avsvCenterPassword $credentials.vCenterPassword

            if ($datastoreStoragePolicy) {
            # Define API endpoint for all storage policies
            $allStoragePolicyapiUrl = [string]::Format(
                "{0}api/vcenter/storage/policies",
                $sddcDetails.vCenterUrl
            )

            # Get all storage policies
            $allStoragePolicyResponse = Invoke-APIRequest -method "GET" `
                    -url $allStoragePolicyapiUrl `
                    -avsVcenter $sddcDetails.vCenterUrl `
                    -avsvCenterUserName $credentials.vCenterUsername `
                    -avsvCenterPassword $credentials.vCenterPassword

            # Check the response
                $policy = $allStoragePolicyResponse | Where-Object { 
                    $_.policy -eq $datastoreStoragePolicy}
                    if ($policy.name -eq "RAID-1 FTT-1" -and 
                        $sddc.Properties.managementCluster.clusterSize -gt 3) 
                    {
                        $recommendationType = "vSANPolicyNotFTT2"
                    }
                }
        }

        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendationType)) {
            $Global:recommendations += Get-Recommendation -type $recommendationType `
                                                -sddcName $sddcDetails.sddcName
        }
    }
    catch {
        Write-Error "vSAN Storage Policy Test failed: $_"
    }
}