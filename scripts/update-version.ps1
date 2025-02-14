param (
    [string]$version = (Get-Content -Path "$PSScriptRoot/../version.txt" -Raw).Trim()
)

# Read the mod.template.json file
$json = Get-Content -Path "$PSScriptRoot/../mod.template.json" -Raw | ConvertFrom-Json

# Update the version number in the JSON object
$json.version = $version

# Convert the JSON object back to a string
$jsonString = $json | ConvertTo-Json

# Write the updated JSON string back to the mod.template.json file
Set-Content -Path "mod.template.json" -Value $jsonString
