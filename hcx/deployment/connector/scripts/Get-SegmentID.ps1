
function Get-SegmentID {
    param (
            
            [string]$vCenter,
            [string]$vCenterUserName,
            [SecureString]$vCenterPassword,
            [string]$segmentName
        )
        
        # Create API Endpoint to get the Cluster ID
        $segmentUrl = [string]::Format(
            "{0}" +
            "api/vcenter/network",
            $vCenter
        )
        
        # Make the request
        $response = Invoke-APIRequest -method "Get" `
                                    -url $segmentUrl `
                                    -vCenter $vCenter `
                                    -vCenterUserName $vCenterUserName `
                                    -vCenterPassword $vCenterPassword
        
        if ($response) {
            return $response.Where({ $_.name -eq $segmentName }).network
        } else {
            Write-Error "Failed to get Segment ID."
            return $null
        }
    
}