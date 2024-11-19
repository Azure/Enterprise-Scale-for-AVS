function Test-NSXT-DistributedFirewall {
    param (
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {

        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Get the NSX-T credentials
        $credentials = Get-AVS-Credentials -token $token -sddc $sddc

        # Define the API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "policy/api/v1/ui/firewall/sections?resource_type=SecurityPolicy&" +
            "page_size=100&cursor=0&sort_by=internal_sequence_number,unique_id" +
            "&sort_ascending=true",
            $sddcDetails.nsxtUrl
        )

        # Define the body
        $body = @{
            primary = @{
                resource_type = "SecurityPolicy"
                filters = @(
                    @{
                        field_names = "!_exists_"
                        value = "_meta.is_vpc_context"
                    }
                )
            }
            related = @(
                @{
                    resource_type = "Domain"
                    join_condition = "path:parent_path"
                    alias = "domains"
                    size = 1
                },
                @{
                    resource_type = "Group"
                    join_condition = "path:scope"
                    alias = "sectionScopes"
                },
                @{
                    resource_type = "SecurityPolicyContainerCluster"
                    join_condition = "parent_path:path"
                    alias = "policyContainerClusters"
                },
                @{
                    resource_type = "ClusterControlPlane"
                    join_condition = "path:$2.container_cluster_path"
                    alias = "clusterControlPlaneAlias"
                },
                @{
                    resource_type = "ContainerCluster"
                    join_condition = "external_id:$3.node_id"
                    alias = "containerClusters"
                }
            )
            filters = @()
            predefined_filter = $null
        }

        $body = $body | ConvertTo-Json -Depth 10

        # Make the request
        $response = Invoke-APIRequest -method "POST" `
            -url $apiUrl `
            -avsnsxtUserName $credentials.nsxtUsername `
            -avsnsxtPassword $credentials.nsxtPassword `
            -body $body

        # Process the response
        if ($response -and $response.results -and $response.results.Count -gt 0) {
            $counter = ($response.results | Where-Object { $_.primary._last_modified_user -eq "system" }).Count

            if ($counter -eq $response.results.Count) {
            $recommendationType = "NoUserDefinedDistributedFirewall"
            }
        }
        
        # Add the recommendation
        if (![string]::IsNullOrEmpty($recommendationType)) {
            $Global:recommendations += Get-Recommendation -type $recommendationType `
                -sddcName $sddcDetails.sddcName
        }
    }
    catch {
        Write-Host "NSX-T Traffic Filtering Test failed: $_"
    }
}