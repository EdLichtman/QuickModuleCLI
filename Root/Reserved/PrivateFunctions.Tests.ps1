describe 'Private Functions' {
    BeforeAll {
        . "$PSScriptRoot\PrivateFunctions.ps1"

        function Get-SandboxBaseFolder { return "$PSScriptRoot\..\..\Tests\Sandbox"; }
        function Get-SandboxNestedModulesFolder { return "$(Get-SandboxBaseFolder)\Modules"; }
        function Get-SandboxFunctionsFolder { return "$(Get-SandboxBaseFolder)\Root"; }
        function Get-SandboxPrivateFunctionsFolder { return "$(Get-SandboxFunctionsFolder)\Reserved" }
        
        <# ENVIRONMENT VARIABLES #>
        $BaseModuleName = "QuickModuleCLITests"
        $BaseFolder =  Get-SandboxBaseFolder
        $NestedModulesFolder = Get-SandboxNestedModulesFolder
        $FunctionsFolder = Get-SandboxFunctionsFolder
        $PrivateFunctionsFolder = Get-SandboxPrivateFunctionsFolder
        

        New-Item -Path (Get-SandboxBaseFolder) -ItemType Directory
        New-Item -Path (Get-SandboxNestedModulesFolder) -ItemType Directory
        New-Item -Path (Get-SandboxFunctionsFolder) -ItemType Directory
        New-Item -Path (Get-SandboxPrivateFunctionsFolder) -ItemType Directory
    }

    BeforeEach {
        
    }

    AfterAll {
        $SandboxBase = Get-SandboxBaseFolder
        if (![String]::IsNullOrWhiteSpace($SandboxBase)) {
            Remove-Item -Path $SandboxBase -Recurse -Force
        } else {
            throw 'Scoping Exception! Get-SandboxBaseFolder is empty!'
        }
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

    describe 'Get-QuickFunctionLocations' {

    }

    describe 'Get-QuickAliasesLocations' {

    }
    describe 'Get-QuickFunctions' {

    }

    describe 'Get-QuickAliases' {

    }

    describe 'Get-QuickFunctionsLocation' {

    }

    describe 'Get-QuickAliasesLocation' {

    }

    describe 'Get-QuickFunctionLocation' {

    }

    describe 'Get-QuickAliasLocation' {

    }


    describe 'Get-ProfileModulesDirectory' {

    }

    <# Assertions: Throw Errors if False#>
    describe 'Assert-CanCreateQuickCommand' {

    }

    describe 'Assert-CanFindCommand' {       
        it "Can find if a global command exists" {
            { Assert-CanFindCommand -CommandName Write-Output } | Should -Not -Throw
        }
        it "Can find if a global command does not exist" {
            { Assert-CanFindCommand -CommandName Write-WibbityWobbity } | Should -Throw -ExceptionType 'System.Management.Automation.CommandNotFoundException'
        }
    }

    describe 'Assert-CanFindQuickCommand' {
        it "Can find if a quick function exists" {
            $NestedModuleFolder = "$(Get-SandboxNestedModulesFolder)\Test"
            New-Item $NestedModuleFolder -ItemType Directory -Force
            New-Item "$NestedModuleFolder\Functions" -ItemType Directory -Force
            New-Item "$NestedModuleFolder\Functions\Write-AssertCanFindQuickCommand.ps1" -ItemType File -Force

            { Assert-CanFindQuickCommand -NestedModule 'Test' -CommandName Write-AssertCanFindQuickCommand } | Should -Not -Throw
        }

        it "Can find if a quick alias exists" {
            $NestedModuleFolder = "$(Get-SandboxNestedModulesFolder)\Test"
            New-Item $NestedModuleFolder -ItemType Directory -Force
            New-Item "$NestedModuleFolder\Aliases" -ItemType Directory -Force
            New-Item "$NestedModuleFolder\Aliases\AssertCanFindQuickCommand.ps1" -ItemType File -Force

            { Assert-CanFindQuickCommand -NestedModule 'Test' -CommandName AssertCanFindQuickCommand } | Should -Not -Throw
        }

        it "Can find if a quick command does not exist" {
            { Assert-CanFindQuickCommand -NestedModule 'Test' -CommandName Write-AssertCantFindQuickCommand } | Should -Throw -ExceptionType 'System.Management.Automation.ItemNotFoundException'
        }
    }

    describe 'Assert-CanCreateModule' {

    }

    describe 'Assert-ModuleAlreadyExists' {

    }

    describe 'Edit-ModuleManifest' {

    }
    describe 'Update-QuickModuleCLI' {

    }


}
