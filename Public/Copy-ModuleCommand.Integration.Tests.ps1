describe 'Copy-ModuleCommand' {
    BeforeAll {
        . "$PSScriptRoot\..\Private\_TestEnvironment.ps1"
        
        <# ENVIRONMENT VARIABLES #>
        $BaseModuleName = "QuickModuleCLITests"
        $BaseFolder =  Get-SandboxBaseFolder
        $ModuleProjectsFolder = Get-SandboxNestedModulesFolder
        $FunctionsFolder = Get-SandboxFunctionsFolder
        $PrivateFunctionsFolder = Get-SandboxPrivateFunctionsFolder

        . "$PSScriptRoot\..\Private\UI.ps1"
        . "$PSScriptRoot\..\Private\Environment.ps1"
        . "$PSScriptRoot\..\Private\ObjectTransformation.ps1"
        . "$PSScriptRoot\..\Private\ArgumentCompleters.ps1"
        . "$PSScriptRoot\..\Private\ArgumentTransformations.ps1"
        . "$PSScriptRoot\..\Private\Validators.ps1"
        
        . "$PSScriptRoot\Update-ModuleProject.ps1"
        . "$PSScriptRoot\Edit-ModuleCommand.ps1"
        . "$PSScriptRoot\Copy-ModuleCommand.ps1"

        $ViableModule = "Viable"
        $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'
        Remove-Sandbox
    }
    BeforeEach {
        New-Sandbox

        Mock Import-Module
        Mock Edit-ModuleCommand
        Mock Update-ModuleProject
    }
    AfterEach {
        Remove-Sandbox
    }
    AfterAll {
        Remove-Sandbox
    }

    describe 'validations' {
        it 'throws error if module does not exist' {
            $err = {  Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName 'Write-Test' -DestinationModuleProject $ViableModule -NewCommandName 'Write-Test2' } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }
    
        it 'throws error if Function is empty' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            $err = {  Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName '' -DestinationModuleProject $ViableModule -NewCommandName 'Write-Test2' } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if function already exists' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            $err = { Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName $FunctionName } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandExistsException'
        }
    
        it 'throws error if SourceModule does not contain the SourceCommand that exists' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Write-FooClone'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName 'Test' -FunctionName $FunctionName -FunctionText  $FunctionText

            $err = { Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName $NewFunctionName } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Not -Be $ParameterBindingException
            $err.Exception.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
        }

        it 'throws error if DestinationCommandModule is not valid' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText

            $err = {  Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject 'Test' -NewCommandName 'Write-Test2' } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }

        it 'throws error if NewCommandName is empty' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText

            $err = {  Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName '' } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if attempting to copy a function using a new name without the approved verb' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Foo-Bar'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            $err = { Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName $NewFunctionName } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Not -Be $ParameterBindingException
            $err.Exception.GetType().Name | Should -Be 'ParameterStartsWithUnapprovedVerbException'
        }    

        it 'does not throw error if attempting to copy a function using a new name without the approved verb and -force flag' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Foo-Bar'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            { Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName $NewFunctionName -Force } | Should -Not -Throw
        }    
    }
    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Source Module' {
            Add-TestModule $ViableModule -Valid
            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName SourceModuleProject)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke()} catch {}
    
            $Arguments | Should -Be @($ViableModule)
        }

        it 'auto-suggests valid Module Command for CommandName' {
            $FakeBoundParameters = @{'SourceModuleProject'=$ViableModule}
            Add-TestModule $ViableModule -Valid
            Add-TestFunction $ViableModule 'Foo-Bar' 
            Add-TestAlias $ViableModule 'Bar'
            Add-TestModule 'Test' -Valid
            Add-TestFunction 'Test' 'Get-Foo'

            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName CommandName)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            $Arguments | Should -Be @('Foo-Bar','Bar')
        }

        it 'auto-suggests valid Module Command for CommandName With no SourceModuleProject' {
            $FakeBoundParameters = @{}
            Add-TestModule $ViableModule -Valid
            Add-TestFunction $ViableModule 'Foo-Bar' 
            Add-TestModule 'Test' -Valid
            Add-TestAlias 'Test' 'Bar'

            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName CommandName)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            $Arguments | Should -Be @('Bar','Foo-Bar')
        }

        it 'auto-suggests valid Module Arguments for Destination Module' {
            Add-TestModule $ViableModule -Valid
            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName DestinationModuleProject)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke()} catch {}
    
            $Arguments | Should -Be @($ViableModule)
        }

        it 'auto-suggests valid verb arguments for NewCommandName if CommandName is a function' {
            $FunctionName = 'Get-Foo'
            $FakeBoundParameters = @{
                'SourceModuleProject'=$ViableModule
                'CommandName'=$FunctionName
            }
            Add-TestModule $ViableModule -Valid
            Add-TestFunction $ViableModule $FunctionName 
            
            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName NewCommandName)
            $Arguments = try {$ArgumentCompleter.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}

            'Get-' -in $Arguments | Should -BeTrue
        }

        it 'does not auto-suggest verb arguments for NewCommandName if CommandName is an alias' {
            $AliasName = 'GetFoo'
            $FakeBoundParameters = @{
                'SourceModuleProject'=$ViableModule
                'CommandName'=$AliasName
            }
            Add-TestModule $ViableModule -Valid
            Add-TestAlias $ViableModule $AliasName 
            
            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName NewCommandName)
            $Arguments = try {$ArgumentCompleter.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}

            'Get-' -in $Arguments | Should -BeFalse
        }
    }
    describe 'functionality' {
        it 'Should copy a function to a new function in the same module' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Write-FooClone'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName $NewFunctionName
    
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $NewFunctionName) | Should -BeTrue
        }

        it 'Should copy a function to a new function without approved verb using -force' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Foo-FooClone'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName $NewFunctionName -Force
    
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $NewFunctionName) | Should -BeTrue
        }
    
        it 'Should copy a function to a new function in a different module' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewModuleName = 'Test'
            $NewFunctionName = 'Write-FooClone'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $NewModuleName -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $NewModuleName -NewCommandName $NewFunctionName
    
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $NewModuleName -CommandName $NewFunctionName) | Should -BeTrue
        }
    
        it 'Should copy an alias to a new alias in the same module' {
            $AliasName = 'Foo'
            $AliasMappedFunction = "Write-Output"
            $NewAliasName = 'FooClone'

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName $ViableModule -AliasName $AliasName -AliasText $AliasMappedFunction
    
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $AliasName -DestinationModuleProject $ViableModule -NewCommandName $NewAliasName
    
            Test-Path (Get-ModuleProjectAliasPath -ModuleProject $ViableModule -CommandName $NewAliasName) | Should -BeTrue
        }
    
        it 'Should copy an alias to a new alias in a differentmodule' {
            $AliasName = 'Foo'
            $AliasMappedFunction = "Write-Output"
            $NewModuleName = 'Test'
            $NewAliasName = 'FooClone'

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $NewModuleName -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName $ViableModule -AliasName $AliasName -AliasText $AliasMappedFunction
    
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $AliasName -DestinationModuleProject $NewModuleName -NewCommandName $NewAliasName
    
            Test-Path (Get-ModuleProjectAliasPath -ModuleProject $NewModuleName -CommandName $NewAliasName) | Should -BeTrue
        }
    
        it 'Should create a function with the same definition as its source' {
            $FunctionName = 'Get-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Get-FooClone'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText $FunctionText
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName $NewFunctionName
    
            $FunctionPath = Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName
            $CopiedFunctionPath = Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $NewFunctionName
            
            . "$FunctionPath"
            . "$CopiedFunctionPath"
    
            $Definition = GetDefinitionForCommand -CommandName $FunctionName
            $CopiedDefinition = GetDefinitionForCommand -CommandName $NewFunctionName
            
            $CopiedCommandType = GetModuleProjectTypeForCommand -CommandName $NewFunctionName
    
            $Definition | Should -Be $FunctionText
            $CopiedDefinition | Should -Be $Definition
            $CopiedCommandType | Should -Be 'Function'
        }

        it 'Attempts to Edit-ModuleCommand if a function is cloned' {
            $FunctionName = 'Get-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Get-FooClone'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText $FunctionText
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName $NewFunctionName
            
            Assert-MockCalled Edit-ModuleCommand -Times 1
        }
    
        it 'does not attempt to Edit-ModuleCommand if alias is cloned' {
            $AliasName = 'Foo'
            $AliasMappedFunction = "Write-Output"
            $NewAliasName = 'FooClone'

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName $ViableModule -AliasName $AliasName -AliasText $AliasMappedFunction
    
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $AliasName -DestinationModuleProject $ViableModule -NewCommandName $NewAliasName

            Assert-MockCalled Edit-ModuleCommand -Times 0
        }

        it 'Can copy a module command without SourceModuleProject' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewModuleName = 'Test'
            $NewFunctionName = 'Write-FooClone'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $NewModuleName -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText

            Copy-ModuleCommand -CommandName $FunctionName -DestinationModuleProject $NewModuleName -NewCommandName $NewFunctionName
    
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $NewModuleName -CommandName $NewFunctionName) | Should -BeTrue
        }

        it 'Should copy a function to the same module without DestinationModuleProject' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Write-FooClone'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Copy-ModuleCommand -CommandName $FunctionName -NewCommandName $NewFunctionName
    
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $NewFunctionName) | Should -BeTrue
        }

        it 'Attempts to Update-ModuleProject for destination if a command is cloned' {
            $NewModule = 'New'
            $FunctionName = 'Get-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Get-FooClone'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $NewModule  -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText $FunctionText
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $NewModule -NewCommandName $NewFunctionName
            
            Assert-MockCalled Update-ModuleProject -Times 1 -ParameterFilter {$ModuleProject -eq $NewModule}
        }

        it 'Attempts to re-import destination ModuleProject if a command is cloned' {
            $FunctionName = 'Get-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Get-FooClone'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText $FunctionText
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName $NewFunctionName
            
            Assert-MockCalled Import-Module -Times 1 -ParameterFilter {$Name -eq $BaseModuleName -and $Force -eq $True -and $Global -eq $True}
        }
    }
}