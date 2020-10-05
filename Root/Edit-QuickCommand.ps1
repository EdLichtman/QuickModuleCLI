function Edit-QuickCommand {
    param(
        [Parameter(Mandatory=$true)]
        [string]$QuickModule,
        [Parameter(Mandatory=$true)]
        [string]$commandName
        
    )

    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1
    . $QuickHelpersRoot\Reset-QuickCommand.ps1

    if(Test-Path "$QuickPackageModuleContainerPath\$QuickModule\Functions\$commandName.ps1") {
        . powershell_ise.exe "$QuickPackageModuleContainerPath\$QuickModule\Functions\$commandName.ps1" 
        Write-Host -NoNewline -Object 'Press any key when you are finished editing...' -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        Reset-QuickCommand -QuickModule $QuickModule -commandName $commandName
    }
    elseif(Test-Path "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$AliasName.ps1") {
        . powershell_ise.exe "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$AliasName.ps1"
        Write-Host -NoNewline -Object 'Press any key when you are finished editing...' -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        Reset-QuickCommand -QuickModule $QuickModule -commandName $commandName
    } else {
        Write-Output "Command '$commandName' not found."
        return;
    }
}