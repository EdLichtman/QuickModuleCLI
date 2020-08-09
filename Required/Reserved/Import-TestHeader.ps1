#Home Folder
$FilesToImport = @(Get-ChildItem -Recurse "$PSScriptRoot\..\..\" -Filter '*.ps1' | ForEach-Object { "$($_.FullName)" }) | Where-Object {!($_ -eq $PSCommandPath) -and !($_.Contains('Tests.ps1'))}

foreach ($file in $FilesToImport) {
    . $file
}