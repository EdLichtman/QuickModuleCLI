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
        
        . "$PSScriptRoot\Update-ModuleProject.ps1"

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
        Teardown-Sandbox
    }

    describe 'validations' {
        BeforeEach {
            Mock Copy-Item
        }
        it 'throws error if ModuleProject is null' {
            $err = {  Update-ModuleProject -ModuleProject '' } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.Message -like '*Null or Empty*' | Should -BeTrue
        }

        it 'throws error if module does not exist' {
            $err = {  Update-ModuleProject -ModuleProject $ViableModule } | Should -Throw -PassThru
    
            $err.Exception.GetType().BaseType | Should -Be $ParameterBindingException
            $err.Exception.InnerException.InnerException.GetType().Name | Should -Be 'ModuleProjectDoesNotExistException'
        }
    }
    describe 'auto-completion for input' {
        it 'auto-suggests valid Module Arguments for Module' {
            Add-TestModule $ViableModule -Valid
            $ArgumentCompleter = (Get-ArgumentCompleter -CommandName Update-ModuleProject -ParameterName ModuleProject)
            
            $Arguments = try {$ArgumentCompleter.Definition.Invoke()} catch {}
    
            $Arguments | Should -Be @($ViableModule)
        }
    }
    describe 'functionality' {
        BeforeAll {
            function Get-Psd1 {
                $ModuleProjects = GetValidModuleProject
                $psd1Location = "$($ModuleProjects.FullName)\$($ModuleProjects.Name).psd1"
                $psd1Content = (Get-Content $psd1Location | Out-String)
                return (Invoke-Expression $psd1Content)
            }
        }

        BeforeEach {
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
        }
        it 'updates all input parameters' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"

            Update-ModuleProject -ModuleProject $ViableModule `
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

            $psd1 = Get-Psd1

            $psd1.Author | Should -Be $expectedAuthor
            $psd1.CompanyName | Should -Be $expectedCompanyName
            $psd1.Copyright | Should -Be $expectedCopyright
            $psd1.ModuleVersion | Should -Be $expectedModuleVersion
            $psd1.Description | Should -Be $expectedDescription
            $psd1.PrivateData.PSData.Tags | Should -Be $expectedTags
            $psd1.PrivateData.PSData.ProjectUri | Should -Be $expectedProjectUri
            $psd1.PrivateData.PSData.LicenseUri | Should -Be $expectedLicenseUri
            $psd1.PrivateData.PSData.IconUri | Should -Be $expectedIconUri
            $psd1.PrivateData.PSData.ReleaseNotes | Should -Be $expectedReleaseNotes
            $psd1.HelpInfoUri | Should -Be $expectedHelpInfoUri
        }

        it 'is idempotent (long test)(does not overwrite any non-input parameters)' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Foo' -FunctionText "Write-Output 'Foo'"

            #Make sure all data is as expected
            $psd1 = Get-Psd1

            $psd1.Author | Should -Not -Be $expectedAuthor
            $psd1.CompanyName | Should -Not -Be $expectedCompanyName
            $psd1.Copyright | Should -Not -Be $expectedCopyright
            $psd1.ModuleVersion | Should -Not -Be $expectedModuleVersion
            $psd1.Description | Should -Not -Be $expectedDescription
            $psd1.PrivateData.PSData.Tags | Should -Not -Be $expectedTags
            $psd1.PrivateData.PSData.ProjectUri | Should -Not -Be $expectedProjectUri
            $psd1.PrivateData.PSData.LicenseUri | Should -Not -Be $expectedLicenseUri
            $psd1.PrivateData.PSData.IconUri | Should -Not -Be $expectedIconUri
            $psd1.PrivateData.PSData.ReleaseNotes | Should -Not -Be $expectedReleaseNotes
            $psd1.HelpInfoUri | Should -Not -Be $expectedHelpInfoUri

            Update-ModuleProject -ModuleProject $ViableModule `
                -Author $expectedAuthor 
            
            #Check to make sure only Author was updated
            $psd1 = Get-Psd1
            $psd1.Author | Should -Be $expectedAuthor
            $psd1.CompanyName | Should -Not -Be $expectedCompanyName
            $psd1.Copyright | Should -Not -Be $expectedCopyright
            $psd1.ModuleVersion | Should -Not -Be $expectedModuleVersion
            $psd1.Description | Should -Not -Be $expectedDescription
            $psd1.PrivateData.PSData.Tags | Should -Not -Be $expectedTags
            $psd1.PrivateData.PSData.ProjectUri | Should -Not -Be $expectedProjectUri
            $psd1.PrivateData.PSData.LicenseUri | Should -Not -Be $expectedLicenseUri
            $psd1.PrivateData.PSData.IconUri | Should -Not -Be $expectedIconUri
            $psd1.PrivateData.PSData.ReleaseNotes | Should -Not -Be $expectedReleaseNotes
            $psd1.HelpInfoUri | Should -Not -Be $expectedHelpInfoUri

            Update-ModuleProject -ModuleProject $ViableModule `
                -CompanyName $expectedCompanyName 

            #Check to make sure only CompanyName was updated
            $psd1 = Get-Psd1
            $psd1.Author | Should -Be $expectedAuthor
            $psd1.CompanyName | Should -Be $expectedCompanyName
            $psd1.Copyright | Should -Not -Be $expectedCopyright
            $psd1.ModuleVersion | Should -Not -Be $expectedModuleVersion
            $psd1.Description | Should -Not -Be $expectedDescription
            $psd1.PrivateData.PSData.Tags | Should -Not -Be $expectedTags
            $psd1.PrivateData.PSData.ProjectUri | Should -Not -Be $expectedProjectUri
            $psd1.PrivateData.PSData.LicenseUri | Should -Not -Be $expectedLicenseUri
            $psd1.PrivateData.PSData.IconUri | Should -Not -Be $expectedIconUri
            $psd1.PrivateData.PSData.ReleaseNotes | Should -Not -Be $expectedReleaseNotes
            $psd1.HelpInfoUri | Should -Not -Be $expectedHelpInfoUri

            Update-ModuleProject -ModuleProject $ViableModule `
                -Copyright $expectedCopyright 

            #Check to make sure only CopyRight was updated
            $psd1 = Get-Psd1
            $psd1.Author | Should -Be $expectedAuthor
            $psd1.CompanyName | Should -Be $expectedCompanyName
            $psd1.Copyright | Should -Be $expectedCopyright
            $psd1.ModuleVersion | Should -Not -Be $expectedModuleVersion
            $psd1.Description | Should -Not -Be $expectedDescription
            $psd1.PrivateData.PSData.Tags | Should -Not -Be $expectedTags
            $psd1.PrivateData.PSData.ProjectUri | Should -Not -Be $expectedProjectUri
            $psd1.PrivateData.PSData.LicenseUri | Should -Not -Be $expectedLicenseUri
            $psd1.PrivateData.PSData.IconUri | Should -Not -Be $expectedIconUri
            $psd1.PrivateData.PSData.ReleaseNotes | Should -Not -Be $expectedReleaseNotes
            $psd1.HelpInfoUri | Should -Not -Be $expectedHelpInfoUri

            Update-ModuleProject -ModuleProject $ViableModule `
                -ModuleVersion $expectedModuleVersion 

            #Check to make sure only ModuleVersion was updated
            $psd1 = Get-Psd1
            $psd1.Author | Should -Be $expectedAuthor
            $psd1.CompanyName | Should -Be $expectedCompanyName
            $psd1.Copyright | Should -Be $expectedCopyright
            $psd1.ModuleVersion | Should -Be $expectedModuleVersion
            $psd1.Description | Should -Not -Be $expectedDescription
            $psd1.PrivateData.PSData.Tags | Should -Not -Be $expectedTags
            $psd1.PrivateData.PSData.ProjectUri | Should -Not -Be $expectedProjectUri
            $psd1.PrivateData.PSData.LicenseUri | Should -Not -Be $expectedLicenseUri
            $psd1.PrivateData.PSData.IconUri | Should -Not -Be $expectedIconUri
            $psd1.PrivateData.PSData.ReleaseNotes | Should -Not -Be $expectedReleaseNotes
            $psd1.HelpInfoUri | Should -Not -Be $expectedHelpInfoUri

            Update-ModuleProject -ModuleProject $ViableModule `
                -Description $expectedDescription 

            #Check to make sure only Description was updated
            $psd1 = Get-Psd1
            $psd1.Author | Should -Be $expectedAuthor
            $psd1.CompanyName | Should -Be $expectedCompanyName
            $psd1.Copyright | Should -Be $expectedCopyright
            $psd1.ModuleVersion | Should -Be $expectedModuleVersion
            $psd1.Description | Should -Be $expectedDescription
            $psd1.PrivateData.PSData.Tags | Should -Not -Be $expectedTags
            $psd1.PrivateData.PSData.ProjectUri | Should -Not -Be $expectedProjectUri
            $psd1.PrivateData.PSData.LicenseUri | Should -Not -Be $expectedLicenseUri
            $psd1.PrivateData.PSData.IconUri | Should -Not -Be $expectedIconUri
            $psd1.PrivateData.PSData.ReleaseNotes | Should -Not -Be $expectedReleaseNotes
            $psd1.HelpInfoUri | Should -Not -Be $expectedHelpInfoUri


            Update-ModuleProject -ModuleProject $ViableModule `
                -Tags $expectedTags 

            #Check to make sure only Tags was updated
            $psd1 = Get-Psd1
            $psd1.Author | Should -Be $expectedAuthor
            $psd1.CompanyName | Should -Be $expectedCompanyName
            $psd1.Copyright | Should -Be $expectedCopyright
            $psd1.ModuleVersion | Should -Be $expectedModuleVersion
            $psd1.Description | Should -Be $expectedDescription
            $psd1.PrivateData.PSData.Tags | Should -Be $expectedTags
            $psd1.PrivateData.PSData.ProjectUri | Should -Not -Be $expectedProjectUri
            $psd1.PrivateData.PSData.LicenseUri | Should -Not -Be $expectedLicenseUri
            $psd1.PrivateData.PSData.IconUri | Should -Not -Be $expectedIconUri
            $psd1.PrivateData.PSData.ReleaseNotes | Should -Not -Be $expectedReleaseNotes
            $psd1.HelpInfoUri | Should -Not -Be $expectedHelpInfoUri

            Update-ModuleProject -ModuleProject $ViableModule `
                -ProjectUri $expectedProjectUri 

            #Check to make sure only ProjectUri was updated
            $psd1 = Get-Psd1
            $psd1.Author | Should -Be $expectedAuthor
            $psd1.CompanyName | Should -Be $expectedCompanyName
            $psd1.Copyright | Should -Be $expectedCopyright
            $psd1.ModuleVersion | Should -Be $expectedModuleVersion
            $psd1.Description | Should -Be $expectedDescription
            $psd1.PrivateData.PSData.Tags | Should -Be $expectedTags
            $psd1.PrivateData.PSData.ProjectUri | Should -Be $expectedProjectUri
            $psd1.PrivateData.PSData.LicenseUri | Should -Not -Be $expectedLicenseUri
            $psd1.PrivateData.PSData.IconUri | Should -Not -Be $expectedIconUri
            $psd1.PrivateData.PSData.ReleaseNotes | Should -Not -Be $expectedReleaseNotes
            $psd1.HelpInfoUri | Should -Not -Be $expectedHelpInfoUri

            Update-ModuleProject -ModuleProject $ViableModule `
                -LicenseUri $expectedLicenseUri 

            #Check to make sure only LicenseUri was updated
            $psd1 = Get-Psd1
            $psd1.Author | Should -Be $expectedAuthor
            $psd1.CompanyName | Should -Be $expectedCompanyName
            $psd1.Copyright | Should -Be $expectedCopyright
            $psd1.ModuleVersion | Should -Be $expectedModuleVersion
            $psd1.Description | Should -Be $expectedDescription
            $psd1.PrivateData.PSData.Tags | Should -Be $expectedTags
            $psd1.PrivateData.PSData.ProjectUri | Should -Be $expectedProjectUri
            $psd1.PrivateData.PSData.LicenseUri | Should -Be $expectedLicenseUri
            $psd1.PrivateData.PSData.IconUri | Should -Not -Be $expectedIconUri
            $psd1.PrivateData.PSData.ReleaseNotes | Should -Not -Be $expectedReleaseNotes
            $psd1.HelpInfoUri | Should -Not -Be $expectedHelpInfoUri

            Update-ModuleProject -ModuleProject $ViableModule `
                -IconUri $expectedIconUri 

            #Check to make sure only IconUri was updated
            $psd1 = Get-Psd1
            $psd1.Author | Should -Be $expectedAuthor
            $psd1.CompanyName | Should -Be $expectedCompanyName
            $psd1.Copyright | Should -Be $expectedCopyright
            $psd1.ModuleVersion | Should -Be $expectedModuleVersion
            $psd1.Description | Should -Be $expectedDescription
            $psd1.PrivateData.PSData.Tags | Should -Be $expectedTags
            $psd1.PrivateData.PSData.ProjectUri | Should -Be $expectedProjectUri
            $psd1.PrivateData.PSData.LicenseUri | Should -Be $expectedLicenseUri
            $psd1.PrivateData.PSData.IconUri | Should -Be $expectedIconUri
            $psd1.PrivateData.PSData.ReleaseNotes | Should -Not -Be $expectedReleaseNotes
            $psd1.HelpInfoUri | Should -Not -Be $expectedHelpInfoUri

            Update-ModuleProject -ModuleProject $ViableModule `
                -ReleaseNotes $expectedReleaseNotes 

            #Check to make sure only ReleaseNotes was updated
            $psd1 = Get-Psd1
            $psd1.Author | Should -Be $expectedAuthor
            $psd1.CompanyName | Should -Be $expectedCompanyName
            $psd1.Copyright | Should -Be $expectedCopyright
            $psd1.ModuleVersion | Should -Be $expectedModuleVersion
            $psd1.Description | Should -Be $expectedDescription
            $psd1.PrivateData.PSData.Tags | Should -Be $expectedTags
            $psd1.PrivateData.PSData.ProjectUri | Should -Be $expectedProjectUri
            $psd1.PrivateData.PSData.LicenseUri | Should -Be $expectedLicenseUri
            $psd1.PrivateData.PSData.IconUri | Should -Be $expectedIconUri
            $psd1.PrivateData.PSData.ReleaseNotes | Should -Be $expectedReleaseNotes
            $psd1.HelpInfoUri | Should -Not -Be $expectedHelpInfoUri

            Update-ModuleProject -ModuleProject $ViableModule `
                -HelpInfoUri $expectedHelpInfoUri 

            #Check to make sure only HelpInfoUri was updated
            $psd1 = Get-Psd1
            $psd1.Author | Should -Be $expectedAuthor
            $psd1.CompanyName | Should -Be $expectedCompanyName
            $psd1.Copyright | Should -Be $expectedCopyright
            $psd1.ModuleVersion | Should -Be $expectedModuleVersion
            $psd1.Description | Should -Be $expectedDescription
            $psd1.PrivateData.PSData.Tags | Should -Be $expectedTags
            $psd1.PrivateData.PSData.ProjectUri | Should -Be $expectedProjectUri
            $psd1.PrivateData.PSData.LicenseUri | Should -Be $expectedLicenseUri
            $psd1.PrivateData.PSData.IconUri | Should -Be $expectedIconUri
            $psd1.PrivateData.PSData.ReleaseNotes | Should -Be $expectedReleaseNotes
            $psd1.HelpInfoUri | Should -Be $expectedHelpInfoUri
        }
    }
}