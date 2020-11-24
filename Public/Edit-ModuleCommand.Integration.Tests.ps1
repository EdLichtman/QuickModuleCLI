describe 'Edit-ModuleCommand' {
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

    describe 'validations' {
        it 'throws error if module does not exist' {
            $err = {  Edit-ModuleCommand -ModuleProject $ViableModule -CommandName 'Write-Test2' } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }
    
        it 'throws error if CommandName is null' {
           
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Edit-ModuleCommand -ModuleProject $ViableModule -CommandName '' } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if CommandName does not exist' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
    
            $err = { Edit-ModuleCommand -ModuleProject $ViableModule -CommandName 'Write-Test' } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
        }

        it 'throws error if ModuleProject does not contain the CommandName ' {
            $FunctionName = 'Write-Test'
            $FunctionText = 'Write-Output "Test"'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName 'Test' -FunctionName $FunctionName -FunctionText  $FunctionText
    
            $err = { Edit-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Not -Be $ParameterBindingException
            $err.Exception.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
        }
    }

    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Module' {
            Add-TestModule $ViableModule -Valid
            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Edit-ModuleCommand -ParameterName ModuleProject)
            
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

            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Edit-ModuleCommand -ParameterName CommandName)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            $Arguments | Should -Be @('Foo-Bar','Bar')
        }

        it 'auto-suggests valid Module Command for CommandName without ModuleProject' {
            $FakeBoundParameters = @{}
            Add-TestModule $ViableModule -Valid
            Add-TestFunction $ViableModule 'Foo-Bar' 
            Add-TestModule 'Test' -Valid
            Add-TestAlias 'Test' 'Bar'

            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Edit-ModuleCommand -ParameterName CommandName)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke($Null,$Null,'',$Null,$FakeBoundParameters)} catch {}
    
            $Arguments | Should -Be @('Bar','Foo-Bar')
        }
    }
    describe 'functionality' {
        it 'Can be run without a ModuleProject' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
    
            Mock Open-PowershellEditor
            Mock Wait-ForKeyPress
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Edit-ModuleCommand -CommandName $FunctionName
            
            Assert-MockCalled Open-PowershellEditor -Times 1
        }
        it 'Attempts to Open Powershell Editor' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
    
            Mock Open-PowershellEditor
            Mock Wait-ForKeyPress
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Edit-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName
            
            Assert-MockCalled Open-PowershellEditor -Times 1
        }
    
        it 'Attempts to Open Powershell Editor' {
            $FunctionName = 'Write-Foo'
            $FunctionText = "return 'Foo'"
    
            Mock Open-PowershellEditor
            Mock Wait-ForKeyPress
    
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText
    
            Edit-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName
            
            Assert-MockCalled Wait-ForKeyPress -Times 1
        }
    }
}