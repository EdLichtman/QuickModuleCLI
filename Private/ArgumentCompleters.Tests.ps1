using namespace System.Collections.Generic

Describe 'ArgumentCompleters' {
    BeforeAll {
        . "$PSScriptRoot\_TestEnvironment.ps1"

        <# ENVIRONMENT VARIABLE OVERRIDES #>
        $BaseModuleName = "QuickModuleCLITests"
        $BaseFolder =  Get-SandboxBaseFolder
        $ModuleProjectsFolder = Get-SandboxNestedModulesFolder
        $FunctionsFolder = Get-SandboxFunctionsFolder
        $PrivateFunctionsFolder = Get-SandboxPrivateFunctionsFolder

        . "$PSScriptRoot\UI.ps1"
        . "$PSScriptRoot\Environment.ps1"
        . "$PSScriptRoot\ArgumentCompleters.ps1"
        . "$PSScriptRoot\ArgumentTransformations.ps1"
        . "$PSScriptRoot\Validators.ps1"

        $ViableModule = "Viable"
        $NonviableModule = "Nonviable"

        $InvalidOperationException = 'System.InvalidOperationException'
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

    describe 'Get-ModuleProjectArgument' {
        It 'Gets all valid Module Project choices' {
            Add-TestModule 'Foo' -Valid
            Add-TestModule 'Bar' -Valid
            
            $Arguments = ModuleProjectArgumentCompleter ''

            $Arguments | Should -Be @('Bar','Foo')
        }

        It 'Gets all valid modules that match the WordToComplete' {
            Add-TestModule 'Foo' -Valid
            
            $Arguments = ModuleProjectArgumentCompleter -WordToComplete 'F'

            $Arguments | Should -Be @('Foo')
        }

        It 'Should throw no error if no modules exist' {          
            {ModuleProjectArgumentCompleter } | Should -Not -Throw
        }
    }

    describe 'Get-ApprovedVerbsArgument' {
        It 'Gets approved verbs' {
            $ApprovedVerbs = [HashSet[String]]::new()
            (Get-Verb) | Select-Object -Property Verb | ForEach-Object {$ApprovedVerbs.Add("$($_.Verb)")}

            $Arguments = ApprovedVerbsArgumentCompleter | ForEach-Object { 
                ($_ -replace '-', '')
            }

            foreach($Argument in $Arguments) {
                $ApprovedVerbs.Contains($Argument) | Should -be $True
            }
        }

        It 'Ends each verb with dash' {
            ApprovedVerbsArgumentCompleter | ForEach-Object { 
                $_.EndsWith('-') | Should -Be $True
            }
        }

        It 'shows all words that match a pattern' {
            ApprovedVerbsArgumentCompleter -WordToComplete 'g' | ForEach-Object {
                $_.StartsWith('G') | Should -Be $True
            }
        }
    }

    describe 'Get-CommandFromModuleArgument' {
        BeforeAll {
            function Get-FakeBoundParameters{
                param([String]$ModuleProject)
                return @{
                    'ModuleProject' = $ModuleProject
                }
            }

        }
        It 'Should throw no error if no commands exist' {
            Add-TestModule $ViableModule -Valid
            Add-TestModule 'Foo' -Valid
            Add-TestFunction 'Foo' 'Write-HelloWorld'

            { CommandFromModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters $ViableModule)} | Should -Not -Throw
        }

        It 'Should show all commands that exist in module from given parameters' {
            $ExpectedFunctions = @('Test-HelloWorld','Test-HowdyWorld')
            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases

            foreach ($function in $ExpectedFunctions) {
                Add-TestFunction $ViableModule $function
            }

            $Arguments = CommandFromModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters $ViableModule)

            $Arguments | Should -Be $ExpectedFunctions
        }

        It 'Should show all commands that exist in module from given parameters that match WordToComplete' {
            $ExpectedFunction = 'Test-HelloWorld'
            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestFunction $ViableModule $ExpectedFunction
            Add-TestFunction $ViableModule 'Assert-HowdyWorld'
            

            $Arguments = CommandFromModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters $ViableModule) -WordToComplete 'T'

            $Arguments | Should -Be @($ExpectedFunction)
        }

        It 'Should throw no error if module does not exist' {
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestFunction 'Foo' 'Write-HelloWorld'

            { CommandFromModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters $ViableModule) } | Should -Not -Throw
        }

        It 'Should return Aliases if any exist' {
            $ExpectedAliases = @('Hello','Howdy')
            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases

            foreach ($Alias in $ExpectedAliases) {
                Add-TestAlias $ViableModule $Alias
            }

            $Arguments = CommandFromModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters $ViableModule)

            $Arguments | Should -Be $ExpectedAliases
        }

        It 'Should return both Aliases and functions' {
            $ExpectedFunctions = @('Test-HelloWorld', 'Test-HowdyWorld')
            $ExpectedAliases = @('Hello','Howdy')
            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            foreach ($function in $ExpectedFunctions) {
                Add-TestFunction $ViableModule $function
            }

            foreach ($Alias in $ExpectedAliases) {
                Add-TestAlias $ViableModule $Alias
            }

            $Arguments = CommandFromModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters $ViableModule) 

            $Arguments | Should -Be ($ExpectedFunctions += $ExpectedAliases)
        }
    }

    describe 'CommandFromOptionalModuleArgumentCompleter' {
        BeforeAll {
            function Get-FakeBoundParameters{
                param([String]$ModuleProject)
                return @{
                    'ModuleProject' = $ModuleProject
                }
            }

        }

        It 'Should show all commands that exist in module' {
            $ExpectedFunctions = @('Test-HelloWorld','Test-HowdyWorld')
            $ExpectedAliases = @('Bar','Foo')

            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            foreach ($function in $ExpectedFunctions) {
                Add-TestFunction $ViableModule $function
            }

            foreach($alias in $ExpectedAliases) {
                Add-TestAlias $ViableModule $alias
            }

            $Arguments = CommandFromOptionalModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters $ViableModule)

            $Arguments | Should -Be @($ExpectedFunctions + $ExpectedAliases)
        }
        
        
        It 'Should show all commands that exist in all modules' {
            $ExpectedFunctions = @('Test-HelloWorld','Test-HowdyWorld')
            $ExpectedAliases = @('Bar','Foo')
            $ExpectedOtherFunctions = @('Foo-Bar')
            $ExpectedOtherAliases = @('WIP')

            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestModule 'zFoo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            foreach ($function in $ExpectedFunctions) {
                Add-TestFunction $ViableModule $function
            }

            foreach($alias in $ExpectedAliases) {
                Add-TestAlias $ViableModule $alias
            }

            foreach($function in $ExpectedOtherFunctions) {
                Add-TestFunction 'zFoo' $function
            }

            foreach($alias in $ExpectedOtherAliases) {
                Add-TestAlias 'zFoo' $alias
            }

            $Arguments = CommandFromOptionalModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters '')

            $Arguments | Should -Be @($ExpectedFunctions + $ExpectedAliases + $ExpectedOtherFunctions + $ExpectedOtherAliases)
        }

        It 'Should show all commands that exist in module from given parameters that match WordToComplete' {
            $ExpectedFunction = 'Test-HelloWorld'
            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestFunction $ViableModule $ExpectedFunction
            Add-TestFunction $ViableModule 'Assert-HowdyWorld'
            

            $Arguments = CommandFromOptionalModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters '') -WordToComplete 'T'

            $Arguments | Should -Be @($ExpectedFunction)
        }
    }

    describe 'CommandFromNewModuleArgumentCompleter' {
        BeforeAll {
            function Get-FakeBoundParameters{
                param(
                    [String]$ModuleProject,
                    [String]$CommandName
                )
                return @{
                    'ModuleProject' = $ModuleProject
                    'CommandName' = $CommandName
                }
            }

        }

       it 'Should show Approved Verbs if CommandName is a Function' {
            $ExpectedFunction = 'Test-HelloWorld'
            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestFunction $ViableModule $ExpectedFunction

            $Arguments = NewCommandFromModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters $ViableModule -CommandName $ExpectedFunction)

            $Arguments -contains 'Get-' | Should -BeTrue
       }

       it 'should not return anything if CommandName is not a function' {
            $ExpectedAlias = 'Test'
            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestAlias $ViableModule $ExpectedAlias

            $Arguments = NewCommandFromModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters $ViableModule -CommandName $ExpectedAlias)

            $Arguments | Should -Be $Null
       }
    }
}