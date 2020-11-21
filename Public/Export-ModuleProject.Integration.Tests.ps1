describe 'Export-ModuleProject' {
    BeforeAll {
        . "$PSScriptRoot\..\Private\_TestEnvironment.ps1"
        
        <# ENVIRONMENT VARIABLES #>
        $BaseModuleName = "QuickModuleCLITests"
        $BaseFolder =  Get-SandboxBaseFolder
        $ModuleProjectsFolder = Get-SandboxNestedModulesFolder
        $FunctionsFolder = Get-SandboxFunctionsFolder
        $PrivateFunctionsFolder = Get-SandboxPrivateFunctionsFolder
        $PSProfileFolder = "$BaseFolder\PSProfileModules"

        . "$PSScriptRoot\..\Private\UI.ps1"
        . "$PSScriptRoot\..\Private\Environment.ps1"
        . "$PSScriptRoot\..\Private\ObjectTransformation.ps1"
        . "$PSScriptRoot\..\Private\ArgumentCompleters.ps1"
        . "$PSScriptRoot\..\Private\ArgumentTransformations.ps1"
        . "$PSScriptRoot\..\Private\Validators.ps1"
        
        . "$PSScriptRoot\Export-ModuleProject.ps1"

        $ViableModule = "Viable"
        $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'
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

    describe 'validations' {
        BeforeEach {
            Mock Copy-Item
        }
        
        it 'throws error if module does not exist' {
            $err = {  Export-ModuleProject -ModuleProject $ViableModule } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }

        it 'throws error if attempting to copy module project to ModuleProjectRoot location' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"

            $err = { Export-ModuleProject -ModuleProject $ViableModule -Path $ModuleProjectsFolder -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectExportDestinationIsInvalidException'
        }

        it 'throws error if attempting to copy module project to designated PowershellModule location' {
            Mock Get-EnvironmentModuleDirectories {return @($PSProfileFolder)}
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"

            $err = { Export-ModuleProject -ModuleProject $ViableModule -Path $PSProfileFolder -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectExportDestinationIsInvalidException'
        }
    }
    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Module' {
            Add-TestModule $ViableModule -Valid
            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Export-ModuleProject -ParameterName ModuleProject)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke()} catch {}
    
            $Arguments | Should -Be @($ViableModule)
        }
    }
    describe 'functionality' {
        it 'copies module project to new location' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"

            Export-ModuleProject -ModuleProject $ViableModule -Path $BaseFolder

            (Test-Path "$BaseFolder\$ViableModule") | Should -BeTrue
            $ExportedModuleContents = (Get-ChildItem "$BaseFolder\$ViableModule").Name
            ("$ViableModule.psd1" -in $ExportedModuleContents) | Should -Be $True
            ("$ViableModule.psm1" -in $ExportedModuleContents) | Should -Be  $True
            ("Functions" -in $ExportedModuleContents) | Should -Be $True
            ("Aliases" -in $ExportedModuleContents) | Should -Be $True
        }

        it 'keeps copy of module project in ModuleProjectRoot location' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"

            Export-ModuleProject -ModuleProject $ViableModule -Path $BaseFolder

            (Test-Path "$ModuleProjectsFolder\$ViableModule") | Should -BeTrue
        }

        it 'can be run with -force even if module has not been exported before' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"

            Export-ModuleProject -ModuleProject $ViableModule -Path $BaseFolder -force

            (Test-Path "$BaseFolder\$ViableModule\Functions\Get-Foo.ps1") | Should -BeTrue
        }

        it 'can overwrite an existing folder with -Force' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"

            Export-ModuleProject -ModuleProject $ViableModule -Path $BaseFolder

            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Bar'

            Export-ModuleProject -ModuleProject $ViableModule -Path $BaseFolder -Force

            (Test-Path "$BaseFolder\$ViableModule\Functions\Get-Bar.ps1") | Should -BeTrue
        }

        it 'Exports all ModuleProjects if given no ModuleProject Parameter' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName 'Test' -FunctionName 'Get-Bar'

            Export-ModuleProject -Path $BaseFolder

            (Test-Path "$BaseFolder\$ViableModule") | Should -BeTrue
            (Test-Path "$BaseFolder\Test") | Should -BeTrue
        }

        it 'only removes directories that it overwrites' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName 'Test' -FunctionName 'Get-Bar'

            Export-ModuleProject -Path $BaseFolder

            New-Item "$BaseFolder\ShouldRemain" -ItemType Directory
            New-Item "$BaseFolder\ShouldRemain\Test.txt" | Out-Null

            Export-ModuleProject -ModuleProject $ViableModule -Path $BaseFolder -Force

            (Test-Path "$BaseFolder\ShouldRemain") | Should -BeTrue
            (Test-Path "$BaseFolder\ShouldRemain\Test.txt") | Should -BeTrue
        }
    }
}