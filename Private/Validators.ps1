using namespace System.Management.Automation;

. "$PSScriptRoot\Validators.Exceptions.ps1"

function ValidateModuleProjectExists {
    param($ModuleProject) 
    if ($ModuleProject) {
        $Choices = Get-ValidModuleProjectNames
        if (!$Choices) {
            throw (New-Object ModuleProjectDoesNotExistException 'No viable Modules. Please create one with New-ModuleProject!')
        }
    
        if (!($moduleProject -in ($Choices))) {
            throw (New-Object ModuleProjectDoesNotExistException "Parameter must be one of the following choices: $Choices")
        }
    }

    return $true

}

class ValidateModuleProjectExistsAttribute : ValidateArgumentsAttribute 
{
    [void]  Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics)
    {
        $moduleProject = $arguments
        ValidateModuleProjectExists -ModuleProject $ModuleProject
    }
}
function ValidateModuleProjectDoesNotExist {
    param($ModuleProject) 
    if ($ModuleProject) {
        $Choices = Get-ValidModuleProjectNames
        if ($Choices -and ($moduleProject -in ($Choices))) {
            throw (New-Object ModuleProjectExistsException "Parameter must not be one of the following choices: $Choices")
        }
    }
    return $True
}
class ValidateModuleProjectDoesNotExistAttribute : ValidateArgumentsAttribute 
{
    [void]  Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics)
    {
        $moduleProject = $arguments
       ValidateModuleProjectExists $ModuleProject
    }
}

function ValidateModuleDoesNotExist {
    param ($ModuleProject) 
    if ($ModuleProject) {
        if (Get-Module $moduleProject) {
            throw (New-Object ModuleExistsException "Module already exists by the name '$moduleProject'")
        }
    }
    return $True
}
class ValidateModuleDoesNotExistAttribute : ValidateArgumentsAttribute 
{
    [void]  Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics)
    {
        $moduleProject = $arguments
        ValidateModuleDoesNotExist $ModuleProject
    }
}

<#Internal#>
function Test-CommandExistsInModule {
    param(
        [String] $ModuleProject,
        [String] $CommandName
    )

    $Functions = Get-ModuleProjectFunctions -ModuleProject $ModuleProject
    if (($Functions | Where-Object { $_.BaseName -eq $CommandName})) {
        return $True
    } else {
        $Aliases = Get-ModuleProjectAliases -ModuleProject $ModuleProject
        if (($Aliases | Where-Object { $_.BaseName -eq $CommandName})) {
            return $True
        } 
    } 

    return $False
}
<#/Internal#>

function Assert-CommandExistsInModule {
    param(
        [String] $ModuleProject,
        [String] $CommandName
    )

    if (!(Test-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName)) {
        throw (New-Object ModuleCommandDoesNotExistException "'$CommandName' does not exist as a command in $ModuleProject!")
    }
}

function Test-ModuleCommandExists {
    $ModuleProjects = Get-ValidModuleProjectNames;
    foreach($ModuleProject in $ModuleProjects) {
        if (Test-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName) {
            return $true;
        }
    }

    return $false;
}
function ValidateModuleCommandExists {
    param($CommandName)
    if ($CommandName) {
        $ModuleProjects = Get-ValidModuleProjectNames;
        foreach($ModuleProject in $ModuleProjects) {
           if (Test-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName) {
               return $True;
           }
        }

        throw (New-Object ModuleCommandDoesNotExistException "'$CommandName' does not exist as a command in any ModuleProject!")
    }
    return $True
}
class ValidateModuleCommandExistsAttribute : ValidateArgumentsAttribute 
{
    [void] Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics) 
    {
        $CommandName = $arguments;
        ValidateModuleCommandExists $CommandName
    }
}

function ValidateCommandExists {
    param($CommandName)
    $ModuleProjects = Get-ValidModuleProjectNames;
    foreach($ModuleProject in $ModuleProjects) {
       if (Test-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName) {
           return;
       }
    }

    if (!(Get-Command -Name $CommandName -ErrorAction 'SilentlyContinue')) {
        throw (New-Object CommandDoesNotExistException "'$CommandName' does not exist")
    }
    return $True
}

class ValidateCommandExistsAttribute : ValidateArgumentsAttribute 
{
    [void] Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics) 
    {
        $CommandName = $arguments;   
        ValidateCommandExists -CommandName $CommandName
    }
}

function ValidateModuleCommandDoesNotExist {
    param($CommandName) 
    if ($CommandName) {
        $ModuleProjects = Get-ValidModuleProjectNames;
        foreach($ModuleProject in $ModuleProjects) {
            $Functions = Get-ModuleProjectFunctions -ModuleProject $ModuleProject
            $FunctionExists = ($Functions | Where-Object { $_.BaseName -eq $CommandName});
    
            $Aliases = Get-ModuleProjectAliases -ModuleProject $ModuleProject
            $AliasExists = ($Aliases | Where-Object { $_.BaseName -eq $CommandName})
            
            if ($FunctionExists -or $AliasExists) {
                throw (New-Object ModuleCommandExistsException "'$CommandName' already exists as a command in '$ModuleProject'!")
            }
        }
    }
    
    return $True
}
class ValidateModuleCommandDoesNotExistAttribute : ValidateArgumentsAttribute 
{
    [void] Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics) 
    {
        $CommandName = $arguments;
        ValidateModuleCommandDoesNotExist -CommandName $CommandName
    }
}

function Test-CommandStartsWithApprovedVerb {
    param([String]$CommandName)
    $chosenVerb = $commandName.Split('-')[0]
    $ApprovedVerbs = Get-ApprovedVerbs;
    return ($ApprovedVerbs.Contains($chosenVerb));
}

function ValidateCommandStartsWithApprovedVerb {
    param([String]$Command) 
    if ($Command) {
        $chosenVerb = $Command.Split('-')[0]
        $ApprovedVerbs = Get-ApprovedVerbs;
        if (!$ApprovedVerbs.Contains($chosenVerb)) {
            throw (New-Object ParameterStartsWithUnapprovedVerbException "$chosenVerb is not a common accepted verb. Please find an appropriate verb by using the command 'Get-Verb'.")
        }
    }
    
    return $True
}

# https://powershellexplained.com/2017-02-20-Powershell-creating-parameter-validators-and-transforms/
class ValidateParameterStartsWithApprovedVerbAttribute : ValidateArgumentsAttribute 
{
    [void]  Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics)
    {
        $Command = $arguments
        ValidateCommandStartsWithApprovedVerb -Command $Command
    }
}