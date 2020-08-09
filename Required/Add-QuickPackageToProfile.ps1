function global:Add-QuickPackageToProfile {
    . "$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1"

    if (!(Test-Path $QuickPowershellProfilePath)) {
        New-Item $QuickPowershellProfilePath -ItemType File
    }
    if (!(Get-Content $QuickPowershellProfilePath | Select-String 'Import-Module Quick-Package')) {
        Add-Content $QuickPowershellProfilePath `
@"
Import-Module Quick-Package
"@
        
    }
    
}