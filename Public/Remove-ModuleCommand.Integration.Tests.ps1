describe 'Remove-ModuleCommand' {
    BeforeAll {
        . "$PSScriptRoot\..\Private\_TestEnvironment.ps1"
        
        <# ENVIRONMENT VARIABLES #>
        $BaseModuleName = "QuickModuleCLITests"
        $BaseFolder =  Get-SandboxBaseFolder
        $ModuleProjectsFolder = Get-SandboxNestedModulesFolder
        $FunctionsFolder = Get-SandboxFunctionsFolder
        $PrivateFunctionsFolder = Get-SandboxPrivateFunctionsFolder

        . "$PSScriptRoot\..\Private\Environment.ps1"
        . "$PSScriptRoot\..\Private\ObjectTransformation.ps1"
        . "$PSScriptRoot\..\Private\ArgumentCompleters.ps1"
        . "$PSScriptRoot\..\Private\ArgumentTransformations.ps1"
        . "$PSScriptRoot\..\Private\Validators.Exceptions.ps1"
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
        it 'throws error if ModuleProject is null' {
            $err = { Remove-ModuleCommand -ModuleProject '' -CommandName 'Get-Foo' -WhatIf } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }
    
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
            Mock Get-ValidModuleProjectNames
            $Arguments = (Get-ArgumentCompleter -CommandName Remove-ModuleCommand -ParameterName ModuleProject)
            
            try {$Arguments.Definition.Invoke()} catch {}
    
            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }

        it 'auto-suggests valid Module Command for CommandName' {
            $FakeBoundParameters = @{'ModuleProject'=$ViableModule}
            Mock Get-ValidModuleProjectNames {return $ViableModule}
            Mock Get-ModuleProjectFunctionNames
            Mock Get-ModuleProjectAliasNames

            $Arguments = (Get-ArgumentCompleter -CommandName Remove-ModuleCommand -ParameterName CommandName)
            
            try {$Arguments.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            Assert-MockCalled Get-ModuleProjectFunctionNames -Times 1
            Assert-MockCalled Get-ModuleProjectAliasNames -Times 1
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

            Assert-MockCalled Import-Module -Times 1 -ParameterFilter {$Name -eq $BaseModuleName -and $Force -eq $True}
            Remove-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName

            Assert-MockCalled Import-Module -Times 2 -ParameterFilter {$Name -eq $BaseModuleName -and $Force -eq $True}
        }
    }
}