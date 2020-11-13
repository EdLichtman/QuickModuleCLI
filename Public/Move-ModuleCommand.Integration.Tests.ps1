describe 'Move-ModuleCommand' {
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

        . "$PSScriptRoot\Remove-ModuleCommand.ps1"
        . "$PSScriptRoot\Move-ModuleCommand.ps1"

        $ViableModule = "Viable"
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

    it 'throws error if source ModuleProject does not exist' {
        Mock Remove-ModuleCommand
        Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

        $err = { Move-ModuleCommand -ModuleProject $ViableModule -CommandName 'Get-Foo' -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
    }

    
    it 'throws error if function does not exist in source ModuleProject' {
        Mock Remove-ModuleCommand
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

        $err = { Move-ModuleCommand -ModuleProject $ViableModule -CommandName 'Get-Foo' -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
    }

    it 'throws error if destination ModuleProject does not exist' {
        Mock Remove-ModuleCommand
        $FunctionName = 'Get-Foo'
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName -FunctionText 'Write-Output "Hello World"'

        $err = { Move-ModuleCommand -ModuleProject $ViableModule -CommandName $FunctionName -DestinationModuleProject 'Test' -WhatIf } | Should -Throw -PassThru
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
    }


    
    # it 'creates a new module project' {
    #     New-ModuleProject -ModuleProject $ViableModule
        
    #     $ModuleProject = (Get-ValidModuleProjects)[0]

    #     $Internals = (Get-ChildItem $ModuleProject.FullName).Name
    #     ("$ViableModule.psd1" -in $Internals) | Should -Be $True
    #     ("$ViableModule.psm1" -in $Internals) | Should -Be  $True
    #     ("Functions" -in $Internals) | Should -Be $True
    #     ("Aliases" -in $Internals) | Should -Be $True
    # }
}