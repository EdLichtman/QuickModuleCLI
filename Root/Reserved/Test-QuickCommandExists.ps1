function Test-QuickCommandExists {
    param([Parameter(Mandatory=$true)][String]$CommandName)
    Invoke-Expression ". '$PSScriptRoot\Get-QuickEnvironment.ps1'"

    if (!(Test-Path $NestedModulesFolder)) {
        return;
    }

    $NestedModules = Get-ChildItem $NestedModulesFolder
    foreach($Module in $NestedModules) {
        $ModulePath = $Module.FullName
        $Functions = "$ModulePath\Functions"
        $Aliases = "$ModulePath\Aliases"
        foreach($Function in Get-ChildItem $Functions) {
            if ($Function.BaseName -eq $CommandName) {
                throw "'$CommandName' already exists as a function in '$Module'! Cannot create command with existing name, to prevent clashing."
            }
        }
        foreach($Alias in Get-ChildItem $Aliases) {
            if ($Alias.BaseName -eq $CommandName) {
                throw "'$CommandName' already exists as an alias in '$Module'! Cannot create command with existing name, to prevent clashing."
            }
        }
    }
}