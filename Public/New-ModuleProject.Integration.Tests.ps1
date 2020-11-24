describe 'New-ModuleProject' {
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

        . "$PSScriptRoot\New-ModuleProject.ps1"

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
        Teardown-Sandbox
    }

    it 'throws error if project already exists' {
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

        $err = { New-ModuleProject -ModuleProject $ViableModule -WhatIf } | Should -Throw -PassThru
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectExistsException'
    }

    
    it 'creates a new module project' {
        New-ModuleProject -ModuleProject $ViableModule
        
        $ModuleProject = (GetValidModuleProject)[0]

        $Internals = (Get-ChildItem $ModuleProject.FullName).Name
        ("$ViableModule.psd1" -in $Internals) | Should -Be $True
        ("$ViableModule.psm1" -in $Internals) | Should -Be  $True
        ("Functions" -in $Internals) | Should -Be $True
        ("Aliases" -in $Internals) | Should -Be $True
    }

    it 'Re-imports Module' {
        New-ModuleProject -ModuleProject $ViableModule

        Assert-MockCalled Import-Module -Times 1 -ParameterFilter {$Name -eq $BaseModuleName -and $Force -eq $True -and $Global -eq $True}
    }
}