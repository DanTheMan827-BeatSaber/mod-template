param (
    [string]$ModId,
    [string]$ModName,
    [string]$ModAuthor,
    [string]$ModDescription,
    [string]$ModVersion
)

function Prompt-For-Input($prompt, $allowSpaces = $true, $suggestedInput = $null) {
    do {
        if ($suggestedInput) {
            $promptValue = Read-Host "$prompt (default: $suggestedInput)"
        }
        else {
            $promptValue = Read-Host $prompt
        }
        $promptValue = $promptValue.Trim()
        if (-not $allowSpaces -and $promptValue -match '\s') {
            $suggestedInput = $promptValue -replace '\s', '-'
            Write-Host "Input cannot contain spaces. Please try again, or press Enter to use the suggested input."
            $promptValue = Read-Host "$prompt (default: $suggestedInput)"
            if ([string]::IsNullOrWhiteSpace($promptValue)) {
                $promptValue = $suggestedInput
            }
        }
        elseif ([string]::IsNullOrWhiteSpace($promptValue) -and $suggestedInput) {
            $promptValue = $suggestedInput
        }
    } while ([string]::IsNullOrWhiteSpace($promptValue))
    return $promptValue
}

# Trim whitespace from all parameters
if ($ModId) {
    $ModId = $ModId.Trim()
    # Replace any spaces in the ModId with '-'
    $ModId = $ModId -replace ' ', '-'
}
if ($ModName) {
    $ModName = $ModName.Trim()
}
if ($ModAuthor) {
    $ModAuthor = $ModAuthor.Trim()
}
if ($ModDescription) {
    $ModDescription = $ModDescription.Trim()
}
if ($ModVersion) {
    $ModVersion = $ModVersion.Trim()
}

# Check if parameters are provided, if not prompt the user for input
if (-not $ModId) {
    $ModId = Prompt-For-Input "Enter the Mod ID" $false
}
if (-not $ModName) {
    $ModName = Prompt-For-Input "Enter the Mod Name"
}
if (-not $ModAuthor) {
    $ModAuthor = Prompt-For-Input "Enter the Mod Author"
}
if (-not $ModDescription) {
    $ModDescription = Prompt-For-Input "Enter the Mod Description"
}
if (-not $ModVersion) {
    $ModVersion = Prompt-For-Input "Enter the Mod Version" $false "0.1.0"
}

# Store the values in variables.
$templateVariables = @{
    "MyTemplateModId"          = $ModId
    "MyTemplateModName"        = $ModName
    "MyTemplateModAuthor"      = $ModAuthor
    "MyTemplateModDescription" = $ModDescription
}

# List of files to be processed
$filesToProcess = @(
    "CMakeLists.txt",
    "mod.template.json",
    "qpm.json",
    "qpm.shared.json",
    "README.md",
    ".vscode/c_cpp_properties.json"
)

# Deep clean the project
& qpm s deepclean

# Loop through the specified files
foreach ($file in $filesToProcess) {
    $filePath = Join-Path -Path (Get-Location) -ChildPath $file
    if (Test-Path -Path $filePath) {
        $fileContent = Get-Content -Path $filePath -Raw

        # For each file, replace the template variables with the actual values.
        foreach ($key in $templateVariables.Keys) {
            $fileContent = $fileContent -replace $key, $templateVariables[$key]
        }

        # Trim trailing whitespace
        $fileContent = $fileContent.TrimEnd("`r", "`n", "`t", " ")

        # Save the updated content back to the file
        Set-Content -Path $filePath -Value $fileContent

        # Output the file path to indicate that it has been processed
        Write-Host "Processed: $filePath"
    }
}

# Update qpm.json with the version
$qpmJson = Get-Content -Path "qpm.json" | ConvertFrom-Json
$qpmJson.info.version = $ModVersion
$qpmJson | ConvertTo-Json -Depth 32 | Set-Content -Path "qpm.json"

# Update qpm.shared.json with the version if it exists
if (Test-Path -Path "qpm.shared.json") {
    $qpmJson = Get-Content -Path "qpm.shared.json" | ConvertFrom-Json
    $qpmJson.config.info.version = $ModVersion
    $qpmJson | ConvertTo-Json -Depth 32 | Set-Content -Path "qpm.shared.json"
}

# Output a message indicating that the script has completed
Write-Host "Configuration complete, deleting script file."

# Delete includes/Hooking.hpp if it exists
Remove-Item -Path "$PSScriptRoot/include/Hooking.hpp" -ErrorAction SilentlyContinue

# Delete the workflow file
Remove-Item -Path "$PSScriptRoot/.github/workflows/configure-template.yml" -ErrorAction SilentlyContinue

# Delete the script file
Remove-Item -Path $MyInvocation.MyCommand.Path
