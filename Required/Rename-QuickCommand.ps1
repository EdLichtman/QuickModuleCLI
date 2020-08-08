function Rename-QuickCommand {
    param(
        [String] $commandName,
        [String] $replacement
    )

    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1
    . $QuickReservedHelpersRoot\Test-QuickFunctionVariable.ps1
    . $QuickReservedHelpersRoot\New-FileWithContent.ps1

    $commandName = Test-QuickFunctionVariable $PSBoundParameters 'commandName' 'Please enter the function/alias name to be renamed'
    $replacement = Test-QuickFunctionVariable $PSBoundParameters 'replacement' 'Please enter the replacement'
    
    $functionFileRoot = "$QuickFunctionsRoot\$commandName.ps1"
    $aliasFileRoot = "$QuickAliasesRoot\$commandName.ps1"
    if(Test-Path $functionFileRoot) {
        $FunctionBlock = Get-Content $functionFileRoot -Raw
        $NewFunctionBlock = $FunctionBlock -Replace "$commandName", "$replacement" 
        
        Remove-QuickCommand -commandName $commandName
        Add-QuickFunction -functionName $replacement -functionText $NewFunctionBlock -ExcludeShell
    } elseif (Test-Path $aliasFileRoot) {
        $aliasBlock = Get-Content $aliasFileRoot -Raw
        $NewAliasBlock = $aliasBlock -Replace "Set-Alias $commandName", "Set-Alias $replacement" 
        
        Remove-QuickCommand -commandName $commandName
        Add-QuickAlias -aliasName $replacement -aliasText $NewAliasBlock -ExcludeShell
    } else {
        Write-Output "Command '$commandName' not found."
        return;
    }

}