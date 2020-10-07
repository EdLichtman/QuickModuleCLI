function Edit-QuickCommand {
    param(
        [Parameter(Mandatory=$true)]
        [string]$NestedModule,
        [Parameter(Mandatory=$true)]
        [string]$commandName
        
    )

    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1

    $Function = "$NestedModulesFolder\$NestedModule\Functions\$commandName.ps1"
    $Alias = "$NestedModulesFolder\$NestedModule\Aliases\$AliasName.ps1"
    if (!(Test-Path $Function) -and !(Test-Path $Alias)) {
        Write-Output "Command '$commandName' not found."
        return;
    }
    if(Test-Path "$Function") {
        . powershell_ise.exe "$Function" 
    }
    elseif(Test-Path "$Alias") {
        . powershell_ise.exe "$Alias"
    } 

    Write-Host -NoNewline -Object 'Press any key when you are finished editing...' -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

    Import-Module $BaseModuleName -Force
}