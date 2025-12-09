Write-Host "STARTING COLOR REPLACEMENT (SAFE MODE)..." -ForegroundColor Cyan

# 1. Define the colors (CTT Blue vs GTweaks Green)
# We look for the specific Hex codes used in the original app
$blueCTT = "0078D7"
$greenGT = "00C853"

$blueSystem = "SystemAccentColor"
$greenHex = "#FF00C853"

# 2. Get ALL files in the project (xaml, ps1, json)
$files = Get-ChildItem -Path . -Recurse -Include "*.xaml", "*.ps1", "*.json", "*.xml"

foreach ($file in $files) {
    # Skip this script itself and git files
    if ($file.Name -eq "ColorFix.ps1" -or $file.FullName -match "\\.git\\") { continue }

    try {
        # Read file content
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
        $modified = $false

        # REPLACEMENT 1: The Hex Color Code
        if ($content -match $blueCTT) {
            $content = $content -replace $blueCTT, $greenGT
            $modified = $true
        }

        # REPLACEMENT 2: The System Accent Color (Windows Blue)
        # We replace the dynamic resource with a static Green color
        if ($content -match $blueSystem) {
            $content = $content -replace "{DynamicResource $blueSystem}", $greenHex
            $content = $content -replace "DynamicResource $blueSystem", $greenHex
            $content = $content -replace $blueSystem, $greenHex
            $modified = $true
        }

        # REPLACEMENT 3: Common named colors
        if ($content -match "DeepSkyBlue") {
            $content = $content -replace "DeepSkyBlue", "#00E676"
            $modified = $true
        }
        if ($content -match "Blue") {
            # Be careful with just "Blue", only replace if it looks like a property
            $content = $content -replace 'Color="Blue"', 'Color="#00C853"'
            $content = $content -replace 'Background="Blue"', 'Background="#00C853"'
            $modified = $true
        }

        # Save if modified
        if ($modified) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8
            Write-Host "  [FIXED]$($file.Name)" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  [ERROR] Could not read $($file.Name)" -ForegroundColor Red
    }
}

Write-Host "`n------------------------------------------------"
Write-Host "COLOR REPLACEMENT DONE."
Write-Host "PLEASE RUN .\Compile.ps1 NOW."
Write-Host "------------------------------------------------"
