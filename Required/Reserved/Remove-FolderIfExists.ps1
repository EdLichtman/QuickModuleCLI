function Remove-FolderIfExists {
    param([String] $pathToFolder)

    if (Test-Path $pathToFolder -PathType Container) {
        Remove-Item -Path $pathToFolder -Recurse | Out-null
    }
}