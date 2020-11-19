using namespace System.Management.Automation;

. "$PSScriptRoot\Validators.Exceptions.ps1"

<#Fully Tested#>
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
<#Fully Tested#>
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

<#Fully Tested -- todo: Test with new addition of Get-EnvironmentalModuleDirectories#>
function ValidateModuleDoesNotExist {
    param ($ModuleProject) 
    if ($ModuleProject) {
        if (Get-Module $moduleProject) {
            throw (New-Object ModuleExistsException "Module already exists by the name '$moduleProject'")
        }

        $ModuleDirectories = Get-EnvironmentModuleDirectories
        foreach($Directory in $ModuleDirectories) {
            if ($ModuleProject -in (Get-ChildItem $Directory -Directory).Name) {
                throw (New-Object ModuleExistsException "Module already exists by the name '$moduleProject'")
            }
        }
    }
    return $True
}

<#Internal#>
<#Fully Tested#>
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

<#Fully Tested#>
function ValidateCommandExistsInModule {
    param(
        [String] $ModuleProject,
        [String] $CommandName
    )

    if (!(Test-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName)) {
        throw (New-Object ModuleCommandDoesNotExistException "'$CommandName' does not exist as a command in $ModuleProject!")
    }
}

<#TODO: Test #>
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

<#TODO: Test#>
function ValidateCommandExists {
    param($CommandName)
    $ModuleProjects = Get-ValidModuleProjectNames;
    foreach($ModuleProject in $ModuleProjects) {
       if (Test-CommandExistsInModule -ModuleProject $ModuleProject -CommandName $CommandName) {
           return $True; #todo: Test
       }
    }

    if (!(Get-Command -Name $CommandName -ErrorAction 'SilentlyContinue')) {
        throw (New-Object CommandDoesNotExistException "'$CommandName' does not exist")
    }
    return $True
}

<#Fully Tested#>
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
<#Fully Tested#>
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

#TODO: Test
function ValidateModuleProjectExportDestinationIsValid {
    param([String]$Destination) 

    $LimitationsText = 'Export-ModuleProject should be used to export your ModuleProject without clobber. If you wish to package the module for import as a separate module, use the command Split-ModuleProject instead.'
    if ($Destination -eq $ModuleProjectsFolder) {
        throw (New-Object ModuleProjectExportDestinationIsInvalidException "Cannot export module to ModuleProjects directory. $LimitationsText")
    }

    if ((Get-EnvironmentModuleDirectories) -contains $Destination) {
        throw (New-Object ModuleProjectExportDestinationIsInvalidException "Cannot export module to a PSModule directory. $LimitationsText")
    }

    return $True
}

#TODO: Test
function ValidateModuleCommandMoveDestinationIsValid {
    param(
        [String]$SourceModuleProject,
        [String]$DestinationModuleProject
    )

    if ($SourceModuleProject -eq $DestinationModuleProject) {
        throw (New-Object ModuleCommandMoveDestinationIsInvalidException 'SourceModuleProject must not be the same as DestinationModuleProject')
    }

    return $True
}

<#Todo: Test#>
function ValidateModuleProjectForImportIsValid {
    param( 
        [String] $Path
    )

    if (!(Test-Path $Path)) {
        throw (New-Object 'ItemNotFoundException' 'Please enter a valid Module path for import')
    }
    $ModuleProjectItem = Get-Item $Path
    $ModuleName = $ModuleProjectItem.Name

    ValidateModuleProjectDoesNotExist -ModuleProject $ModuleName | Out-Null
    ValidateModuleDoesNotExist -ModuleProject $ModuleName | Out-Null

    if (!(Test-Path "$Path\$ModuleName.psd1") `
        -or !(Test-Path "$Path\$ModuleName.psm1") `
        -or !(Test-Path "$Path\Functions") `
        -or !(Test-Path "$Path\Aliases")) {
            #todo -- add more validation, like do all the functions and Aliases only hold 1 base function or alias? Does psd1 have DefaultPrefix?
            throw ModuleProjectUnsupportedForImportException "This module is not supported for import by QuickModuleCLI"
        }
    
    return $True
}