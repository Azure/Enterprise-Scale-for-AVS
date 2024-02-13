$rootFolder
$variablesPath = $rootFolder + "\variables\variables.json"
$variables = Get-Content -path $variablesPath | ConvertFrom-Json