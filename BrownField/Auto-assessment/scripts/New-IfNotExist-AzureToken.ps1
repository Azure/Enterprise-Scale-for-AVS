function New-IfNotExist-AzureToken {
    param (
        [Microsoft.Azure.Commands.Profile.Models.PSSecureAccessToken]$token
    )

    if ($null -eq $token) {
        Write-Error "Token cannot be null."
        return
    }

    try {
        $currentTime = [System.DateTime]::UtcNow
        $timeDifference = $token.ExpiresOn - $currentTime

        if ($timeDifference.TotalSeconds -le 60) {
            $token = Get-AzAccessToken -ResourceUrl "https://management.azure.com/" -AsSecureString -ErrorAction Stop
        }

        return $token
    }
    catch {
        Write-Error "Failed to get Azure session token: $_"
        return
    }
}