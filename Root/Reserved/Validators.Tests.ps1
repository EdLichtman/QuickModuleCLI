Describe 'Validators' {
    BeforeAll {
        . "$PSScriptRoot\_TestEnvironment.ps1"

        . "$PSScriptRoot\Variables.ps1"
        . "$PSScriptRoot\Environment.ps1"
        . "$PSScriptRoot\ArgumentCompleters.ps1"
        . "$PSScriptRoot\Validators.ps1"
        . "$PSScriptRoot\PrivateFunctions.ps1"
        
        <# ENVIRONMENT VARIABLES #>
        $BaseModuleName = "QuickModuleCLITests"
        $BaseFolder =  Get-SandboxBaseFolder
        $NestedModulesFolder = Get-SandboxNestedModulesFolder
        $FunctionsFolder = Get-SandboxFunctionsFolder
        $PrivateFunctionsFolder = Get-SandboxPrivateFunctionsFolder

        $ViableModule = "Viable"
        $NonviableModule = "Nonviable"
        Remove-Sandbox
    }
    BeforeEach {
        New-Sandbox
    }
    AfterEach {
        Remove-Sandbox
    }
    AfterAll {
        Remove-Sandbox
    }
    Describe 'Assert-ModuleProjectExists' {
        BeforeEach {
            function Test-Function{
                param(
                    [ValidateScript({(Assert-ModuleProjectExists)})]
                    [String]
                    $ModuleProject
                )
                # Some mild hackery because the $_ cannot be obtained from pipeline in ValidateScript
            }

            $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'
        }

        it 'Errors if no modules exist' {
            { Test-Function -ModuleProject $ViableModule } | Should -Throw -ExceptionType $ParameterBindingException
        }

        it 'Errors if Module does not exist' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot
            { Test-Function -ModuleProject $NonViableModule } | Should -Throw -ExceptionType $ParameterBindingException
        }

        it 'Does not error if Module is valid' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot
            { Test-Function -ModuleProject $ViableModule } | Should -Not -Throw -ExceptionType $ParameterBindingException
        }
    }

    describe 'Assert-ModuleProjectDoesNotExist' {
        BeforeEach {
            function Test-Function{
                param(
                    [ValidateScript({(Assert-ModuleProjectDoesNotExist)})]
                    [String]
                    $ModuleProject
                )
                # Some mild hackery because the $_ cannot be obtained from pipeline in ValidateScript
            }

            $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'
        }

        it 'Errors if no modules exist' {
            { Test-Function -ModuleProject $ViableModule } | Should -Not -Throw -ExceptionType $ParameterBindingException
        }

        it 'Errors if Module does not exist' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot
            { Test-Function -ModuleProject $NonViableModule } | Should -Not -Throw -ExceptionType $ParameterBindingException
        }

        it 'Does not error if Module is valid' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot
            { Test-Function -ModuleProject $ViableModule } | Should -Throw -ExceptionType $ParameterBindingException
        }
    }
}