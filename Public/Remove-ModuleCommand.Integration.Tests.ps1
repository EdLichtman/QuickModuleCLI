describe 'Remove-ModuleCommand' {
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

        . "$PSScriptRoot\Edit-ModuleCommand.ps1"
        . "$PSScriptRoot\Add-ModuleFunction.ps1"
        . "$PSScriptRoot\Add-ModuleAlias.ps1"
        . "$PSScriptRoot\Update-ModuleProject.ps1"
        . "$PSScriptRoot\Remove-ModuleCommand.ps1"

        $ViableModule = "Viable"
        $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'
        Remove-Sandbox
    }
    BeforeEach {
        New-Sandbox
        Mock Import-Module
        Mock Edit-ModuleCommand -RemoveParameterValidation 'ModuleProject', 'CommandName'
        Mock Update-ModuleProject
    }
    AfterEach {
        Remove-Sandbox
    }
    AfterAll {
        Remove-Sandbox
    }

    describe 'validations' {   
        it 'throws error if ModuleProject does not exist' {
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Remove-ModuleCommand -ModuleProject $ViableModule -CommandName 'Get-Foo' -WhatIf } | Should -Throw -PassThru
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }
    
        it 'throws error if function does not exist' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Remove-ModuleCommand -ModuleProject $ViableModule -CommandName 'Get-Foo' -WhatIf } | Should -Throw -PassThru
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
        }
    
        it 'throws error if function is null' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Remove-ModuleCommand -ModuleProject $ViableModule -CommandName '' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }
    
        it 'throws error if function does not exist in ModuleProject' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-TestFunction -ModuleName 'Test' -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"
    
            $err = { Remove-ModuleCommand -ModuleProject $ViableModule -CommandName 'Get-Foo' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
        }
        
        it 'throws error if function does not exist at all' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Remove-ModuleCommand -ModuleProject $ViableModule -CommandName 'Get-Foo' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
        }    
    }
    
    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for ModuleProject' {
             Add-TestModule $ViableModule -Valid
            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Remove-ModuleCommand -ParameterName ModuleProject)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke()} catch {}
    
            $Arguments | Should -Be @($ViableModule)
        }

        it 'auto-suggests valid Module Command for CommandName' {
            $FakeBoundParameters = @{'ModuleProject'=$ViableModule}
            Add-TestModule $ViableModule -Valid
            Add-TestFunction $ViableModule 'Foo-Bar' 
            Add-TestAlias $ViableModule 'Bar'
            Add-TestModule 'Test' -Valid
            Add-TestFunction 'Test' 'Get-Foo'

            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Remove-ModuleCommand -ParameterName CommandName)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            $Arguments | Should -Be @('Foo-Bar','Bar')
        }

        it 'auto-suggests valid Module Command for CommandName with no ModuleProject' {
            $FakeBoundParameters = @{}
            Add-TestModule $ViableModule -Valid
            Add-TestFunction $ViableModule 'Foo-Bar' 
            Add-TestModule 'Test' -Valid
            Add-TestAlias 'Test' 'Bar'

            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Remove-ModuleCommand -ParameterName CommandName)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            $Arguments | Should -Be @('Bar','Foo-Bar')
        }
    }

    describe 'functionality' {
        it 'Removes function from module' {
            $FunctionName = 'Write-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName
    
            #Preliminary test
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName) | Should -BeTrue
            Remove-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName

            #Assertion
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName) | Should -BeFalse
        }

        it 'Removes alias from module' {
            $AliasName = 'foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-ModuleAlias -ModuleProject $ViableModule -AliasName $AliasName -AliasMappedFunction 'Write-Output'
    
            #Preliminary test
            Test-Path (Get-ModuleProjectAliasPath -ModuleProject $ViableModule -CommandName $AliasName) | Should -BeTrue
            Remove-ModuleCommand -ModuleProject $ViableModule -CommandName $AliasName

            #Assertion
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $AliasName) | Should -BeFalse
        }

        it 'updates ModuleProject' {
            $FunctionName = 'Write-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName

            Assert-MockCalled Update-ModuleProject -Times 1
            Remove-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName

            Assert-MockCalled Update-ModuleProject -Times 2
        }

        it 'Re-imports Module' {
            $FunctionName = 'Write-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName

            Assert-MockCalled Import-Module -Times 1 -ParameterFilter {$Name -eq $BaseModuleName -and $Force -eq $True -and $Global -eq $True}
            Remove-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName

            Assert-MockCalled Import-Module -Times 2 -ParameterFilter {$Name -eq $BaseModuleName -and $Force -eq $True -and $Global -eq $True}
        }
    }
}