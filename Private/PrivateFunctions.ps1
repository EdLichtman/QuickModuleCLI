<# ENVIRONMENT VARIABLES #>

<# INTERNAL FUNCTIONS #>
function New-FileWithContent {
    param(  [String] $filePath,
            [String] $fileText,
            [Switch] $force)

    $continue = 0;
    if (Test-Path $filePath) {
        if (!$force) {
            $folderPath = Split-Path $filePath
            $fileName = Split-Path $filePath -Leaf
            $continue = $Host.UI.PromptForChoice("'$fileName' already exists at location $folderPath.", "Would you like to overwrite?", @('&Yes','&No'),1)
        }
       
        if ($continue -eq '0') {
            Remove-Item $filePath
        }
    } 

    if ($continue -eq '0') {
        New-Item -ItemType File -Force -Path $filePath | Out-null
    }
    if (Test-Path $filePath) {
        Add-Content -Path $filePath -Value $fileText 
    }
}
