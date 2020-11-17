describe 'Remove-ModuleProject' {
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

        . "$PSScriptRoot\Remove-ModuleProject.ps1"

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
        BeforeEach {
            Mock Remove-ModuleProjectFolder
        }
        it 'throws error if ModuleProject is null' {
            $err = {  Remove-ModuleProject -ModuleProject '' -WhatIf} | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if module does not exist' {
            $err = {  Remove-ModuleProject -ModuleProject $ViableModule -WhatIf} | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }    
    }

    describe 'functionality' {
        it 'Attempts to Remove-Item with confirmation' {
            Mock Remove-ModuleProjectFolder

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Write-Foo' -FunctionText  "return 'Foo'"
    
            $ExpectedPath = Get-ModuleProjectLocation -ModuleProject $ViableModule
            Remove-ModuleProject -ModuleProject $ViableModule 
            
            Assert-MockCalled Remove-ModuleProjectFolder -Times 1 -ParameterFilter { $ModuleProject -eq $ViableModule}
        }
    
        it 'Removes ModuleProject if choice is confirmed' {
            Mock Confirm-Choice -MockWith {return $True}
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Write-Foo' -FunctionText  "return 'Foo'"
    
            Remove-ModuleProject -ModuleProject $ViableModule

            (Get-ValidModuleProjects).Count | Should -Be 0
        }

        it 'Removes ModuleProject if choice is not confirmed' {
            Mock Confirm-Choice -MockWith {return $False}
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Write-Foo' -FunctionText  "return 'Foo'"
    
            Remove-ModuleProject -ModuleProject $ViableModule

            (Get-ValidModuleProjects).Name | Should -Be $ViableModule
        }
    }

    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Module' {
            Mock Get-ValidModuleProjectNames
            $Arguments = (Get-ArgumentCompleter -CommandName Remove-ModuleProject -ParameterName ModuleProject)
            
            try {$Arguments.Definition.Invoke()} catch {}
    
            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }
    }
}