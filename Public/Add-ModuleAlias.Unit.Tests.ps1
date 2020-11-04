describe 'Add-ModuleAlias' {
    BeforeAll {
        . "$PSScriptRoot\..\Private\_TestEnvironment.ps1"
        
        <# ENVIRONMENT VARIABLES #>
        $BaseModuleName = "QuickModuleCLITests"
        $BaseFolder =  Get-SandboxBaseFolder
        $ModuleProjectsFolder = Get-SandboxNestedModulesFolder
        $FunctionsFolder = Get-SandboxFunctionsFolder
        $PrivateFunctionsFolder = Get-SandboxPrivateFunctionsFolder

        . "$PSScriptRoot\..\Private\Environment.ps1"
        . "$PSScriptRoot\..\Private\ArgumentCompleters.ps1"
        . "$PSScriptRoot\..\Private\ArgumentTransformations.ps1"
        . "$PSScriptRoot\..\Private\Validators.ps1"
        
        . "$PSScriptRoot\Add-ModuleAlias.ps1"

        $ViableModule = "Viable"
    }

    it 'throws error if module does not exist' {
        Mock Get-ValidModuleProjectNames { return @() }
        $err = { Add-ModuleAlias -ModuleProject $ViableModule -AliasName 'foo' -AliasMappedFunction 'Write-Output' -WhatIf } | Should -Throw -PassThru
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
    }

    it 'throws error if command does not exist' {
        Mock Get-ValidModuleProjectNames { return @($ViableModule) }
        Mock Get-ModuleProjectFunctions { return @()}
        Mock Get-ModuleProjectAliases { return @() }

        $err = { Add-ModuleAlias -ModuleProject $ViableModule -AliasName 'foo' -AliasMappedFunction 'Write-Foo' -WhatIf } | Should -Throw -PassThru
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'CommandDoesNotExistException'
    }

    it 'throws error if alias already exists' {
        $Alias = 'Foo'
        $MockAliasFile = Get-MockFileInfo -BaseName $Alias

        Mock Get-ValidModuleProjectNames { return @($ViableModule) }
        Mock Get-ModuleProjectFunctions { return @()}
        Mock Get-ModuleProjectAliases { return @($MockAliasFile) }

        $err = { Add-ModuleAlias -ModuleProject $ViableModule -AliasName $Alias -AliasMappedFunction 'Write-Output' -WhatIf } | Should -Throw -PassThru
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandExistsException'
    }

    it 'Attempts to create a new ModuleProjectAlias' {
        Mock New-ModuleProjectAlias
        Mock Get-ValidModuleProjectNames { return @($ViableModule) }
        Mock Get-ModuleProjectFunctions { return @()}
        Mock Get-ModuleProjectAliases { return @() }

        Add-ModuleAlias -ModuleProject $ViableModule -AliasName 'Foo' -AliasMappedFunction 'Write-Output' -WhatIf

        Assert-MockCalled New-ModuleProjectAlias -Times 1
    }

    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Module' {
            Mock Get-ValidModuleProjectNames
            $Arguments = (Get-ArgumentCompleter -CommandName Add-ModuleAlias -ParameterName ModuleProject)
            
            try {$Arguments.Definition.Invoke()} catch {}
    
            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }
    }
}