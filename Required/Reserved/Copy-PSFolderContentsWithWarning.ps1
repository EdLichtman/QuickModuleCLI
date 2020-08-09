function Copy-PSFolderContentsWithWarning {
    param(
        [String]$FromPath,
        [String]$ToPath,
        [Switch]$Force
    )

    . "$PSScriptRoot\New-FileWithContent.ps1"
    $QuickForceText = if ($Force) { '-force' } else { '' }

    $files = @(Get-ChildItem $FromPath -Filter '*.ps1')
    foreach ($file in $files) {
        Invoke-Expression "New-FileWithContent -FilePath $ToPath\$file -FileText (Get-Content $FromPath\$file -Raw) $QuickForceText"
    }
}