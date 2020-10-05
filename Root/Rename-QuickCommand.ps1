function Rename-QuickCommand {
    param(
        [Parameter(Mandatory=$true)][string] $QuickModule,
        [Parameter(Mandatory=$true)][string] $commandName,
        [Parameter(Mandatory=$true)][string] $replacement
    )

    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1
    
    $functionFileRoot = "$QuickPackageModuleContainerPath\$QuickModule\Functions\$commandName.ps1"
    $aliasFileRoot = "$QuickPackageModuleContainerPath\$QuickModule\Aliases\$commandName.ps1"
    if(Test-Path $functionFileRoot) {
        $FunctionBlock = Get-Content $functionFileRoot -Raw
        $NewFunctionBlock = $FunctionBlock -Replace "$commandName", "$replacement" 
        
        Remove-QuickCommand -commandName $commandName
        Add-QuickFunction -functionName $replacement -functionText $NewFunctionBlock -Raw
    } elseif (Test-Path $aliasFileRoot) {
        $aliasBlock = Get-Content $aliasFileRoot -Raw
        $NewAliasBlock = $aliasBlock -Replace "Set-Alias $commandName", "Set-Alias $replacement" 
        
        Remove-QuickCommand -commandName $commandName
        Add-QuickAlias -aliasName $replacement -aliasText $NewAliasBlock -Raw
    } else {
        Write-Output "Command '$commandName' not found."
        return;
    }

}