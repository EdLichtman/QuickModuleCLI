function Remove-FolderIfExists {
    param(
        [String] $pathToFolder,
        [Switch] $Force
    )

    $QuickForceText = if ($force) { '-force' } else {''}
    if (Test-Path $pathToFolder -PathType Container) {
        Invoke-Expression "Remove-Item -Path $pathToFolder -Recurse $QuickForceText | Out-null"
    }
}