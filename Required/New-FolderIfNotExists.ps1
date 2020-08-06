function New-FolderIfNotExists {
    param([String] $pathToFolder)

    if (!(Test-Path $pathToFolder -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $pathToFolder | Out-null
    }
}