describe 'Get-ModuleProject' {
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

        . "$PSScriptRoot\Update-ModuleProject.ps1"
        . "$PSScriptRoot\Add-ModuleFunction.ps1"
        . "$PSScriptRoot\Add-ModuleAlias.ps1"
        . "$PSScriptRoot\Get-ModuleProject.ps1"

        $ViableModule = "Viable"
        Remove-Sandbox
    }
    BeforeEach {
        New-Sandbox

        Mock Update-ModuleProject
        Mock Import-Module
    }
    AfterEach {
        Remove-Sandbox
    }
    AfterAll {
        Remove-Sandbox
    }
<#[String] $ModuleProject,
[String] $CommandName,
[Switch] $Summary#>
    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for ModuleProject' {
            Mock Get-ValidModuleProjectNames
            $Arguments = (Get-ArgumentCompleter -CommandName Get-ModuleProject -ParameterName ModuleProject)
            
            try {$Arguments.Definition.Invoke()} catch {}
    
            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }

        # it 'auto-suggests valid Commands if ModuleProject is provided' {

        # }

        # it 'auto-suggests valid Commands if ModuleProject is not provided' {

        # }
    }
    describe 'functionality' {
        it 'Should get names of all functions' {
            $FunctionName = 'Write-Foo'
            $OtherFunctionName = 'Test-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName
            Add-TestFunction -ModuleName 'Test' -FunctionName $OtherFunctionName
    
            $Project = Get-ModuleProject

            $FunctionName -in $Project.Command | Should -BeTrue
            $OtherFunctionName -in $Project.Command | Should -BeTrue
        }
    
        it 'Should get names of all functions within ModuleProject' {
            $FunctionName = 'Write-Foo'
            $OtherFunctionName = 'Test-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName
            Add-TestFunction -ModuleName 'Test' -FunctionName $OtherFunctionName
    
            $Project = Get-ModuleProject -ModuleProject $ViableModule

            $FunctionName -in $Project.Command | Should -BeTrue
            $OtherFunctionName -in $Project.Command | Should -BeFalse
        }

        it 'Should get Function specified' {
            $FunctionName = 'Write-Foo'
            $OtherFunctionName = 'Test-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName
            Add-TestFunction -ModuleName 'Test' -FunctionName $OtherFunctionName
    
            $Project = Get-ModuleProject -CommandName $FunctionName

            $FunctionName -in $Project.Command | Should -BeTrue
            $OtherFunctionName -in $Project.Command | Should -BeFalse
        }

        it 'Should get Function specified in ModuleProject' {
            $FunctionName = 'Write-Foo'
            $OtherFunctionName = 'Test-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName
            Add-TestFunction -ModuleName 'Test' -FunctionName $OtherFunctionName
    
            $Project = Get-ModuleProject -ModuleProject $ViableModule -CommandName $FunctionName

            $FunctionName -in $Project.Command | Should -BeTrue
            $OtherFunctionName -in $Project.Command | Should -BeFalse
        }

        it 'Should not get Function specified if not in ModuleProject' {
            $FunctionName = 'Write-Foo'
            $OtherFunctionName = 'Test-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName
            Add-TestFunction -ModuleName 'Test' -FunctionName $OtherFunctionName
    
            $Project = Get-ModuleProject -ModuleProject $ViableModule -CommandName $OtherFunctionName

            $FunctionName -in $Project.Command | Should -BeFalse
            $OtherFunctionName -in $Project.Command | Should -BeFalse
        }

        it 'Should get CommandType of all Commands within ModuleProject' {
            $FunctionName = 'Write-Foo'
            $AliasName = 'Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName
            Add-TestAlias -ModuleName $ViableModule -AliasName $AliasName
    
            $Project = Get-ModuleProject -ModuleProject $ViableModule

            $Function = $Project | Where-Object {$_.Command -eq $FunctionName}
            $Alias = $Project | Where-Object {$_.Command -eq $AliasName}

            $Function.Type | Should -Be 'Function'
            $Alias.Type | Should -Be 'Alias'
        }

        it 'Should get ModuleProject for each Command within ModuleProject' {
            $FunctionName = 'Write-Foo'
            $OtherFunctionName = 'Test-Foo'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            Add-TestFunction -ModuleName $ViableModule -FunctionName $FunctionName
            Add-TestFunction -ModuleName 'Test' -FunctionName $OtherFunctionName
    
            $Project = Get-ModuleProject

            $Function = $Project | Where-Object {$_.Command -eq $FunctionName}
            $OtherFunction = $Project | Where-Object {$_.Command -eq $OtherFunctionName}

            $Function.Module | Should -Be $ViableModule
            $OtherFunction.Module | Should -Be 'Test'
        }
    }
    
}