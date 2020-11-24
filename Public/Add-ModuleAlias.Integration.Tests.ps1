describe 'Add-ModuleAlias' {
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
        . "$PSScriptRoot\Add-ModuleAlias.ps1"

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
        Teardown-Sandbox
    }

    describe 'validation' {
        it 'throws error if module does not exist' {
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            $err = { Add-ModuleAlias -ModuleProject $ViableModule -AliasName 'foo' -AliasMappedFunction 'Write-Output' -WhatIf } | Should -Throw -PassThru
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }

        it 'throws error if ModuleProject is empty' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Add-ModuleAlias -ModuleProject '' -AliasName 'Foo' -AliasMappedFunction 'Write-Output' -WhatIf } | Should -Throw -PassThru
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }
    
        it 'throws error if command does not exist' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Add-ModuleAlias -ModuleProject $ViableModule -AliasName 'foo' -AliasMappedFunction "Write-Foo$(Get-Random)" -WhatIf } | Should -Throw -PassThru
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'CommandDoesNotExistException'
        }

        it 'throws error if Alias is empty' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Add-ModuleAlias -ModuleProject $ViableModule -AliasName '' -AliasMappedFunction 'Write-Output' -WhatIf } | Should -Throw -PassThru
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }
    
        it 'throws error if alias already exists' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName $ViableModule -AliasName 'Foo'
    
            $err = { Add-ModuleAlias -ModuleProject $ViableModule -AliasName 'Foo' -AliasMappedFunction 'Write-Output' -WhatIf } | Should -Throw -PassThru
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandExistsException'
        }

        it 'throws error if alias already exists in other module' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName 'Test' -AliasName 'Foo'
    
            $err = { Add-ModuleAlias -ModuleProject $ViableModule -AliasName 'Foo' -AliasMappedFunction 'Write-Output' -WhatIf } | Should -Throw -PassThru
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandExistsException'
        }

        it 'throws error if AliasMappedCommand is empty' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Add-ModuleAlias -ModuleProject $ViableModule -AliasName 'Foo' -AliasMappedFunction '' -WhatIf } | Should -Throw -PassThru
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }
    
        it 'throws error if AliasMappedCommand does not exist' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Add-ModuleAlias -ModuleProject $ViableModule -AliasName 'Foo' -AliasMappedFunction 'Foo-Bar' -WhatIf } | Should -Throw -PassThru
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'CommandDoesNotExistException'
        }
    
    }

    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Module' {
            Add-TestModule -Name $ViableModule -Valid

            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Add-ModuleAlias -ParameterName ModuleProject)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke()} catch {}
    
            $Arguments = @($ViableModule)| Should -BeTrue
        }
    }

    describe 'functionality' {
        it 'Should create an alias in a module' {
            $AliasName = 'foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-ModuleAlias -ModuleProject $ViableModule -AliasName $AliasName -AliasMappedFunction 'Write-Output'
    
            Test-Path (Get-ModuleProjectAliasPath -ModuleProject $ViableModule -CommandName $AliasName) | Should -BeTrue
        }
    
        it 'Should create an alias with the standard text' {
            $AliasName = 'foo'
            $AliasMappedFunction = 'Write-Output'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-ModuleAlias -ModuleProject $ViableModule -AliasName $AliasName -AliasMappedFunction $AliasMappedFunction
    
            $AliasPath = Get-ModuleProjectAliasPath -ModuleProject $ViableModule -CommandName $AliasName
            . "$AliasPath"
    
            $Alias = Get-Item "alias:\$AliasName"
            $Alias.Definition | Should -Be $AliasMappedFunction
        }
    
        it 'Should try to import the module again' {
            $AliasName = 'foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-ModuleAlias -ModuleProject $ViableModule -AliasName $AliasName -AliasMappedFunction 'Write-Output'
    
            Assert-MockCalled Import-Module -Times 1 -ParameterFilter {$Force -eq $True -and $Name -eq $BaseModuleName -and $Global -eq $True}
        }
    
        it 'Should try to update the ModuleProject' {
            $AliasName = 'foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            Add-ModuleAlias -ModuleProject $ViableModule -AliasName $AliasName -AliasMappedFunction 'Write-Output'
    
            Assert-MockCalled Update-ModuleProject -Times 1 -ParameterFilter {$ModuleProject -eq $ViableModule}
        }
    }
}