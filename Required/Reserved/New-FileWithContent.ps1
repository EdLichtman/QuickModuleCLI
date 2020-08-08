function New-FileWithContent {
    param(  [String] $filePath,
            [String] $fileText,
            [Switch] $force)

    if (Test-Path $filePath) {
        if (!$force) {
            $folderPath = Split-Path $filePath
            $fileName = Split-Path $filePath -Leaf
            $continue = (Read-Host -Prompt "'$fileName' already exists at location $folderPath. Want to overwrite? (Y/N)")
        } else {
            $continue = 'y'
        }
       
        if ($continue -eq 'y') {
            Remove-Item $filePath
        }
    } else {
        $continue = 'y'
    }
    if ($continue -eq 'y') {
        New-Item -ItemType File -Force -Path $filePath | Out-null
    }
    if (Test-Path $filePath) {
        Add-Content -Path $filePath -Value $fileText 
    }

}