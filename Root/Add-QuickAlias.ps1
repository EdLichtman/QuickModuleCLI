function global:Add-QuickAlias {
    param(
        [string]$AliasName,
        [string]$AliasText,
        [string]$QuickModule,
        [Switch]$Raw
    )
    
    . "$PSScriptRoot\Reserved\Get-QuickEnvironment.ps1"
    . "$QuickReservedHelpersRoot\Test-QuickFunctionVariable.ps1"
    . "$QuickReservedHelpersRoot\Test-CommandExists.ps1"
    . "$QuickReservedHelpersRoot\New-FileWithContent.ps1"

    $AliasName = Test-QuickFunctionVariable $PSBoundParameters 'AliasName' 'Please enter the Alias'
    $AliasText = Test-QuickFunctionVariable $PSBoundParameters 'AliasText' 'Please enter the Function'
    $QuickModule = Test-QuickFunctionVariable $PSBoundParameters 'QuickModule' 'Please enter the name of the Module'
    
    if (Test-CommandExists $aliasName) {
        Write-Output "That alias already exists as a command. $QuickPackageModuleName does not support Clobber."
        return
    }
    if (!(Test-CommandExists $aliasText)) {
        Write-Output "That Function does not exist."
        return
    }

    $newCode = $AliasText
    if (!$Raw){
        $newCode = 
@"
Set-Alias $AliasName $AliasText -Scope Global
"@
    }

    New-FileWithContent -filePath "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$AliasName.ps1" -fileText $newCode
    if ([String]::IsNullOrWhiteSpace($newFunctionText)) {
        powershell_ise.exe "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$AliasName.ps1"
        Write-Host -NoNewline -Object 'Press any key when you are finished editing...' -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    }

    Add-QuickModuleExport -QuickModule $QuickModule -AliasToExport $AliasName
    Reset-QuickCommand -QuickModule $QuickModule -commandName $AliasName
}