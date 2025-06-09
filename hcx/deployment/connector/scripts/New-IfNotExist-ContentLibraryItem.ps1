. .\Invoke-APIRequest.ps1

function New-IfNotExist-ContentLibraryItem {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$contentLibraryID,
        [string]$contentLibraryitemName,
        [string]$contentLibraryItemID = $null
    )
    try {
        # Check if the Content Library Item already exists
        $libraryItemID = Get-LibraryItem -vCenter $vCenter `
                                    -vCenterUserName $vCenterUserName `
                                    -vCenterPassword $vCenterPassword `
                                    -contentLibraryID $contentLibraryID `
                                    -contentLibraryitemName $contentLibraryitemName

        if (-not $libraryItemID) {
            # Create a new Content Library Item
            $libraryItemID = New-LibraryItem -vCenter $vCenter `
                                            -vCenterUserName $vCenterUserName `
                                            -vCenterPassword $vCenterPassword `
                                            -contentLibraryID $contentLibraryID `
                                            -contentLibraryitemName $contentLibraryitemName
            if ($libraryItemID) {
                Write-Host "Content Library Item '$contentLibraryitemName' created successfully."
            }
        } else {
            Write-Host "Content Library Item '$contentLibraryitemName' already exists. Skipping creation."
        }
    }
    catch {
        Write-Host "Error processing library item: $_"
        $libraryItemID = $null
    }
    return $libraryItemID
}

function Get-LibraryItem {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$contentLibraryID,
        [string]$contentLibraryitemName
    )

    # Create API Endpoint to get Content Library Items
    $contentLibraryItemUrl = [string]::Format(
        "{0}" +
        "api/content/library/item?action=find",
        ${vCenter}
    )

    # Create the body for the request
    $body = @{
        library_id = $contentLibraryID
        name = $contentLibraryitemName
    }
    
    # Convert the body to JSON
    $jsonBody = $body | ConvertTo-Json -Depth 10

    # Make the request to get the Content Library Items
    $reponse = Invoke-APIRequest -method "Post" `
                      -url $contentLibraryItemUrl `
                      -body $jsonBody `
                      -vCenter $vCenter `
                      -vCenterUserName $vCenterUserName `
                      -vCenterPassword $vCenterPassword

    # Process the response
    if ($reponse) {
        return $reponse
    }
}

function New-LibraryItem {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$contentLibraryID,
        [string]$contentLibraryitemName
    )

    # Create API Endpoint to create a new Content Library Item
    $createContentLibraryItemUrl = [string]::Format(
        "{0}" +
        "api/content/library/item",
        ${vCenter}
    )
      # Define the body for the request
    $body = @{
        library_id = $contentLibraryID
        type = "ovf"
        name = $contentLibraryitemName
    }
    
    # Convert the body to JSON
    $jsonBody = $body | ConvertTo-Json -Depth 10
    
    # Make the request to create the Content Library Item
    $response = Invoke-APIRequest -method "Post" `
                      -url $createContentLibraryItemUrl `
                      -body $jsonBody `
                      -vCenter $vCenter `
                      -vCenterUserName $vCenterUserName `
                      -vCenterPassword $vCenterPassword

    # Process the response
    if ($null -ne $response) {
        return $response
    } else {
        Write-Error "Failed to create Content Library Item: $contentLibraryitemName."
        return $null
    }
}


function Get-ContentLibraryItemStorage {
    param (
            
            [string]$vCenter,
            [string]$vCenterUserName,
            [SecureString]$vCenterPassword,
            [string]$contentLibraryItemID
        )
        
        # Create API Endpoint to get the Content Library Item Storage
        $contentLibraryItemStorageUrl = [string]::Format(
            "{0}" +
            "api/content/library/item/{1}/storage",
            $vCenter,
            $contentLibraryItemID
        )
        
        # Make the request
        $response = Invoke-APIRequest -method "Get" `
                                    -url $contentLibraryItemStorageUrl `
                                    -vCenter $vCenter `
                                    -vCenterUserName $vCenterUserName `
                                    -vCenterPassword $vCenterPassword
        
        if ($response) {
            # only return value until .iso from $response.storage_uris[0]
            return $response.storage_uris[0].Substring(0, $response.storage_uris[0].IndexOf(".iso") + 4)
            
        } else {
            Write-Error "Failed to get Content Library Item Storage."
            return $null
        }
}