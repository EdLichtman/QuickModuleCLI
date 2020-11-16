describe 'Export-ModuleProject' {
    BeforeAll {
        . "$PSScriptRoot\..\Private\_TestEnvironment.ps1"
        
        <# ENVIRONMENT VARIABLES #>
        $BaseModuleName = "QuickModuleCLITests"
        $BaseFolder =  Get-SandboxBaseFolder
        $ModuleProjectsFolder = Get-SandboxNestedModulesFolder
        $FunctionsFolder = Get-SandboxFunctionsFolder
        $PrivateFunctionsFolder = Get-SandboxPrivateFunctionsFolder

        . "$PSScriptRoot\..\Private\Environment.ps1"
        . "$PSScriptRoot\..\Private\ObjectTransformation.ps1"
        . "$PSScriptRoot\..\Private\ArgumentCompleters.ps1"
        . "$PSScriptRoot\..\Private\ArgumentTransformations.ps1"
        . "$PSScriptRoot\..\Private\Validators.Exceptions.ps1"
        . "$PSScriptRoot\..\Private\Validators.ps1"

        . "$PSScriptRoot\Update-ModuleProject.ps1"
        . "$PSScriptRoot\Export-ModuleProject.ps1"

        $ViableModule = "Viable"
        $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'
        Remove-Sandbox
    }
    BeforeEach {
        New-Sandbox
        Mock Update-ModuleProject
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
        it 'throws error if ModuleProject is null' {
            $err = {  Export-ModuleProject -ModuleProject '' } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if module does not exist' {
            $err = {  Export-ModuleProject -ModuleProject $ViableModule } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }

        it 'throws error if attempting to copy module project to ModuleProjectRoot location' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"

            $err = { Export-ModuleProject -ModuleProject $ViableModule -Destination $ModuleProjectsFolder -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ValidateModuleProjectExportDestinationIsInvalidException'
        }

        it 'throws error if attempting to copy module project to designated PowershellModule location' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"

            $PSProfile = $env:PSModulePath.Split(';')[0]
            $err = { Export-ModuleProject -ModuleProject $ViableModule -Destination $PSProfile -WhatIf } | Should -Throw -PassThru
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ValidateModuleProjectExportDestinationIsInvalidException'
        }
    }

    describe 'functionality' {
        it 'calls Update-ModuleProject with updated Parameters' {
            $expectedAuthor = New-Guid
            $expectedCompanyName = New-Guid
            $expectedCopyright = New-Guid
            $expectedModuleVersion = "$(Get-Random -Maximum 10 -Minimum 0).$(Get-Random -Maximum 10 -Minimum 0).$(Get-Random -Maximum 10 -Minimum 0)"
            $expectedDescription = New-Guid
            $expectedTags = New-Guid
            $expectedProjectUri = "http://$(New-Guid)/"
            $expectedLicenseUri = "http://$(New-Guid)/"
            $expectedIconUri = "http://$(New-Guid)/"
            $expectedReleaseNotes = New-Guid
            $expectedHelpInfoUri = "http://$(New-Guid)/"

            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"

            Export-ModuleProject -ModuleProject $ViableModule -Destination $BaseFolder `
                -Author $expectedAuthor `
                -CompanyName $expectedCompanyName `
                -Copyright $expectedCopyright `
                -ModuleVersion $expectedModuleVersion `
                -Description $expectedDescription `
                -Tags $expectedTags `
                -ProjectUri $expectedProjectUri `
                -LicenseUri $expectedLicenseUri `
                -IconUri $expectedIconUri `
                -ReleaseNotes $expectedReleaseNotes `
                -HelpInfoUri $expectedHelpInfoUri 

            Assert-MockCalled Update-ModuleProject -Times 1 -ParameterFilter {
                $Author -eq $expectedAuthor -and
                $CompanyName -eq $expectedCompanyName -and
                $Copyright -eq $expectedCopyright -and
                $ModuleVersion -eq $expectedModuleVersion -and
                $Description -eq $expectedDescription -and
                $Tags -eq $expectedTags -and
                $ProjectUri -eq $expectedProjectUri -and
                $LicenseUri -eq $expectedLicenseUri -and
                $IconUri -eq $expectedIconUri -and
                $ReleaseNotes -eq $expectedReleaseNotes -and
                $HelpInfoUri -eq $expectedHelpInfoUri
            }
        }

        it 'copies module project to new location' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"

            Export-ModuleProject -ModuleProject $ViableModule -Destination $BaseFolder

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

            Export-ModuleProject -ModuleProject $ViableModule -Destination $BaseFolder

            (Test-Path "$ModuleProjectsFolder\$ViableModule") | Should -BeTrue
        }
    }

    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Module' {
            Mock Get-ValidModuleProjectNames
            $Arguments = (Get-ArgumentCompleter -CommandName Export-ModuleProject -ParameterName ModuleProject)
            
            try {$Arguments.Definition.Invoke()} catch {}
    
            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }
    }
}