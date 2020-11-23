describe 'Rename-ModuleCommand' {
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
        . "$PSScriptRoot\Rename-ModuleCommand.ps1"

        $ViableModule = "Viable"
        $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'
        Remove-Sandbox
    }
    BeforeEach {
        New-Sandbox

        Mock Import-Module
        Mock Update-ModuleProject
    }
    AfterEach {
        Remove-Sandbox
    }
    AfterAll {
        Remove-Sandbox
    }

    describe 'validations' {
        it 'throws error if source ModuleProject does not exist' {   
            $err = { Rename-ModuleCommand -ModuleProject $ViableModule -CommandName 'Get-Foo' -NewCommandName 'Test' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }
    
        it 'throws error if CommandName is null' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Rename-ModuleCommand -ModuleProject $ViableModule -CommandName '' -NewCommandName 'Test' -WhatIf } | Should -Throw -PassThru
            
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if function does not exist in source ModuleProject' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            $err = { Rename-ModuleCommand  -ModuleProject $ViableModule -CommandName 'Get-Foo' -NewCommandName 'Test' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
        }
    
        it 'throws error if NewCommandName is null' {
            $FunctionName = 'Get-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText 'Write-Output "Hello World"'

            $err = { Rename-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName -NewCommandName '' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if NewCommandName already exists' {
            $FunctionName = 'Get-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText 'Write-Output "Hello World"'
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Test' -FunctionText 'Write-Output "Hello World"'
    
            $err = { Rename-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName -NewCommandName 'Test' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandExistsException'
        }

        it 'throws error if NewCommandName is same as CommandName (i.e. already exists)' {
            $FunctionName = 'Get-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText 'Write-Output "Hello World"'
    
            $err = { Rename-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName -NewCommandName $FunctionName -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandExistsException'
        }

        it 'throws error if attempting to copy a function using a new name without the approved verb' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = 'Foo-Bar'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            $err = { Rename-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName -NewCommandName $NewFunctionName } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Not -Be $ParameterBindingException
            $err.Exception.GetType().Name | Should -Be 'ParameterStartsWithUnapprovedVerbException'
        }  
        
    }
    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Source Module' {
            Mock Get-ValidModuleProjectNames
            $Arguments = (Get-ArgumentCompleter -CommandName Rename-ModuleCommand -ParameterName ModuleProject)
            
            try {$Arguments.Definition.Invoke()} catch {}
    
            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }

        it 'auto-suggests valid Module Command for CommandName' {
            $FakeBoundParameters = @{'ModuleProject'=$ViableModule}
            Mock Get-ValidModuleProjectNames {return $ViableModule}
            Mock Get-ModuleProjectFunctionNames
            Mock Get-ModuleProjectAliasNames

            $Arguments = (Get-ArgumentCompleter -CommandName Rename-ModuleCommand -ParameterName CommandName)
            
            try {$Arguments.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            Assert-MockCalled Get-ModuleProjectFunctionNames -Times 1
            Assert-MockCalled Get-ModuleProjectAliasNames -Times 1
        }

        it 'auto-suggests valid Module Command for CommandName with no ModuleProject' {
            $FakeBoundParameters = @{}
            Mock Get-ValidModuleProjectNames {return $ViableModule, 'Test'}
            Mock Get-ModuleProjectFunctionNames
            Mock Get-ModuleProjectAliasNames

            $Arguments = (Get-ArgumentCompleter -CommandName Rename-ModuleCommand -ParameterName CommandName)
            
            try {$Arguments.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            Assert-MockCalled Get-ModuleProjectFunctionNames -Times 2
            Assert-MockCalled Get-ModuleProjectAliasNames -Times 2
        }

        it 'auto-suggests valid verb arguments for NewCommandName if CommandName is a function' {
            $Arguments = (Get-ArgumentCompleter -CommandName Rename-ModuleCommand -ParameterName NewCommandName)
            $FakeBoundParameters = @{
                'ModuleProject'=$ViableModule
                'CommandName'='Get-Foo'
            }
            Mock Get-ValidModuleProjectNames {return $ViableModule}
            Mock Get-ModuleProjectFunctionNames {'Get-Foo'}
            Mock Get-ModuleProjectAliasNames
            
            'Get-' -in ($Arguments.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)) | Should -BeTrue
        }

        it 'does not auto-suggest verb arguments for NewCommandName if CommandName is an alias' {
            $Arguments = (Get-ArgumentCompleter -CommandName Rename-ModuleCommand -ParameterName NewCommandName)
            $FakeBoundParameters = @{
                'ModuleProject'=$ViableModule
                'CommandName'='Get'
            }
            Mock Get-ValidModuleProjectNames {return $ViableModule}
            Mock Get-ModuleProjectFunctionNames 
            Mock Get-ModuleProjectAliasNames {'Get'}
            
            'Get-' -in ($Arguments.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)) | Should -BeFalse
        }
    }
    describe 'functionality' {
        it 'renames command into same module if function' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = "Test-Foo"

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Rename-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName -NewCommandName $NewFunctionName
    
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $NewFunctionName) | Should -BeTrue
        }

        it 'removes old command if function' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = "Test-Foo"

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Rename-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName -NewCommandName $NewFunctionName
    
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName) | Should -BeFalse
        }
    
        it 'renames command into same module if alias' {
            $AliasName = 'Bar'
            $NewAliasName = "Foo"

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName $ViableModule -AliasName $AliasName
    
            Rename-ModuleCommand -ModuleProject $ViableModule -CommandName $AliasName -NewCommandName $NewAliasName
    
            Test-Path (Get-ModuleProjectAliasPath -ModuleProject $ViableModule -CommandName $NewAliasName) | Should -BeTrue
        }

        it 'removes old command if alias' {
            $AliasName = 'Bar'
            $NewAliasName = "Foo"

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName $ViableModule -AliasName $AliasName
    
            Rename-ModuleCommand -ModuleProject $ViableModule -CommandName $AliasName -NewCommandName $NewAliasName
    
            Test-Path (Get-ModuleProjectAliasPath -ModuleProject $ViableModule -CommandName $AliasName) | Should -BeFalse
        }
        
        it 'attempts to update ModuleProject with renamed Function or alias' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = "Test-Foo"

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Rename-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName -NewCommandName $NewFunctionName
    
            Assert-MockCalled Update-ModuleProject -Times 1 -ParameterFilter {$ModuleProject -eq $ViableModule}
        }
    
        it 'Should try to re-import the ModuleProject' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $NewFunctionName = "Test-Foo"

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Rename-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName -NewCommandName $NewFunctionName
    
            Assert-MockCalled Import-Module -Times 1 -ParameterFilter {$Name -eq $BaseModuleName -and $Force -eq $True -and $Global -eq $True}
        }        
    }

}