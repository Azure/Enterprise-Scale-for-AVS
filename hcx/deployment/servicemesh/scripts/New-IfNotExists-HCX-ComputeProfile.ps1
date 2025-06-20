. .\Get-Resources.ps1
. .\Get-Interconnect-Task-Details.ps1
function New-IfNotExists-HCX-ComputeProfile {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword,
        [array]$hcxNetworkProfiles
    )

    try {
        Write-Host "Checking for existing HCX Compute Profile and creating new if it does not exist..."
        # Get existing Compute Profiles
        $computeProfile = Get-HCX-ComputeProfile -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -hcxConnectorUserName $hcxConnectorUserName `
            -hcxConnectorPassword $hcxConnectorPassword

        # Get first Compute Profile matching name
        $computeProfile = $computeProfile.items | Where-Object { $_.name -eq $computeProfileName } | Select-Object -First 1
        if ($computeProfile -and $computeProfile.computeProfileId) {
            Write-Host "HCX Compute Profile: '$($computeProfile.name)' already exists."
        }

        if ($null -eq $computeProfile) {
            # Create new Compute Profile
            $computeProfile = New-HCX-ComputeProfile -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
                -hcxConnectorUserName $hcxConnectorUserName `
                -hcxConnectorPassword $hcxConnectorPassword `
                -hcxNetworkProfiles $hcxNetworkProfiles `
                -useMgmtForUplinkInComputeProfile $useMgmtForUplinkInComputeProfile

            # Get Task details
            $taskDetails = Get-Interconnect-Task-Details -taskID $computeProfile.data.interconnectTaskId `
                -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
                -hcxConnectorUserName $hcxConnectorUserName `
                -hcxConnectorPassword $hcxConnectorPassword

            # Check while status is "RUNNING" or "QUEUED". Break if it is "SUCCESS" or "FAILED"
            while ($taskDetails.status -eq "RUNNING" -or $taskDetails.status -eq "QUEUED") {
                Write-Host "Waiting for Compute Profile creation to complete..."
                Start-Sleep -Seconds 10
                $taskDetails = Get-Interconnect-Task-Details -taskID $computeProfile.data.interconnectTaskId `
                    -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
                    -hcxConnectorUserName $hcxConnectorUserName `
                    -hcxConnectorPassword $hcxConnectorPassword
            }
            
            if ($taskDetails.status -eq "SUCCESS") {
                $computeProfile = Get-HCX-ComputeProfile -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
                -hcxConnectorUserName $hcxConnectorUserName `
                -hcxConnectorPassword $hcxConnectorPassword

                Write-Host "New HCX Compute Profile '$computeProfileName' created successfully."
                return $computeProfile

            } elseif ($taskDetails.status -eq "FAILED") {
                Write-Host "Compute Profile creation failed: $($taskDetails.errorMessage)"
                return $null
            }
        }

        return $computeProfile
    }
    catch {
        Write-Host "Error processing Compute Profiles: $_"
    }
}

function Get-HCX-ComputeProfile {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword
    )

    try {
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/interconnect/computeProfiles",
            $hcxConnectorServiceUrl
        )

        # Make the request
        $response = Invoke-API -method "GET" `
            -url $apiUrl `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -userName $hcxConnectorUserName `
            -password $hcxConnectorPassword `
            -AuthType "HCX"

        # Process the response
        if ($response -and $response.items.Count -gt 0) {
            return $response
        } else {
            return $null
        }
    }
    catch {
        Write-Error "Error retrieving Compute Profiles: $_"
    }
}

function Get-HCX-ComputeProfile-By-Endpoint {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword,
        [string]$endpointId
    )

    try {
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/interconnect/computeProfiles?endpointId={1}",
            $hcxConnectorServiceUrl,
            $endpointId
        )

        # Make the request
        $response = Invoke-API -method "GET" `
            -url $apiUrl `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -userName $hcxConnectorUserName `
            -password $hcxConnectorPassword `
            -AuthType "HCX"

        # Process the response
        if ($response) {
            return $response
        } else {
            return $null
        }
    }
    catch {
        Write-Error "Error retrieving Compute Profiles: $_"
    }
}
function New-HCX-ComputeProfile {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword,
        [array]$hcxNetworkProfiles,
        [bool]$useMgmtForUplinkInComputeProfile
    )

    try {
        # Get Pre-requisite data for Compute Profile
        $preReqData = Get-Consolidated-Data -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -hcxConnectorUserName $hcxConnectorUserName `
            -hcxConnectorPassword $hcxConnectorPassword
        if (-not $preReqData) {
            Write-Host "Failed to retrieve pre-requisite data for Compute Profile."
            return $false
        }
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/interconnect/computeProfiles",
            $hcxConnectorServiceUrl
        )

        # Define the body
       $body = @{
            deploymentContainer = @{
                compute = @(
                    @{
                        cmpId = $preReqData.vcenter_instanceId
                        id = $preReqData.vcenter_entity_id
                        type = "ClusterComputeResource"
                    }
                )
                storage = @(
                    @{
                        cmpId = $preReqData.vcenter_instanceId
                        id = $preReqData.datastore_id
                        type = "Datastore"
                    }
                )
            }
            name = $computeProfileName
            compute = @(
                @{
                    cmpId = $preReqData.vcenter_instanceId
                    id = $preReqData.datacenter_id
                    type = "datacenter"
                }
            )
            services = @(
                @{ name = "INTERCONNECT" }
                @{ name = "VMOTION" }
                @{ name = "BULK_MIGRATION" }
                @{ name = "RAV" }
                @{ name = "NETWORK_EXTENSION" }
                @{ name = "DISASTER_RECOVERY" }
            )              
            networks = @(
                @{
                    id = $hcxNetworkProfiles.mgmtProfileId
                    tags = if ($useMgmtForUplinkInComputeProfile) { 
                        @("management", "uplink") 
                    } else { 
                        [object[]]@("management")
                    }
                }
                if (-not $useMgmtForUplinkInComputeProfile) {
                    @{
                        id = $hcxNetworkProfiles.uplinkProfileId
                        tags = @("uplink")
                    }
                }
                @{
                    id = $hcxNetworkProfiles.vmotionProfileId
                    tags = @("vmotion")
                }
                @{
                    id = $hcxNetworkProfiles.replicationProfileId
                    tags = @("replication")
                }
            )
            switches = @(
                @{
                    cmpId  = "bfa1012e-f7df-4053-a268-12c743b08801"
                    id     = $preReqData.dvs_id
                    type   = "VmwareDistributedVirtualSwitch"
                }
            )        }
 
        $jsonBody = $body | ConvertTo-Json -Depth 10
        
        # Fix the single-element array issue for management tags
        if (-not $useMgmtForUplinkInComputeProfile) {
            $jsonBody = $jsonBody -replace '"tags": "management"', '"tags": ["management"]'
        }

        # Make the request to create a new Compute Profile
        $response = Invoke-API -method "POST" `
            -url $apiUrl `
            -body $jsonBody `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -userName $hcxConnectorUserName `
            -password $hcxConnectorPassword `
            -AuthType "HCX"

        if ($response -and $response.data.interconnectTaskId) {
            return $response
        } else {
            return $null
        }
    }
    catch {
        Write-Host "Error creating HCX Compute Profile: $_"
    }
}
function Get-NetworkProfileIDs {
    param (
        [array]$hcxNetworkProfiles
    )

    # Extract network profile IDs from the provided network profiles and return objectId as the ID
    return @{
        mgmtProfileId = ($hcxNetworkProfiles | Where-Object `
            { $_.name -like "*management*" -or $_.recommendationTags -contains "management" } | `
            Select-Object -First 1)?.objectId
        uplinkProfileId = ($hcxNetworkProfiles | Where-Object `
            { $_.name -like "*uplink*" -or $_.recommendationTags -contains "uplink" } | `
            Select-Object -First 1)?.objectId
        vmotionProfileId = ($hcxNetworkProfiles | Where-Object `
            { $_.name -like "*vmotion*" -or $_.recommendationTags -contains "vmotion" } | `
            Select-Object -First 1)?.objectId
        replicationProfileId = ($hcxNetworkProfiles | Where-Object `
            { $_.name -like "*replication*" -or $_.recommendationTags -contains "replication" } | `
            Select-Object -First 1)?.objectId
    }
}