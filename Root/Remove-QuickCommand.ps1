function global:Remove-QuickCommand {
    param(
        [Parameter(Mandatory=$true)][string]$QuickModule,
        [Parameter(Mandatory=$true)][string]$commandName

    )

    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1

    if(Test-Path "$QuickPackageModuleContainerPath\$QuickModule\Functions\$commandName.ps1") {
        Remove-Item -Path "$QuickPackageModuleContainerPath\$QuickModule\Functions\$commandName.ps1"    

        if (Test-Path function:\$commandName) {
            Remove-Item function:\$commandName
        }
    }
    elseif(Test-Path "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$commandName.ps1") {
        Remove-Item -Path "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$commandName.ps1"
        
        if (Test-Path alias:\$commandName) {
            Remove-Item alias:\$commandName
        }
    } else {
        Write-Output "Command '$commandName' not found."
        return;
    }
}