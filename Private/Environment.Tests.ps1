using namespace System.Management.Automation
using namespace System.Collections.Generic
Describe 'Environment' {
    BeforeAll {
        . "$PSScriptRoot\_TestEnvironment.ps1"
        
        <# ENVIRONMENT VARIABLES #>
        $BaseModuleName = "QuickModuleCLITests"
        $BaseFolder =  Get-SandboxBaseFolder
        $ModuleProjectsFolder = Get-SandboxNestedModulesFolder
        $FunctionsFolder = Get-SandboxFunctionsFolder
        $PrivateFunctionsFolder = Get-SandboxPrivateFunctionsFolder

        . "$PSScriptRoot\Environment.ps1"
        . "$PSScriptRoot\ArgumentCompleters.ps1"
        . "$PSScriptRoot\Validators.ps1"
        . "$PSScriptRoot\PrivateFunctions.ps1"

        $ViableModule = "Viable"
        $NonviableModule = "Nonviable"
        $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'
        $ItemNotFoundException = 'System.Management.Automation.ItemNotFoundException'
        $ArgumentException = 'System.ArgumentException'
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

    describe 'Get-ModuleProjectLocation' {
        it "Gets the child folder of the NestedModulesFolder" {
            $NestedModule = "Test"
            $NestedModuleLocation = Get-ModuleProjectLocation -ModuleProject $NestedModule

            $NestedModuleLocation | Should -Be "$(Get-SandboxNestedModulesFolder)\$NestedModule"
        }

        it "Gets the expected child folder even if the folder doesn't exist" {
            $NestedModule = "Test"
            $NestedModuleLocation = Get-ModuleProjectLocation -ModuleProject $NestedModule

            (Test-Path $NestedModuleLocation) | Should -Be $false
        }
    }

    describe 'Get-ValidModuleProjects' {
        It 'Does not throw error if no viable module exists' {
            { Get-ValidModuleProjects } | Should -Not -Throw
        }

        It 'Has empty array if no viable modules exist' {
            (Get-ValidModuleProjects).Count | Should -Be 0
        }

        It 'Does not consider a folder without psd1 and psm1 and functions and aliases as a viable module' {
            Add-TestModule -Name 'Test'

            (Get-ValidModuleProjects).Count | Should -Be 0
        }

        It 'Does not consider a folder without psd1 as a viable module' {
            Add-TestModule -Name 'Test' -IncludeRoot -IncludeFunctions -IncludeAliases

            (Get-ValidModuleProjects).Count | Should -Be 0
        }

        It 'Does not consider a folder without psm1 as a viable module' {
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeFunctions -IncludeAliases

            (Get-ValidModuleProjects).Count | Should -Be 0
        }


        It 'Does not consider a folder without functions as a viable module' {
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeAliases

            (Get-ValidModuleProjects).Count | Should -Be 0
        }        

        It 'Does not consider a folder without aliases as a viable module' {
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions

            (Get-ValidModuleProjects).Count | Should -Be 0
        }        

        It 'Considers an array with a single value to still be an array' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            (Get-ValidModuleProjects).Count | Should -Be 1
        }

        It 'Considers a folder with psd1 and psm1 and Functions and Aliases as a viable module' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            Get-ValidModuleProjects | ForEach-Object {$_.Name} | Should -contain $ViableModule
        }
    }

    describe 'Get-ValidModuleProjectNames' {
        It 'Does not throw error if no viable module exists' {
            { Get-ValidModuleProjectNames } | Should -Not -Throw
        }

        It 'Has empty array if no viable modules exist' {
            (Get-ValidModuleProjectNames).Count | Should -Be 0
        }

        It 'Gets ModuleProjectNames from ValidModuleProjects' {
            Mock Get-ValidModuleProjects { return @(@{Name=$ViableModule})}

            (Get-ValidModuleProjectNames).Count | Should -Be 1
        }

        It 'Gets array of ModuleProjectNames from ValidModuleProjects if only one exists' {
            $CustomObject = Get-MockFileInfo -BaseName $ViableModule -Directory

            Mock Get-ValidModuleProjects { return @($CustomObject)}

            (Get-ValidModuleProjectNames)[0] | Should -Be $ViableModule
        }

        It 'Gets array of ModuleProjectNames from ValidModuleProjects' {
            $CustomObject = Get-MockFileInfo -BaseName $ViableModule -Directory
            $CustomObject2 = Get-MockFileInfo -BaseName 'Test' -Directory

            Mock Get-ValidModuleProjects { return @($CustomObject, $CustomObject2)}

            (Get-ValidModuleProjectNames)[0] | Should -Be $ViableModule
        }
    }

    describe 'Get-ModuleProjectFunctionsFolder' {
        It 'Does not throw error if module does not exist' {
            { Get-ModuleProjectFunctionsFolder -ModuleProject $ViableModule } | Should -Not -Throw
        }

        It 'Should start with module path' {
            $ModulePath = Get-ModuleProjectLocation -ModuleProject $ViableModule
            (Get-ModuleProjectFunctionsFolder -ModuleProject $ViableModule).IndexOf($ModulePath) | Should -Be 0
        }
    }

    describe 'Get-ModuleProjectFunctions' {
        It 'Throws error if module does not exist' {
            { Get-ModuleProjectFunctions -ModuleProject $ViableModule } | Should -Throw -ExceptionType $ItemNotFoundException
        }

        It 'Does not throw error if no functions exist' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions
            { Get-ModuleProjectFunctions -ModuleProject $ViableModule } | Should -Not -Throw
        }

        It 'Should contain values within module project' {
            $expectedTestFunction = 'Get-Test'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions
            Add-TestFunction -ModuleName $ViableModule -FunctionName $expectedTestFunction

            $Functions = @((Get-ModuleProjectFunctions -ModuleProject $ViableModule) | ForEach-Object {$_.Name})
            $Functions.Contains("$expectedTestFunction.ps1") | Should -BeTrue
        }

        It 'Should not contain values within other module project' {
            $expectedTestFunction = 'Get-Test'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions
            Add-TestFunction -ModuleName 'Test' -FunctionName $expectedTestFunction

            (Get-ModuleProjectFunctions -ModuleProject $ViableModule).Contains($expectedTestFunction) | Should -BeFalse
        }

        It 'Should contain all values within module project' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Test'
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-OtherTest'

            (Get-ModuleProjectFunctions -ModuleProject $ViableModule).Count | Should -Be 2
        }
    }

    describe 'Get-ModuleProjectFunctionNames' {
        It 'Should get names from Get-ModuleProjectFunctions' {
            $expectedFunction = 'Get-Test'
            $CustomObject = Get-MockFileInfo -BaseName $expectedFunction

            Mock Get-ModuleProjectFunctions {return @($CustomObject)} -ParameterFilter { $ModuleProject -eq $ViableModule } 

            (Get-ModuleProjectFunctionNames -ModuleProject $ViableModule).Contains($expectedFunction) | Should -BeTrue
        }

        It 'Should get names from Get-ModuleProjectFunctions using Module' {
            $expectedFunction = 'Get-Test'
            $CustomObject = Get-MockFileInfo -BaseName $expectedFunction

            Mock Get-ModuleProjectFunctions {return @($CustomObject)} -ParameterFilter { $ModuleProject -eq 'Test' } 
            Mock Get-ModuleProjectFunctions {return [List[String]]::new()} -ParameterFilter { $ModuleProject -eq $Viable }.GetNewClosure() 

            (Get-ModuleProjectFunctionNames -ModuleProject $ViableModule).Contains($expectedFunction) | Should -BeFalse
        }

        It 'Should contain an array even if there is only 1 value' {
            $expectedFunction = 'Get-Test'
            $CustomObject = Get-MockFileInfo -BaseName $expectedFunction
            Mock Get-ModuleProjectFunctions {return @($CustomObject)}

            (Get-ModuleProjectFunctionNames -ModuleProject $ViableModule)[0] | Should -Be $expectedFunction
        }

         It 'Should contain all functions within module project' {
            $CustomObject = Get-MockFileInfo -BaseName 'Get-Test'
            $CustomObject2 = Get-MockFileInfo -BaseName 'Get-Test2'
            
            Mock Get-ModuleProjectFunctions {return @($CustomObject, $CustomObject2)}
            
            (Get-ModuleProjectFunctionNames -ModuleProject $ViableModule).Count | Should -Be 2
        }

        It 'Should contain all values within module project' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-Test'
            Add-TestFunction -ModuleName $ViableModule -FunctionName 'Get-OtherTest'

            (Get-ModuleProjectFunctionNames -ModuleProject $ViableModule).Count | Should -Be 2
        }
    }

    describe 'Get-ModuleProjectFunctionPath' {
        It 'Does not throw error if module does not exist' {
            { Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName "Test-Foo"} | Should -Not -Throw
        }

        It 'Should start with module path' {
            $ModulePath = Get-ModuleProjectLocation -ModuleProject $ViableModule
            (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName "Test-Foo").IndexOf($ModulePath) | Should -Be 0
        }

        It 'Should start with function path' {
            $FunctionsPath = Get-ModuleProjectFunctionsFolder -ModuleProject $ViableModule
            (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName "Test-Foo").IndexOf($FunctionsPath) | Should -Be 0
        }

        It 'Should end in a file by the expected name' {
            (Get-ModuleProjectFunctionPath -ModuleProject $ViableModule -CommandName "Write-Foo").EndsWith("\Write-Foo.ps1") | Should -BeTrue
        }
    }

    describe 'New-ModuleProjectFunction' {
        It 'Throws error if module does not exist' {
            {New-ModuleProjectFunction -ModuleProject $ViableModule -CommandName 'Write-Foo'} | Should -Throw $ParameterBindingException
        }

        It 'Throws error if function already exists in module' {
            Add-TestModule -ModuleProject $ViableModule
            Add-TestFunction -ModuleProject $ViableModule -FunctionName 'Write-Foo'

            {New-ModuleProjectFunction -ModuleProject $ViableModule -CommandName 'Write-Foo'} | Should -Throw $ArgumentException
        }

        It 'Throws error if function does not start with approved verbs' {

        }

        It 'Creates new function' {

        }

        It 'Adds function template to file' {

        }

        It 'Adds Text to function template in file' {

        }

        It 'Supports Raw addition of text for Renaming Functions' {

        }
    }

    describe 'Get-ModuleProjectAliasesFolder' {
        It 'Does not throw error if module does not exist' {
            { Get-ModuleProjectAliasesFolder -ModuleProject $ViableModule } | Should -Not -Throw
        }

        It 'Should start with module path' {
            $ModulePath = Get-ModuleProjectLocation -ModuleProject $ViableModule
            (Get-ModuleProjectAliasesFolder -ModuleProject $ViableModule).IndexOf($ModulePath) | Should -Be 0
        }
    }


    describe 'Get-ModuleProjectAliases' {
        It 'Throws error if module does not exist' {
            { Get-ModuleProjectAliases -ModuleProject $ViableModule } | Should -Throw -ExceptionType $ItemNotFoundException
        }

        It 'Does not throw error if no Aliases exist' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            { Get-ModuleProjectAliases -ModuleProject $ViableModule } | Should -Not -Throw
        }

        It 'Should contain values within module project' {
            $expectedTestAlias = 'Test'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName $ViableModule -AliasName $expectedTestAlias

            $Functions = @((Get-ModuleProjectAliases -ModuleProject $ViableModule) | ForEach-Object {$_.Name})
            $Functions.Contains("$expectedTestAlias.ps1") | Should -BeTrue
        }

        It 'Should not contain values within other module project' {
            $expectedTestAlias = 'Test'
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name 'Test' -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName 'Test' -AliasName $expectedTestAlias

            (Get-ModuleProjectAliases -ModuleProject $ViableModule).Contains($expectedTestAlias) | Should -BeFalse
        }

        It 'Should contain all values within module project' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName $ViableModule -AliasName 'Test'
            Add-TestAlias -ModuleName $ViableModule -AliasName 'OtherTest'

            (Get-ModuleProjectAliases -ModuleProject $ViableModule).Count | Should -Be 2
        }
    }

    describe 'Get-ModuleProjectAliasNames' {
        It 'Should get names from Get-ModuleProjectAliases' {
            $expectedAlias = 'Test'
            $CustomObject = Get-MockFileInfo -BaseName $expectedAlias

            Mock Get-ModuleProjectAliases {return @($CustomObject)} -ParameterFilter { $ModuleProject -eq $ViableModule } 

            (Get-ModuleProjectAliasNames -ModuleProject $ViableModule).Contains($expectedAlias) | Should -BeTrue
        }

        It 'Should get names from Get-ModuleProjectAliases using Module' {
            $expectedAlias = 'Test'
            $CustomObject = Get-MockFileInfo -BaseName $expectedAlias

            Mock Get-ModuleProjectAliases {return @($CustomObject)} -ParameterFilter { $ModuleProject -eq 'Test' } 
            Mock Get-ModuleProjectAliases {return [List[String]]::new()} -ParameterFilter { $ModuleProject -eq $Viable }.GetNewClosure() 

            (Get-ModuleProjectAliasNames -ModuleProject $ViableModule).Contains($expectedAlias) | Should -BeFalse
        }

        It 'Should contain an array even if there is only 1 value' {
            $expectedAlias = 'Test'
            $CustomObject = Get-MockFileInfo -BaseName $expectedAlias
            Mock Get-ModuleProjectAliases {return @($CustomObject)}

            (Get-ModuleProjectAliasNames -ModuleProject $ViableModule)[0] | Should -Be $expectedAlias
        }

         It 'Should contain all functions within module project' {
            $CustomObject = Get-MockFileInfo -BaseName 'Test'
            $CustomObject2 = Get-MockFileInfo -BaseName 'Test2'
            
            Mock Get-ModuleProjectAliases {return @($CustomObject, $CustomObject2)}
            
            (Get-ModuleProjectAliasNames -ModuleProject $ViableModule).Count | Should -Be 2
        }

        It 'Should contain all values within module project' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestAlias -ModuleName $ViableModule -AliasName 'Test'
            Add-TestAlias -ModuleName $ViableModule -AliasName 'OtherTest'

            (Get-ModuleProjectAliasNames -ModuleProject $ViableModule).Count | Should -Be 2
        }
    }

    describe 'Get-ModuleProjectAliasPath' {
        It 'Does not throw error if module does not exist' {
            { Get-ModuleProjectAliasPath -ModuleProject $ViableModule -CommandName "Foo"} | Should -Not -Throw
        }

        It 'Should start with module path' {
            $ModulePath = Get-ModuleProjectLocation -ModuleProject $ViableModule
            (Get-ModuleProjectAliasPath -ModuleProject $ViableModule -CommandName "Foo").IndexOf($ModulePath) | Should -Be 0
        }

        It 'Should start with alias path' {
            $AliasesPath = Get-ModuleProjectAliasesFolder -ModuleProject $ViableModule
            (Get-ModuleProjectAliasPath -ModuleProject $ViableModule -CommandName "Foo").IndexOf($AliasesPath) | Should -Be 0
        }

        It 'Should end in a file by the expected name' {
            (Get-ModuleProjectAliasPath -ModuleProject $ViableModule -CommandName "Foo").EndsWith("\Foo.ps1") | Should -BeTrue
        }
    }

    Describe 'Get-ApprovedVerbs' {
        It 'Returns all approved verbs' {
            $ObtainedVerbs = Get-ApprovedVerbs
            $ExpectedVerbs = Get-Verb | Select-Object -Property Verb | ForEach-Object { $_.Verb }

            $ExpectedVerbs | Should -Be $ObtainedVerbs
        }
    }
}