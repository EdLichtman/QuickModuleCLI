describe 'Move-ModuleCommand' {
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
        . "$PSScriptRoot\Move-ModuleCommand.ps1"

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
            $err = { Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName 'Get-Foo' -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }
    
        it 'throws error if CommandName is null' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName '' -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru
            
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if function does not exist in source ModuleProject' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            $err = { Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName 'Get-Foo' -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
        }
    
        it 'throws error if Destination ModuleProject is null' {
            $FunctionName = 'Get-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText 'Write-Output "Hello World"'

            $err = { Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject '' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if destination ModuleProject does not exist' {
            $FunctionName = 'Get-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText 'Write-Output "Hello World"'
    
            $err = { Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }
        it 'throws error if source ModuleProject is same as destination ModuleProject' {
            $FunctionName = 'Get-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText 'Write-Output "Hello World"'
    
            $err = { Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $ViableModule -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Not -Be $ParameterBindingException
            $err.Exception.GetType().Name | Should -Be 'ModuleCommandMoveDestinationIsInvalidException'
        }
    }
    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Source Module' {
            Mock Get-ValidModuleProjectNames
            $Arguments = (Get-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName SourceModuleProject)
            
            try {$Arguments.Definition.Invoke()} catch {}
    
            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }

        it 'auto-suggests valid Module Command for CommandName' {
            $FakeBoundParameters = @{'SourceModuleProject'=$ViableModule}
            Mock Get-ValidModuleProjectNames {return $ViableModule}
            Mock Get-ModuleProjectFunctionNames
            Mock Get-ModuleProjectAliasNames

            $Arguments = (Get-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName CommandName)
            
            try {$Arguments.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            Assert-MockCalled Get-ModuleProjectFunctionNames -Times 1
            Assert-MockCalled Get-ModuleProjectAliasNames -Times 1
        }

        it 'auto-suggests valid Module Command for CommandName with no SourceModuleProject' {
            $FakeBoundParameters = @{}
            Mock Get-ValidModuleProjectNames {return $ViableModule, 'Test'}
            Mock Get-ModuleProjectFunctionNames
            Mock Get-ModuleProjectAliasNames

            $Arguments = (Get-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName CommandName)
            
            try {$Arguments.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            Assert-MockCalled Get-ModuleProjectFunctionNames -Times 2
            Assert-MockCalled Get-ModuleProjectAliasNames -Times 2
        }

        it 'auto-suggests valid Module Arguments for Destination Module' {
            Mock Get-ValidModuleProjectNames
            $Arguments = (Get-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName DestinationModuleProject)
            
            try {$Arguments.Definition.Invoke()} catch {}
    
            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }
    }
    describe 'functionality' {
        it 'moves command into destination module if function' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject 'Test'
    
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject 'Test' -CommandName $FunctionName) | Should -BeTrue
        }
    
        it 'moves command into destination module if alias' {
            $Alias = 'Foo'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName $ViableModule -AliasName $Alias
    
            Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $Alias -DestinationModuleProject 'Test'
    
            Test-Path (Get-ModuleProjectAliasPath -ModuleProject 'Test' -CommandName $Alias) | Should -BeTrue
        }
    
        it 'removes command from source module if function' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject 'Test'
    
            Test-Path (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName $FunctionName) | Should -BeFalse
        }
        
        it 'removes command from source module if alias' {
            $Alias = 'Foo'
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName $ViableModule -AliasName $Alias
    
            Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $Alias -DestinationModuleProject 'Test'
    
            Test-Path (Get-ModuleProjectAliasPath -ModuleProject $ViableModule -CommandName $Alias) | Should -BeFalse
        }
        
        it 'attempts to update sourceModuleProject with removed Function or alias' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $DestinationModule = 'Test'

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $DestinationModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $DestinationModule
    
            Assert-MockCalled Update-ModuleProject -Times 1 -ParameterFilter {$ModuleProject -eq $ViableModule}
        }
    
        it 'attempts to update DestinationModuleProject with new Function or alias' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $DestinationModule = 'Test'

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $DestinationModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $DestinationModule
    
            Assert-MockCalled Update-ModuleProject -Times 1 -ParameterFilter {$ModuleProject -eq $DestinationModule}
        }
    
        it 'Should try to re-import the ModuleProject' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
            $DestinationModule = 'Test'

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $DestinationModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Move-ModuleCommand -SourceModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject $DestinationModule
    
            Assert-MockCalled Import-Module -Times 1 -ParameterFilter {$Name -eq $BaseModuleName -and $Force -eq $True -and $Global -eq $True}
        }        
    }

}