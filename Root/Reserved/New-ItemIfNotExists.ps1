function New-ItemIfNotExists {
    param(
        [String] $pathToItem,
        [String] $itemType
    )

    if (!(Test-Path $pathToItem)) {
        New-Item -ItemType $itemType -Force -Path $pathToItem | Out-null
    }
}