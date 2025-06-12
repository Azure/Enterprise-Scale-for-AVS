function Get-Standard-Headers {
    param(
        [SecureString]$vCenterPassword
    )
    # Create Auth Header
    $base64AuthInfo = Get-Base64AuthInfo -userName "admin" -password $vCenterPassword

    # Create Call Header
    $headers = @{
        'Authorization' = "Basic $base64AuthInfo"
        'Content-Type' = 'application/json'
        'Accept' = 'application/json'
    }

    return $headers
}