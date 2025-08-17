param(
    [Parameter(Mandatory=$true)]
    [string]$ForgePath,
    [string]$SourceFolder = "$($env:APPDATA)\Forge\custom\typelists"
)

# Paths
$existingFile = Join-Path -Path $ForgePath -ChildPath "\res\lists\TypeLists.txt"
$backupFile = "$existingFile.bak"

# Validate existing file
if (-not (Test-Path $existingFile)) {
    Write-Error "Existing file not found at path: $existingFile"
    exit 1
}

# Always create a timestamped and incremented backup
$timestamp = Get-Date -Format "yyyyMMdd"
$baseBackupPath = "$existingFile.$timestamp"
$counter = 1

do {
    $backupFile = "$baseBackupPath.$counter.bak"
    $counter++
} while (Test-Path $backupFile)

Copy-Item -Path $existingFile -Destination $backupFile
Write-Host "📦 Backup created: $backupFile"

# Function to parse .txt files into sections preserving order
function Parse-TypeFileWithOrder($path) {
    $sections = @{}
    $sectionOrder = @()
    $currentSection = ""

    Get-Content $path | ForEach-Object {
        $line = $_.Trim()
        if ($line -match '^\[.+\]$') {
            $currentSection = $line
            if (-not $sections.ContainsKey($currentSection)) {
                $sections[$currentSection] = @()
                $sectionOrder += $currentSection
            }
        }
        elseif ($line -ne "" -and $currentSection -ne "") {
            $sections[$currentSection] += $line
        }
    }

    return @{ Sections = $sections; Order = $sectionOrder }
}

# Extract type key (part before colon)
function Get-TypeKey($entry) {
    if ($entry -match "^(.*?):") {
        return $matches[1].Trim()
    } else {
        return $entry.Trim()
    }
}

# Parse existing file once
$existingParsed = Parse-TypeFileWithOrder $existingFile
$existingSections = $existingParsed.Sections
$existingOrder = $existingParsed.Order

# Build hashsets for existing keys per section for fast lookup
$existingKeysPerSection = @{}
foreach ($section in $existingOrder) {
    $keysSet = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($entry in $existingSections[$section]) {
        $null = $keysSet.Add((Get-TypeKey $entry))
    }
    $existingKeysPerSection[$section] = $keysSet
}

# Get all .txt files in source folder
$txtFiles = Get-ChildItem -Path $SourceFolder -Filter *.txt

Write-Host "Scanning folder: $SourceFolder"
Write-Host "Merging into: $existingFile"
Write-Host ""

foreach ($file in $txtFiles) {
    Write-Host "Processing $($file.Name)..."

    $fileParsed = Parse-TypeFileWithOrder $file.FullName
    $fileSections = $fileParsed.Sections

    foreach ($section in $existingOrder) {
        if ($fileSections.ContainsKey($section)) {
            foreach ($entry in $fileSections[$section]) {
                $typeKey = Get-TypeKey $entry
                if (-not $existingKeysPerSection[$section].Contains($typeKey)) {
                    $existingSections[$section] += $entry
                    $null = $existingKeysPerSection[$section].Add($typeKey)
                    Write-Host "➕ Added to $($section): $entry"
                }
                else {
                    Write-Host "⏭️ Skipped duplicate in $($section): $entry"
                }
            }
        }
    }
    Write-Host ""
}

# Write updated content back to TypeLists.txt
$output = @()
foreach ($section in $existingOrder) {
    $output += $section
    $output += $existingSections[$section]
    $output += ""
}
$output | Set-Content -Encoding UTF8 $existingFile

Write-Host "✅ TypeLists.txt has been updated at $existingFile."
