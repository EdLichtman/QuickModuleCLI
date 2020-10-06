function Move-QuickCommand {
    param(
        [Parameter(Mandatory=$true)][string] $NestedModule,
        [Parameter(Mandatory=$true)][string] $commandName,
        [Parameter(Mandatory=$true)][string] $DestinationNestedModule
    )

    . $PSScriptRoot\Reserved\Get-QuickEnvironment.ps1
    
    $Function = "$NestedModulesFolder\$NestedModule\Functions\$commandName.ps1"
    $Alias = "$NestedModulesFolder\$NestedModule\Aliases\$commandName.ps1"

    if(Test-Path $Function) {
        $FunctionBlock = Get-Content $Function -Raw
        
        Remove-QuickCommand -NestedModule $NestedModule -commandName $commandName
        Add-QuickFunction -NestedModule $DestinationNestedModule -functionName $commandName -functionText $FunctionBlock -Raw
    } elseif (Test-Path $Alias) {
        $aliasBlock = Get-Content $Alias -Raw
        
        Remove-QuickCommand -NestedModule $NestedModule -commandName $commandName
        Add-QuickAlias -NestedModule $DestinationNestedModule -aliasName $commandName -aliasText $aliasBlock -Raw
    } else {
        Write-Output "Command '$commandName' not found."
        return;
    }
}