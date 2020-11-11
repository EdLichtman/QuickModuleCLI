describe 'Add-ModuleFunction' {
    BeforeAll {
        . "$PSScriptRoot\..\Private\_TestEnvironment.ps1"
        
        <# ENVIRONMENT VARIABLES #>
        $BaseModuleName = "QuickModuleCLITests"
        $BaseFolder =  Get-SandboxBaseFolder
        $ModuleProjectsFolder = Get-SandboxNestedModulesFolder
        $FunctionsFolder = Get-SandboxFunctionsFolder
        $PrivateFunctionsFolder = Get-SandboxPrivateFunctionsFolder

        . "$PSScriptRoot\..\Private\Environment.ps1"
        . "$PSScriptRoot\..\Private\ArgumentCompleters.ps1"
        . "$PSScriptRoot\..\Private\ArgumentTransformations.ps1"
        . "$PSScriptRoot\..\Private\Validators.ps1"
        
        . "$PSScriptRoot\Edit-ModuleCommand.ps1"

        $ViableModule = "Viable"
        $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'
    }

    it 'throws error if module does not exist' {
        Mock Get-ValidModuleProjectNames { return @() }
        $err = {  Edit-ModuleCommand -ModuleProject $ViableModule -CommandName 'Write-Test2' } | Should -Throw -PassThru

        $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
    }

    it 'throws error if ModuleProject does not contain the CommandName ' {
        $Function = 'Write-Foo'
        $MockFunctionFile = Get-MockFileInfo -BaseName $Function
        Mock Get-ValidModuleProjectNames { return @($ViableModule, 'Test') }
        Mock Get-ModuleProjectFunctions { return @($MockFunctionFile) } -ParameterFilter {$ModuleProject -eq 'Test' }
        Mock Get-ModuleProjectFunctions { return @()}
        Mock Get-ModuleProjectAliases { return @()}

        $err = { Edit-ModuleCommand -ModuleProject $ViableModule -CommandName 'Write-Test2' } | Should -Throw -PassThru

        $err.Exception.GetType().BaseType | Should -Not -Be $ParameterBindingException
        $err.Exception.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
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