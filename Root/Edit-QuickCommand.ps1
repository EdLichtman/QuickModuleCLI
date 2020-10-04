function global:Edit-QuickCommand {
    param(
        [string]$commandName,
        [string]$QuickModule
    )

    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1
    . $QuickReservedHelpersRoot\Test-QuickFunctionVariable.ps1
    . $QuickHelpersRoot\Reset-QuickCommand.ps1

    $commandName = Test-QuickFunctionVariable $PSBoundParameters 'commandName' 'Please enter the function/alias to edit'
    $QuickModule = Test-QuickFunctionVariable $PSBoundParameters 'QuickModule' 'Please enter the name of the Module'

    if(Test-Path "$QuickPackageModuleContainerPath\$QuickModule\Functions\$commandName.ps1") {
        . powershell_ise.exe "$QuickPackageModuleContainerPath\$QuickModule\Functions\$commandName.ps1" 
        Write-Host -NoNewline -Object 'Press any key when you are finished editing...' -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        Reset-QuickCommand -commandName $commandName
    }
    elseif(Test-Path "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$AliasName.ps1") {
        . powershell_ise.exe "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$AliasName.ps1"
        Write-Host -NoNewline -Object 'Press any key when you are finished editing...' -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        Reset-QuickCommand -commandName $commandName
    } else {
        Write-Output "Command '$commandName' not found."
        return;
    }
}