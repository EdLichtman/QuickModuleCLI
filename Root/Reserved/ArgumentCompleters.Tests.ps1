Describe 'ArgumentCompleters' {
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
   
    describe 'Get-ModuleProjectChoices' {
        It 'Throws Error if no viable modules exist' {
            { Get-ModuleProjectChoices } | Should -Throw -ExceptionType 'System.Management.Automation.ItemNotFoundException'
        }

        It 'Does not consider a folder without psd1 and psm1 as a viable module' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot
            Add-TestModule -Name $NonViableModule

            Get-ModuleProjectChoices | Should -not -contain $NonViableModule
        }

        It 'Does not consider a folder without psd1 as a viable module' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot
            Add-TestModule -Name $NonViableModule -IncludeRoot

            Get-ModuleProjectChoices | Should -not -contain $NonViableModule
        }

        It 'Does not consider a folder without psm1 as a viable module' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot
            Add-TestModule -Name $NonViableModule -IncludeManifest

            Get-ModuleProjectChoices | Should -not -contain $NonViableModule
        }


        It 'Does not throw error if a viable module exists' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot

            { Get-ModuleProjectChoices } | Should -Not -Throw -ExceptionType 'System.Management.Automation.ItemNotFoundException'
        }

        It 'Considers a folder with psd1 and psm1 as a viable module' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot

            Get-ModuleProjectChoices | Should -contain $ViableModule
        }
    }
}