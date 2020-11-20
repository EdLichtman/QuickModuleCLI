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
        . "$PSScriptRoot\Add-ModuleFunction.ps1"
        . "$PSScriptRoot\Add-ModuleAlias.ps1"
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
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
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
            Add-ModuleFunction -ModuleProject 'Test' -FunctionName $FunctionName -FunctionText  $FunctionText

            $err = { Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName $NewFunctionName } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Not -Be $ParameterBindingException
            $err.Exception.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
        }
    
        it 'throws error if DestinationModuleProject is empty' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText

            $err = {  Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject '' -NewCommandName 'Write-Test2' } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if DestinationCommandModule is not valid' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText

            $err = {  Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject 'Test' -NewCommandName 'Write-Test2' } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }

        it 'throws error if NewCommandName is empty' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText

            $err = {  Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName '' } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if attempting to copy a function using a new name without the approved verb' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Foo-Bar'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            $err = { Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName $NewFunctionName } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Not -Be $ParameterBindingException
            $err.Exception.GetType().Name | Should -Be 'ParameterStartsWithUnapprovedVerbException'
        }    

        it 'does not throw error if attempting to copy a function using a new name without the approved verb and -force flag' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Foo-Bar'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            { Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName $NewFunctionName -Force } | Should -Not -Throw
        }    
    }
    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Source Module' {
            Mock Get-ValidModuleProjectNames
            $Arguments = (Get-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName SourceModuleProject)
            
            try {$Arguments.Definition.Invoke()} catch {}
    
            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }

        it 'auto-suggests valid Module Command for CommandName' {
            $FakeBoundParameters = @{'SourceModuleProject'=$ViableModule}
            Mock Get-ValidModuleProjectNames {return $ViableModule}
            Mock Get-ModuleProjectFunctionNames
            Mock Get-ModuleProjectAliasNames

            $Arguments = (Get-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName CommandName)
            
            try {$Arguments.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            Assert-MockCalled Get-ModuleProjectFunctionNames -Times 1
            Assert-MockCalled Get-ModuleProjectAliasNames -Times 1
        }

        it 'auto-suggests valid Module Command for CommandName With no SourceModuleProject' {
            $FakeBoundParameters = @{}
            Mock Get-ValidModuleProjectNames {return $ViableModule,'Test'}
            Mock Get-ModuleProjectFunctionNames
            Mock Get-ModuleProjectAliasNames

            $Arguments = (Get-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName CommandName)
            
            try {$Arguments.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            Assert-MockCalled Get-ModuleProjectFunctionNames -Times 2
            Assert-MockCalled Get-ModuleProjectAliasNames -Times 2
        }

        it 'auto-suggests valid Module Arguments for Destination Module' {
            Mock Get-ValidModuleProjectNames
            $Arguments = (Get-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName DestinationModuleProject)
            
            try {$Arguments.Definition.Invoke()} catch {}
    
            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }

        it 'auto-suggests valid verb arguments for NewCommandName if CommandName is a function' {
            $Arguments = (Get-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName NewCommandName)
            $FakeBoundParameters = @{
                'SourceModuleProject'=$ViableModule
                'CommandName'='Get-Foo'
            }
            Mock Get-ValidModuleProjectNames {return $ViableModule}
            Mock Get-ModuleProjectFunctionNames {'Get-Foo'}
            Mock Get-ModuleProjectAliasNames
            
            'Get-' -in ($Arguments.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)) | Should -BeTrue
        }

        it 'does not auto-suggest verb arguments for NewCommandName if CommandName is an alias' {
            $Arguments = (Get-ArgumentCompleter -CommandName Copy-ModuleCommand -ParameterName NewCommandName)
            $FakeBoundParameters = @{
                'SourceModuleProject'=$ViableModule
                'CommandName'='Get'
            }
            Mock Get-ValidModuleProjectNames {return $ViableModule}
            Mock Get-ModuleProjectFunctionNames 
            Mock Get-ModuleProjectAliasNames {'Get'}
            
            'Get-' -in ($Arguments.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)) | Should -BeFalse
        }
    }
    describe 'functionality' {
        it 'Should copy a function to a new function in the same module' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Write-FooClone'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName $NewFunctionName
    
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $NewFunctionName) | Should -BeTrue
        }

        it 'Should copy a function to a new function without approved verb using -force' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Foo-FooClone'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
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
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $NewModuleName -NewCommandName $NewFunctionName
    
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $NewModuleName -CommandName $NewFunctionName) | Should -BeTrue
        }
    
        it 'Should copy an alias to a new alias in the same module' {
            $AliasName = 'Foo'
            $AliasMappedFunction = "Write-Output"
            $NewAliasName = 'FooClone'

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleAlias -ModuleProject $ViableModule -AliasName $AliasName -AliasMappedFunction $AliasMappedFunction
    
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
            Add-ModuleAlias -ModuleProject $ViableModule -AliasName $AliasName -AliasMappedFunction $AliasMappedFunction
    
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $AliasName -DestinationModuleProject $NewModuleName -NewCommandName $NewAliasName
    
            Test-Path (Get-ModuleProjectAliasPath -ModuleProject $NewModuleName -CommandName $NewAliasName) | Should -BeTrue
        }
    
        it 'Should create a function with the same definition as its source' {
            $FunctionName = 'Get-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Get-FooClone'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText $FunctionText
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName $NewFunctionName
    
            $FunctionPath = Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName
            $CopiedFunctionPath = Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $NewFunctionName
            
            . "$FunctionPath"
            . "$CopiedFunctionPath"
    
            $CommandType, $Definition = Get-ModuleProjectCommandDefinition -ModuleProject $ViableModule -CommandName $FunctionName
            $CopiedCommandType, $CopiedDefinition = Get-ModuleProjectCommandDefinition -ModuleProject $ViableModule -CommandName $NewFunctionName
    
            $Definition | Should -Be $FunctionText
            $CopiedDefinition | Should -Be $Definition
            $CopiedCommandType | Should -Be 'Function'
        }

        it 'Attempts to Edit-ModuleCommand if a function is cloned' {
            $FunctionName = 'Get-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Get-FooClone'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText $FunctionText
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -NewCommandName $NewFunctionName
            
            Assert-MockCalled Edit-ModuleCommand -Times 1
        }
    
        it 'does not attempt to Edit-ModuleCommand if alias is cloned' {
            $AliasName = 'Foo'
            $AliasMappedFunction = "Write-Output"
            $NewAliasName = 'FooClone'

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleAlias -ModuleProject $ViableModule -AliasName $AliasName -AliasMappedFunction $AliasMappedFunction
    
            Copy-ModuleCommand -SourceModuleProject $ViableModule -CommandName $AliasName -DestinationModuleProject $ViableModule -NewCommandName $NewAliasName

            Assert-MockCalled Edit-ModuleCommand -Times 0
        }
    }
}