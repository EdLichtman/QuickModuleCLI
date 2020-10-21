function Get-NestedModuleLocation {
    param([Parameter(Mandatory=$true)][String]$NestedModule)
    return "$NestedModulesFolder\$NestedModule"
}

function Get-NestedModules {
    return Get-ChildItem $NestedModulesFolder
}

function Get-ModuleFunctionLocations {
    param([Parameter(Mandatory=$true)][String]$NestedModule)
    $ModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule
    return Get-ChildItem "$ModuleLocation\Functions"
}

function Get-ModuleAliasesLocations {
    param([Parameter(Mandatory=$true)][String]$NestedModule)
    $ModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule
    return Get-ChildItem "$ModuleLocation\Aliases"
}
function Get-ModuleFunctions {
    param([Parameter(Mandatory=$true)][String]$NestedModule)

    $NestedFunctions = New-Object System.Collections.ArrayList($null)
    $Functions = Get-ModuleFunctionLocations -NestedModule $NestedModule
    if ($Functions) {
        $Functions | ForEach-Object {$NestedFunctions.Add("$($_.BaseName)")} | Out-Null
    }

    return $NestedFunctions
}

function Get-ModuleAliases {
    param([Parameter(Mandatory=$true)][String]$NestedModule)

    $NestedAliases = New-Object System.Collections.ArrayList($null)
    $Aliases = Get-ModuleAliasesLocations -NestedModule $NestedModule
    if ($Aliases) {
        $Aliases | ForEach-Object {$NestedAliases.Add("$($_.BaseName)")} | Out-Null
    }

    return $NestedAliases
}

function Get-ModuleFunctionsLocation {
    param(
        [Parameter(Mandatory=$true)][String]$NestedModule
        )
    $ModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule
    return "$ModuleLocation\Functions\"
}

function Get-ModuleAliasesLocation {
    param(
        [Parameter(Mandatory=$true)][String]$NestedModule
        )
    $ModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule
    return "$ModuleLocation\Aliases\"
}

function Get-ModuleFunctionLocation {
    param(
        [Parameter(Mandatory=$true)][String]$NestedModule,
        [Parameter(Mandatory=$true)][String]$CommandName
        )
    $ModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule
    return "$ModuleLocation\Functions\$CommandName.ps1"
}

function Get-ModuleAliasLocation {
    param(
        [Parameter(Mandatory=$true)][String]$NestedModule,
        [Parameter(Mandatory=$true)][String]$CommandName
        )
    $ModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule
    return "$ModuleLocation\Aliases\$CommandName.ps1"
}