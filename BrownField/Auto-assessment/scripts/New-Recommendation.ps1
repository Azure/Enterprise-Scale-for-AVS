function New-Recommendation {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$Category,

        [ValidateNotNullOrEmpty()]
        [string]$Observation,

        [string]$Recommendation,

        [ValidateNotNullOrEmpty()]
        [string]$LinkText,

        [ValidateNotNullOrEmpty()]
        [string]$LinkUrl,

        [ValidateSet("High", "Medium", "Low")]
        [string]$Priority
    )

    try {
        # Create a new PSCustomObject
        return [PSCustomObject]@{
            Category       = $Category
            Priority       = $Priority
            Observation    = $Observation
            Recommendation = $Recommendation
            LinkText       = $LinkText
            LinkUrl        = $LinkUrl
        }
    }
    catch {
        Write-Error "An error occurred while creating the recommendation: $_"
    }
}