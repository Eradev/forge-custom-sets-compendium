param(
    [bool]$images = $false
)

$customSource = "..\custom"
$forgeCustomDestination = "$($env:APPDATA)\Forge"

Copy-Item -Path $customSource -Destination $forgeCustomDestination -Recurse -Force
Write-Host "Folder copied from '$customSource' to '$forgeCustomDestination'."


if ($images) {
  $picsSource = "..\pics"
  $forgePicsDestination = "$($env:LOCALAPPDATA)\Forge\Cache"

  Copy-Item -Path $picsSource -Destination $forgePicsDestination -Recurse -Force
  Write-Host "Folder copied from '$picsSource' to '$forgePicsDestination'."
}