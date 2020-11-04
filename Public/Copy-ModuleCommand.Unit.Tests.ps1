describe 'Add-ModuleFunction' {
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
        
        . "$PSScriptRoot\Add-ModuleFunction.ps1"
        . "$PSScriptRoot\Add-ModuleAlias.ps1"
        . "$PSScriptRoot\Edit-ModuleCommand.ps1"
        . "$PSScriptRoot\Copy-ModuleCommand.ps1"

        $ViableModule = "Viable"
        $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'
    }

    BeforeEach {    
        Mock New-ModuleProjectFunction
        Mock New-ModuleProjectAlias
        Mock Edit-ModuleCommand
    }

    it 'throws error if module does not exist' {
        Mock Get-ValidModuleProjectNames { return @() }
        $err = {  Copy-ModuleCommand -SourceModuleProject $ViableModule -SourceCommandName 'Write-Test' -DestinationModuleProject $ViableModule -DestinationCommandName 'Write-Test2' } | Should -Throw -PassThru

        $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
    }

    it 'throws error if function already exists' {
        $Function = 'Write-Foo'
        $MockFunctionFile = Get-MockFileInfo -BaseName $Function

        Mock Get-ValidModuleProjectNames { return @($ViableModule) }
        Mock Get-ModuleProjectFunctions { return @($MockFunctionFile) }
        Mock Get-ModuleProjectAliases { return @()}

        $err = {  Copy-ModuleCommand -SourceModuleProject $ViableModule -SourceCommandName $Function -DestinationModuleProject $ViableModule -DestinationCommandName $Function } | Should -Throw -PassThru

        $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandExistsException'
    }

    it 'throws error if SourceModule does not contain the SourceCommand that exists' {
        $Function = 'Write-Foo'
        $MockFunctionFile = Get-MockFileInfo -BaseName $Function
        Mock Get-ValidModuleProjectNames { return @($ViableModule, 'Test') }
        Mock Get-ModuleProjectFunctions { return @($MockFunctionFile) } -ParameterFilter {$ModuleProject -eq 'Test' }
        Mock Get-ModuleProjectFunctions { return @()}
        Mock Get-ModuleProjectAliases { return @()}

        $err = { Copy-ModuleCommand -SourceModuleProject $ViableModule -SourceCommandName $Function -DestinationModuleProject $ViableModule -DestinationCommandName 'Write-Test2' } | Should -Throw -PassThru

        $err.Exception.GetType().BaseType | Should -Not -Be $ParameterBindingException
        $err.Exception.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
    }

    it 'throws error if attempting to copy a function using a new name without the approved verb' {
        $Function = 'Write-Foo'
        $MockFunctionFile = Get-MockFileInfo -BaseName $Function
        Mock Get-ValidModuleProjectNames { return @($ViableModule, 'Test') }

        Mock Get-ModuleProjectFunctions { return @($MockFunctionFile) } -ParameterFilter {$ModuleProject -eq $ViableModule }.GetNewClosure()
        Mock Get-ModuleProjectFunctions { return @()}
        Mock Get-ModuleProjectAliases { return @()}

        Mock Get-ModuleProjectCommandDefinition {return ('Function', $MockFunctionFile)}

        $err = { Copy-ModuleCommand -SourceModuleProject $ViableModule -SourceCommandName $Function -DestinationModuleProject $ViableModule -DestinationCommandName 'Foo-Test2' } | Should -Throw -PassThru

        $err.Exception.GetType().BaseType | Should -Not -Be $ParameterBindingException
        $err.Exception.GetType().Name | Should -Be 'ParameterStartsWithUnapprovedVerbException'
    }


    it 'Attempts to Edit-ModuleCommand if a function is cloned' {
        $Function = 'Write-Foo'
        $MockFunctionFile = Get-MockFileInfo -BaseName $Function
        Mock Get-ValidModuleProjectNames { return @($ViableModule, 'Test') }
        
        Mock Get-ModuleProjectFunctions { return @($MockFunctionFile) } -ParameterFilter {$ModuleProject -eq $ViableModule}.GetNewClosure()
        Mock Get-ModuleProjectFunctions { return @()}
        Mock Get-ModuleProjectAliases { return @()}
        Mock Get-ModuleProjectCommandDefinition {return ('Function', $MockFunctionFile)}

        Copy-ModuleCommand -SourceModuleProject $ViableModule -SourceCommandName $Function -DestinationModuleProject $ViableModule -DestinationCommandName 'Write-Test2'
        
        Assert-MockCalled Edit-ModuleCommand -Times 1
    }

    it 'does not attempt to Edit-ModuleCommand if alias is cloned' {
        $Alias = 'Foo'
        $MockAliasFile = Get-MockFileInfo -BaseName $Alias
        Mock Get-ValidModuleProjectNames { return @($ViableModule, 'Test') }
        
        Mock Get-ModuleProjectFunctions { return @()}

        Mock Get-ModuleProjectAliases { return @($MockAliasFile) } -ParameterFilter {$ModuleProject -eq $ViableModule}.GetNewClosure()
        Mock Get-ModuleProjectAliases { return @()}
        
        Mock Get-ModuleProjectCommandDefinition {return ('Alias', $MockAliasFile)}

        Copy-ModuleCommand -SourceModuleProject $ViableModule -SourceCommandName $Alias -DestinationModuleProject $ViableModule -DestinationCommandName 'Test2'
        
        Assert-MockCalled New-ModuleProjectAlias -Times 1
        Assert-MockCalled Edit-ModuleCommand -Times 0
    }

    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Source Module' {
            Mock Get-ValidModuleProjectNames
            $Arguments = (Get-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName SourceModuleProject)
            
            try {$Arguments.Definition.Invoke()} catch {}
    
            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }

        it 'auto-suggests valid Module Command for SourceCommandName' {
            $FakeBoundParameters = @{'ModuleProject'=$ViableModule}
            Mock Get-ValidModuleProjectNames {return $ViableModule}
            Mock Get-ModuleProjectFunctionNames
            Mock Get-ModuleProjectAliasNames

            $Arguments = (Get-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName SourceCommandName)
            
            try {$Arguments.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            Assert-MockCalled Get-ModuleProjectFunctionNames -Times 1
            Assert-MockCalled Get-ModuleProjectAliasNames -Times 1
        }

        it 'auto-suggests valid Module Arguments for Destination Module' {
            Mock Get-ValidModuleProjectNames
            $Arguments = (Get-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName DestinationModuleProject)
            
            try {$Arguments.Definition.Invoke()} catch {}
    
            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }
    }
}