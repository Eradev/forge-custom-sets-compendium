param(
    [bool]$images = $false
)

$prefix = "zarepath"
$customSource = "..\custom"
$forgeCustomDestination = "$($env:APPDATA)\Forge"

# Remove existing folders
Get-ChildItem -Path $forgeCustomDestination -Recurse -Directory -Force | Where-Object { $_.Name -eq $prefix } | ForEach-Object {
    Remove-Item -Path $_.FullName -Recurse -Force
    Write-Host "Deleted folder: $($_.FullName)"
}

# Remove existing edition files
Get-ChildItem -Path $forgeCustomDestination -Recurse -File -Force | Where-Object {
    $_.Extension -eq ".txt" -and $_.Name -like "$prefix*.txt"
} | ForEach-Object {
    Remove-Item -Path $_.FullName -Force
    Write-Host "Deleted file: $($_.FullName)"
}

Copy-Item -Path $customSource -Destination $forgeCustomDestination -Recurse -Force
Write-Host "Folder copied from '$customSource' to '$forgeCustomDestination'."

if ($images) {
    $picsSource = "..\pics"
    $forgePicsDestination = "$($env:LOCALAPPDATA)\Forge\Cache"

    Copy-Item -Path $picsSource -Destination $forgePicsDestination -Recurse -Force
    Write-Host "Folder copied from '$picsSource' to '$forgePicsDestination'."
}