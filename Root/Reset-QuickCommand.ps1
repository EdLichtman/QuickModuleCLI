function global:Reset-QuickCommand {
    param(
        [Parameter(Mandatory=$true)][string]$QuickModule,
        [Parameter(Mandatory=$true)][string]$commandName
    )

    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1

    if(Test-Path "$QuickPackageModuleContainerPath\$QuickModule\Functions\$commandName.ps1") {
        . "$QuickPackageModuleContainerPath\$QuickModule\Functions\$commandName.ps1" 
    }
    elseif(Test-Path "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$commandName.ps1") {
        . "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$commandName.ps1"
    } else {
        Write-Output "Command '$commandName' not found."
        return;
    }
}