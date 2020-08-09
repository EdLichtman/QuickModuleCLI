$FilesToImport = @(Get-ChildItem "$PSScriptRoot\..\" -Filter '*.ps1' | ForEach-Object { "$($_.FullName)" })
$FilesToImport += @(Get-ChildItem "$PSScriptRoot\" -Filter '*.ps1' | ForEach-Object { "$($_.FullName)" })
$FilesToImport += @(Get-ChildItem "$PSScriptRoot\Installer\" -Filter '*.ps1' | ForEach-Object { "$($_.FullName)" })

foreach ($file in $FilesToImport) {
    . $file
}