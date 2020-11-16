describe 'Move-ModuleCommand' {
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

        . "$PSScriptRoot\Remove-ModuleCommand.ps1"
        . "$PSScriptRoot\Move-ModuleCommand.ps1"

        $ViableModule = "Viable"
        $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'
        Remove-Sandbox
    }
    BeforeEach {
        New-Sandbox

        Mock Import-Module
    }
    AfterEach {
        Remove-Sandbox
    }
    AfterAll {
        Remove-Sandbox
    }

    describe 'validations' {

        it 'throws error if source ModuleProject is null' {
            $err = { Move-ModuleCommand -ModuleProject '' -CommandName 'Get-Foo' -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru

            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if source ModuleProject does not exist' {   
            $err = { Move-ModuleCommand -ModuleProject $ViableModule -CommandName 'Get-Foo' -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }
    
        it 'throws error if CommandName is null' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Move-ModuleCommand -ModuleProject $ViableModule -CommandName '' -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru
            
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if function does not exist in source ModuleProject' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Move-ModuleCommand -ModuleProject $ViableModule -CommandName 'Get-Foo' -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
        }
    
        it 'throws error if Destination ModuleProject is null' {
            $FunctionName = 'Get-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText 'Write-Output "Hello World"'

            $err = { Move-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject '' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if destination ModuleProject does not exist' {
            $FunctionName = 'Get-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText 'Write-Output "Hello World"'
    
            $err = { Move-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
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
            $FakeBoundParameters = @{'ModuleProject'=$ViableModule}
            Mock Get-ValidModuleProjectNames {return $ViableModule}
            Mock Get-ModuleProjectFunctionNames
            Mock Get-ModuleProjectAliasNames

            $Arguments = (Get-ArgumentCompleter -CommandName Move-ModuleCommand -ParameterName CommandName)
            
            try {$Arguments.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            Assert-MockCalled Get-ModuleProjectFunctionNames -Times 1
            Assert-MockCalled Get-ModuleProjectAliasNames -Times 1
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
            throw [System.NotImplementedException]
        }
    
        it 'moves command into destination module if alias' {
            throw [System.NotImplementedException]
        }
    
        it 'removes command from source module if function' {
            throw [System.NotImplementedException]
        }
        
        it 'removes command from source module if alias' {
            throw [System.NotImplementedException]
        }
        
        it 'attempts to update sourceModuleProject with removed Function or alias' {
            throw [System.NotImplementedException]
        }
    
        it 'attempts to update DestinationModuleProject with new Function or alias' {
            throw [System.NotImplementedException]
        }
    
        it 'attempts to update sourceModuleProject with new Functions and aliases' {
            throw [System.NotImplementedException]
        }
        
        it 'Should try to re-import the ModuleProject' {
            throw [System.NotImplementedException]
    
            Assert-MockCalled Import-Module -Times 1 -ParameterFilter {$Name -eq $BaseModuleName -and $Force -eq $True}
        }        
    }

}