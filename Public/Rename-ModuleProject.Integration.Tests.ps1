describe 'Rename-ModuleProject' {
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

        . "$PSScriptRoot\Rename-ModuleProject.ps1"

        $ViableModule = "Viable"
        $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'
        Remove-Sandbox
    }
    BeforeEach {
        New-Sandbox
        Mock Import-Module
        Mock Edit-ModuleManifest
    }
    AfterEach {
        Remove-Sandbox
    }
    AfterAll {
        Remove-Sandbox
    }

    describe 'validations' {
        BeforeEach {
            Mock Rename-Item
        }
        it 'throws error if SourceModuleProject is null' {
            $err = {  Rename-ModuleProject -SourceModuleProject '' -DestinationModuleProject 'Foo' -WhatIf } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if SourceModuleProject does not exist' {
            $err = {  Rename-ModuleProject -SourceModuleProject $ViableModule -DestinationModuleProject 'Foo' -WhatIf} | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }    

        it 'throws error if DestinationModuleProject is null' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            $err = {  Rename-ModuleProject -SourceModuleProject $ViableModule -DestinationModuleProject '' -WhatIf } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if DestinationModuleProject exists' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Foo' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            $err = {  Rename-ModuleProject -SourceModuleProject $ViableModule -DestinationModuleProject 'Foo' -WhatIf } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectExistsException'
        }
    }

    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Module' {
            Add-TestModule $ViableModule -Valid
            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Rename-ModuleProject -ParameterName SourceModuleProject)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke()} catch {}
    
            $Arguments | Should -Be @($ViableModule)
        }
    }

    describe 'functionality' {
        it 'renames the ModuleProject and all the internals' {
            $ExpectedDestinationModuleProject = 'Test'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Write-Foo' -FunctionText  "return 'Foo'"

            (GetValidModuleProject).Count | Should -Be 1
            (GetModuleProjectInfo $ViableModule) | Should -Not -Be $Null

            Rename-ModuleProject -SourceModuleProject $ViableModule -DestinationModuleProject $ExpectedDestinationModuleProject
            
            $ModuleProjects = GetValidModuleProject
            $ModuleProjects.Count | Should -Be 1
            $ModuleProjects.Name | Should -Be $ExpectedDestinationModuleProject

            $Files = ($ModuleProjects.GetFiles()).Name
            $Directories = ($ModuleProjects.GetDirectories()).Name
            "$ExpectedDestinationModuleProject.psd1" -in $Files | Should -BeTrue
            "$ExpectedDestinationModuleProject.psm1" -in $Files | Should -BeTrue
            "Functions" -in $Directories | Should -BeTrue
            "Aliases" -in $Directories | Should -BeTrue
        }

        it 'attempts to Edit the module manifest with a new RootModule' {
            $ExpectedDestinationModuleProject = 'Test'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Write-Foo' -FunctionText  "return 'Foo'"

            (GetModuleProjectInfo $ViableModule) | Should -Not -Be $Null

            Rename-ModuleProject -SourceModuleProject $ViableModule -DestinationModuleProject $ExpectedDestinationModuleProject

            $DestinationModuleProjectLocation = Get-ModuleProjectLocation -ModuleProject $ExpectedDestinationModuleProject
            $expectedPsd1Location = "$DestinationModuleProjectLocation\$ExpectedDestinationModuleProject.psd1"
            $expectedRootModule = "$ExpectedDestinationModuleProject.psm1"
            Assert-MockCalled Edit-ModuleManifest -ParameterFilter { $RootModule -eq $expectedRootModule -and $psd1Location -eq $expectedPsd1Location }
        }
    
        it 'Should try to re-import the ModuleProject' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Write-Foo' -FunctionText 'Write-Output "Hello World"' -WhatIf
    
            Rename-ModuleProject -SourceModuleProject $ViableModule -DestinationModuleProject 'Test'

            Assert-MockCalled Import-Module -Times 1 -ParameterFilter {$Name -eq $BaseModuleName -and $Force -eq $True -and $Global -eq $True}
        }
    }
}