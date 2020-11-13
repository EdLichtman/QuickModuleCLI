describe 'Remove-ModuleCommand' {
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

    it 'throws error if ModuleProject does not exist' {
        Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

        $err = { Remove-ModuleCommand -ModuleProject $ViableModule -CommandName 'Get-Foo' -WhatIf } | Should -Throw -PassThru
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
    }


    it 'throws error if ModuleProject is null' {
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

        $err = { Remove-ModuleCommand -ModuleProject '' -CommandName 'Get-Foo' -WhatIf } | Should -Throw -PassThru
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
    }


    it 'throws error if function does not exist' {
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

        $err = { Remove-ModuleCommand -ModuleProject $ViableModule -CommandName 'Get-Foo' -WhatIf } | Should -Throw -PassThru
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
    }

    it 'throws error if function is null' {
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

        $err = { Remove-ModuleCommand -ModuleProject $ViableModule -CommandName '' -WhatIf } | Should -Throw -PassThru
        $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
    }

    it 'throws error if function does not exist in ModuleProject' {
        Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
        Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

        Add-TestFunction -ModuleName 'Test' -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"

        $err = { Remove-ModuleCommand -ModuleProject $ViableModule -CommandName 'Get-Foo' -WhatIf } | Should -Throw -PassThru
        $err.Exception.GetType().Name | Should -Be 'ModuleCommandDoesNotExistException'
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