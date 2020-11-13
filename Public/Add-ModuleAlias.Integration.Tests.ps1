describe 'Add-ModuleAlias' {
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
        . "$PSScriptRoot\..\Private\Validators.Exceptions.ps1"
        . "$PSScriptRoot\..\Private\Validators.ps1"

        . "$PSScriptRoot\Add-ModuleAlias.ps1"

        $ViableModule = "Viable"
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

    it 'Should create an alias in a module' {
        $AliasName = 'foo'
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

        Add-ModuleAlias -ModuleProject $ViableModule -AliasName $AliasName -AliasMappedFunction 'Write-Output'

        Test-Path (Get-ModuleProjectAliasPath -ModuleProject $ViableModule -CommandName $AliasName) | Should -BeTrue
    }

    it 'Should create an alias with the standard text' {
        $AliasName = 'foo'
        $AliasMappedFunction = 'Write-Output'
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

        Add-ModuleAlias -ModuleProject $ViableModule -AliasName $AliasName -AliasMappedFunction $AliasMappedFunction

        $AliasPath = Get-ModuleProjectAliasPath -ModuleProject $ViableModule -CommandName $AliasName
        . "$AliasPath"

        $Alias = Get-Item "alias:\$AliasName"
        $Alias.Definition | Should -Be $AliasMappedFunction
    }

    it 'Should try to import the module again' {
        $AliasName = 'foo'
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

        Add-ModuleAlias -ModuleProject $ViableModule -AliasName $AliasName -AliasMappedFunction 'Write-Output'

        Assert-MockCalled Import-Module -Times 1 -ParameterFilter {$Force -eq $True -and $Name -eq $BaseModuleName}
    }
}