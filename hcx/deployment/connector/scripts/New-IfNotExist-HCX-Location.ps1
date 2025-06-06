. .\Invoke-APIRequest.ps1
. .\HeaderHelper.ps1

function New-IfNotExist-HCX-Location {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl
    )

    # Check if HCX Location already exists
    $existingConfig = Get-HCX-Location -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl

    if (-not $existingConfig) {
        New-HCX-Location -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl
    }
}

function Get-HCX-Location {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl    )

    # Create Auth Header
    $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword

    # Define API URL
    $apiUrl = [string]::Format(
        "{0}" +
        "api/admin/global/config/location",
        $hcxUrl
    )

    # Make the request to get HCX locations
    $response = Invoke-WebRequest -method "GET" `
        -Uri $apiUrl `
        -Headers $headers `
        -SkipCertificateCheck

    # Process the response
    if ($response) {
        $content = $response.Content
        if ($content -eq '{}' -or $content -eq '' -or $null -eq $content) {
            return $null
        }else {
            return $content
        }
    } else {
        Write-Error "Failed to retrieve HCX Location."
        return $null
    }
}

function New-HCX-Location {
    param (
            [SecureString]$vCenterPassword,
            [string]$hcxUrl
        )

    try {
        
        # Get HCX Locations
        $location = Get-HCX-Locations -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl

        if ($location) {
            Create-HCX-Location -vCenterPassword $vCenterPassword -location $location
        }
    }
    catch {
        Write-Error "HCX Data Center Location configuration failed: $_"
    }
}
function Get-HCX-Locations {
    param (
            [SecureString]$vCenterPassword,
            [string]$hcxUrl
        )
    try {        #Extract city from current location
        $currentCity = Get-CurrentLocation | Select-Object -ExpandProperty city

        # Create Auth Header
        $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword
        
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "api/admin/global/config/searchCities?searchString={1}",
            $hcxUrl,
            $currentCity
        )        
        
        # Make the request
        $response = Invoke-WebRequest -method "GET" `
            -Uri $apiUrl `
            -Headers $headers `
            -SkipCertificateCheck

        # Process the response
        if ($response) {
            # Check if the response is empty
            if ($response.Content -eq '') {
                Write-Host "No HCX Locations found matching '$hcxLocationName'."
                # Create a fixed location
                $location = @{
                    city = "London"
                    country = "United Kingdom"
                    province = "Westminster"
                    latitude = 51.49999473
                    longitude = -0.116721844

                }            
            } else {
                # Get current location first to compare it's latitude and longitude against HCX locations
                $currentLocation = Get-CurrentLocation
                $apiResponse = $response.Content | ConvertFrom-Json
                $locations = $apiResponse.items

                # Sort locations by distance from current location using proper geographic distance
                $sortedLocations = $locations | Sort-Object {
                    Get-Distance $currentLocation.latitude $currentLocation.longitude $_.latitude $_.longitude
                }

                # Get the closest location
                $location = $sortedLocations | Select-Object -First 1

                #Ensure $location returns city, country, latitude, and longitude
                $location = @{
                    city = $location.city
                    country = $location.country
                    province = $location.province
                    latitude = [double]$location.latitude
                    longitude = [double]$location.longitude
                }
                #Write-Host "Selected closest location: $($location.city)"

            }

            return $location

        }
    }
    catch {
        Write-Error "HCX Locations retrieval failed: $_"
    }
}

function Get-CurrentLocation {
    try {
        # Using ipinfo.io (free, no API key required)
        $response = Invoke-RestMethod -Uri "https://ipinfo.io/json" -Method Get
        return @{
            latitude = [double]($response.loc -split ',')[0]
            longitude = [double]($response.loc -split ',')[1]
            city = $response.city
            region = $response.region
            country = $response.country
        }
    }
    catch {
        Write-Warning "Failed to get location from ipinfo.io: $_"
        return $null
    }
}

function Get-Distance {
    param(
        [double]$lat1,
        [double]$lon1,
        [double]$lat2,
        [double]$lon2
    )
    
    # Haversine formula for calculating distance between two points on Earth
    $R = 6371 # Earth's radius in kilometers
    $dLat = [Math]::PI * ($lat2 - $lat1) / 180
    $dLon = [Math]::PI * ($lon2 - $lon1) / 180
    $a = [Math]::Sin($dLat/2) * [Math]::Sin($dLat/2) + [Math]::Cos([Math]::PI * $lat1 / 180) * [Math]::Cos([Math]::PI * $lat2 / 180) * [Math]::Sin($dLon/2) * [Math]::Sin($dLon/2)
    $c = 2 * [Math]::Atan2([Math]::Sqrt($a), [Math]::Sqrt(1-$a))
    $distance = $R * $c
    
    return $distance
}

function Create-HCX-Location {
    param (
            [SecureString]$vCenterPassword,
            [PSCustomObject]$location        )
    try {

        # Create Auth Header
        $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword
        
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "api/admin/global/config/location",
            $hcxUrl
        )        

        # Define body
        $jsonBody= $location | ConvertTo-Json -Depth 10
        
        # Make the request
        $response = Invoke-WebRequest -method "PUT" `
            -Uri $apiUrl `
            -Body $jsonBody `
            -Headers $headers `
            -SkipCertificateCheck

        # Process the response
        if ($response) {
            Write-Host "HCX Location set successfully: $($location.city)."
        }
    }
    catch {
        Write-Error "HCX Location couldn't be set: $_"
    }
}