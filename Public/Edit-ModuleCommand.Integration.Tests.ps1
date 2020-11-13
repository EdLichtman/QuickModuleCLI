describe 'Edit-ModuleCommand' {
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

        
        . "$PSScriptRoot\Update-ModuleProject.ps1"
        . "$PSScriptRoot\Add-ModuleFunction.ps1"
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
        Remove-Sandbox
    }

    describe 'validations' {
        it 'throws error if ModuleProject is null' {
            $err = {  Edit-ModuleCommand -ModuleProject '' -CommandName 'Write-Test2' } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

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
            Add-ModuleFunction -ModuleProject 'Test' -FunctionName $FunctionName -FunctionText  $FunctionText
    
            $err = { Edit-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Not -Be $ParameterBindingException
            $err.Exception.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
        }
    
    }
    it 'Attempts to Open Powershell Editor' {
        $FunctionName = 'Write-Foo'
        $FunctionText = "return 'Foo'"

        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress

        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText

        Edit-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName
        
        Assert-MockCalled Open-PowershellEditor -Times 1
    }

    it 'Attempts to Open Powershell Editor' {
        $FunctionName = 'Write-Foo'
        $FunctionText = "return 'Foo'"

        Mock Open-PowershellEditor
        Mock Wait-ForKeyPress

        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        Add-ModuleFunction -ModuleProject $ViableModule -FunctionName $FunctionName -FunctionText  $FunctionText

        Edit-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName
        
        Assert-MockCalled Wait-ForKeyPress -Times 1
    }

    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Module' {
            Mock Get-ValidModuleProjectNames
            $Arguments = (Get-ArgumentCompleter -CommandName Edit-ModuleCommand -ParameterName ModuleProject)
            
            try {$Arguments.Definition.Invoke()} catch {}
    
            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }
    }
}