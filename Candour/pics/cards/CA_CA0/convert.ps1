Get-ChildItem -Path . -Filter *.png | ForEach-Object {
    $originalPath = $_.FullName
    $jpgName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name) + ".jpg"
    $outputPath = Join-Path $_.DirectoryName $jpgName

    Write-Host "Converting: $originalPath -> $outputPath"

    magick $originalPath -background white -flatten $outputPath

    if (Test-Path $outputPath) {
        Write-Host "Conversion successful. Deleting original: $originalPath"
        Remove-Item $originalPath -Force
    } else {
        Write-Host "Conversion failed for: $originalPath" -ForegroundColor Red
    }
}