describe 'Import-ModuleProject' {
    BeforeAll {
        . "$PSScriptRoot\..\Private\_TestEnvironment.ps1"
        
        <# ENVIRONMENT VARIABLES #>
        $BaseModuleName = "QuickModuleCLITests"
        $BaseFolder =  Get-SandboxBaseFolder
        $ModuleProjectsFolder = Get-SandboxNestedModulesFolder
        $FunctionsFolder = Get-SandboxFunctionsFolder
        $PrivateFunctionsFolder = Get-SandboxPrivateFunctionsFolder
        $ImportableProjectsFolder = "$BaseFolder\Import"

        . "$PSScriptRoot\..\Private\UI.ps1"
        . "$PSScriptRoot\..\Private\Environment.ps1"
        . "$PSScriptRoot\..\Private\ObjectTransformation.ps1"
        . "$PSScriptRoot\..\Private\ArgumentCompleters.ps1"
        . "$PSScriptRoot\..\Private\ArgumentTransformations.ps1"
        . "$PSScriptRoot\..\Private\Validators.ps1"
        
        . "$PSScriptRoot\Import-ModuleProject.ps1"

        $ViableModule = "Viable"
        $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'
        Remove-Sandbox

        function New-ImportableModuleProject {
            [OutputType([String])]
            param(
                [String]$ModuleProject
            )

            Add-TestModule -Name $ModuleProject -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases | Out-Null
            Add-TestFunction -ModuleName $ModuleProject -FunctionName 'Write-Foo' | Out-Null

            $ModuleProjectLocation = Get-ModuleProjectLocation -ModuleProject $ModuleProject
            Move-Item -Path $ModuleProjectLocation -Destination "$ImportableProjectsFolder" -Force | Out-Null
            return "$ImportableProjectsFolder\$ModuleProject"
        }
    }
    BeforeEach {
        New-Sandbox
        New-Item $ImportableProjectsFolder -ItemType Directory
        Mock Import-Module
        
    }
    AfterEach {
        Remove-Sandbox
    }
    AfterAll {
        Remove-Sandbox
    }

    describe 'validations' {
        it 'throws error if Path is null' {
            $err = {  Import-ModuleProject -Path '' } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Empty*' | Should -BeTrue
        }

        it 'throws error if Path does not exist' {
            $err = { Import-ModuleProject -Path 'C:\path\to\som\unknown\not\real\location\unless\there\is\some\intentional\hijacking\of\tests' } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.GetType().Name | Should -Be 'ItemNotFoundException'
        }

        it 'throws error if attempting to copy module project that exists by same name' {
            $ImportableProjectLocation = New-ImportableModuleProject $ViableModule
            Import-ModuleProject -Path $ImportableProjectLocation

            $err = { Import-ModuleProject -Path $ImportableProjectLocation } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectExistsException'
        }

        it 'throws error if attempting to copy module project from ModuleProject path (because it already exists)' {
            $ImportableProjectLocation = New-ImportableModuleProject $ViableModule
            Import-ModuleProject -Path $ImportableProjectLocation

            $ModuleProjectLocation = Get-ModuleProjectLocation -ModuleProject $ViableModule

            $err = { Import-ModuleProject -Path $ModuleProjectLocation } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectExistsException'
        }

        it 'throws error if attempting to copy module project to designated PowershellModule location' {
            Mock Get-EnvironmentModuleDirectories { return @((Get-Item $ImportableProjectsFolder).FullName) }

            $ImportableProjectLocation = New-ImportableModuleProject $ViableModule

            $err = { Import-ModuleProject -Path $ImportableProjectLocation } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleExistsException'
        }
    }

    describe 'functionality' {     
        it 'Should try to import the module' { 
            $ImportableProjectLocation = New-ImportableModuleProject $ViableModule
            (Get-ValidModuleProjects).Count | Should -Be 0

            Import-ModuleProject -Path $ImportableProjectLocation
    
            (Get-ValidModuleProjects).Count | Should -Be 1
            (Get-ValidModuleProjects).Name | Should -Be $ViableModule
        }

        it 'Should try to import the base module again' {
            $ImportableProjectLocation = New-ImportableModuleProject $ViableModule

            Import-ModuleProject -Path $ImportableProjectLocation
    
            Assert-MockCalled Import-Module -Times 1 -ParameterFilter {$Force -eq $True -and $Name -eq $BaseModuleName -and $Global -eq $True}
        }
    
        it 'leaves a copy of the imported module in the original location' {
            $ImportableProjectLocation = New-ImportableModuleProject $ViableModule

            Import-ModuleProject -Path $ImportableProjectLocation

            Test-Path $ImportableProjectLocation | Should -Be $True
        }
    
    }
}