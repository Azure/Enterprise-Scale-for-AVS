function Export-RecommendationsToCSV {
    param (
        [Parameter(Mandatory=$true)]
        [array]$recommendations,
        [System.Object[]]$designAreasToTest
    )

    try {

        if ($recommendations.Count -eq 0) {
            Write-Host "There are no recommendations to export..."
            return
        }

        # Filter the recommendations based on the design areas to test
        if ($designAreasToTest.Count -gt 0) {
            $recommendations = $recommendations | Where-Object { $designAreasToTest -contains $_.Category }
        }

        # Get the path of the calling script
        $scriptDirectory = $PSScriptRoot

        # Construct the full path for the CSV file
        $csvFilePath = Join-Path -Path $scriptDirectory -ChildPath "Recommendations.csv"

        # Sort and Create the CSV file
        $recommendations | Sort-Object -Property Category | Export-Csv -Path $csvFilePath -NoTypeInformation

        Write-Host "CSV file created at: $csvFilePath"
    }
    catch {
        Write-Error "An error occurred: $_"
    }
}