describe 'Private Functions' {
    BeforeAll {
        . "$PSScriptRoot\_TestEnvironment.ps1"
        Test-BeforeAll
    }
    BeforeEach {
        Test-BeforeEach
    }
    AfterEach {
        Test-AfterEach
    }
    AfterAll {
        Test-AfterAll
    }
    <# INTERNAL FUNCTIONS #>
    describe 'New-FileWithContent' {

    }

    describe 'Get-NestedModuleLocation' {
        it "Gets the child folder of the NestedModulesFolder" {
            $NestedModule = "Test"
            $NestedModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule

            $NestedModuleLocation | Should -Be "$(Get-SandboxNestedModulesFolder)\$NestedModule"
        }

        it "Gets the expected child folder even if the folder doesn't exist" {
            $NestedModule = "Test"
            $NestedModuleLocation = Get-NestedModuleLocation -NestedModule $NestedModule

            (Test-Path $NestedModuleLocation) | Should -Be $false
        }
    }

    describe 'Get-NestedModules' {

    }

    describe 'Get-ModuleFunctionLocations' {

    }

    describe 'Get-ModuleAliasesLocations' {

    }
    describe 'Get-ModuleFunctions' {

    }

    describe 'Get-ModuleAliases' {

    }

    describe 'Get-ModuleFunctionsLocation' {

    }

    describe 'Get-ModuleAliasesLocation' {

    }

    describe 'Get-ModuleFunctionLocation' {

    }

    describe 'Get-ModuleAliasLocation' {

    }


    describe 'Get-ProfileModulesDirectory' {

    }

    <# Assertions: Throw Errors if False#>
    describe 'Assert-CanCreateModuleCommand' {

    }

    describe 'Assert-CanFindCommand' {       
        it "Can find if a global command exists" {
            { Assert-CanFindCommand -CommandName Write-Output } | Should -Not -Throw
        }
        it "Can find if a global command does not exist" {
            { Assert-CanFindCommand -CommandName Write-WibbityWobbity } | Should -Throw -ExceptionType 'System.Management.Automation.CommandNotFoundException'
        }
    }

    describe 'Assert-CanFindModuleCommand' {
        it "Can find if a quick function exists" {
            $NestedModuleFolder = "$(Get-SandboxNestedModulesFolder)\Test"
            New-Item $NestedModuleFolder -ItemType Directory -Force
            New-Item "$NestedModuleFolder\Functions" -ItemType Directory -Force
            New-Item "$NestedModuleFolder\Functions\Write-AssertCanFindModuleCommand.ps1" -ItemType File -Force

            { Assert-CanFindModuleCommand -NestedModule 'Test' -CommandName Write-AssertCanFindModuleCommand } | Should -Not -Throw
        }

        it "Can find if a quick alias exists" {
            $NestedModuleFolder = "$(Get-SandboxNestedModulesFolder)\Test"
            New-Item $NestedModuleFolder -ItemType Directory -Force
            New-Item "$NestedModuleFolder\Aliases" -ItemType Directory -Force
            New-Item "$NestedModuleFolder\Aliases\AssertCanFindModuleCommand.ps1" -ItemType File -Force

            { Assert-CanFindModuleCommand -NestedModule 'Test' -CommandName AssertCanFindModuleCommand } | Should -Not -Throw
        }

        it "Can find if a quick command does not exist" {
            { Assert-CanFindModuleCommand -NestedModule 'Test' -CommandName Write-AssertCantFindModuleCommand } | Should -Throw -ExceptionType 'System.Management.Automation.ItemNotFoundException'
        }
    }

    describe 'Assert-CanCreateModule' {

    }

    describe 'Assert-ModuleAlreadyExists' {

    }


    describe 'Edit-ModuleManifest' {

    }
    describe 'Update-ModuleProjectCLI' {

    }
}
