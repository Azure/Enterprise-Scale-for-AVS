function Get-AVS-VMs {
    param (
        [string]$avsVcenter,
        [string]$avsvCenteruserName,
        [SecureString]$avsvCenterpassword
    )

    # Define the URL for getting AVS VMs
    $url = "$avsVcenter/rest/vcenter/vm/"

    try {

        if ($null -eq $avsvCenteruserName) {
            Write-Error "AVS vCenter Username is null"
            return
        }
        if ($null -eq $avsvCenterpassword) {
            Write-Error "AVS vCenter Password is null"
            return
        }

        # Make the API request to get AVS VMs
        $response = Invoke-APIRequest -method "Get" `
                                    -url $url `
                                    -avsVcenter $avsVcenter `
                                    -avsvCenteruserName $avsvCenteruserName `
                                    -avsvCenterpassword $avsvCenterpassword
        return $response.value
    }
    catch {
        Write-Error "Failed to get AVS VMs: $_"
    }
}