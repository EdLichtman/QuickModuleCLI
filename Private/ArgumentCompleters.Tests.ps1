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

        . "$PSScriptRoot\Environment.ps1"
        . "$PSScriptRoot\ArgumentCompleters.ps1"
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
        Remove-Sandbox
    }

    describe 'ModuleProjectArgument' {
        It 'Uses Tested Get-ValidModuleProjects logic to figure out Valid Choices' {
            Mock Get-ValidModuleProjectNames { return @('Test') }
            Get-ModuleProjectArgumentCompleter ''

            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }


        It 'Gets all valid Module Project choices' {
            $ExpectedArguments = @('Foo','Bar')
            Mock Get-ValidModuleProjectNames { return $ExpectedArguments }
            
            $Arguments = Get-ModuleProjectArgumentCompleter ''

            $Arguments | Should -Be $ExpectedArguments
        }

        It 'Gets all valid modules that match the WordToComplete' {
            $ExpectedArgument = @('Foo')
            Mock Get-ValidModuleProjectNames { return @($expectedArgument, 'Bar') }
            
            $Arguments = Get-ModuleProjectArgumentCompleter -WordToComplete 'F'

            $Arguments | Should -Be @($ExpectedArgument)
        }

        It 'Should throw error if no modules exist' {
            Mock Get-ValidModuleProjectNames { return @() }
            
            {Get-ModuleProjectArgumentCompleter } | Should -Throw -ExceptionType $InvalidOperationException
        }
    }

    describe 'ApprovedVerbsArgument' {
        It 'Gets approved verbs' {
            $ApprovedVerbs = [HashSet[String]]::new()
            (Get-Verb) | Select-Object -Property Verb | ForEach-Object {$ApprovedVerbs.Add("$($_.Verb)")}

            $Arguments = Get-ApprovedVerbsArgumentCompleter | ForEach-Object { 
                ($_ -replace '-', '')
            }

            foreach($Argument in $Arguments) {
                $ApprovedVerbs.Contains($Argument) | Should -be $True
            }
        }

        It 'Ends each verb with dash' {
            Get-ApprovedVerbsArgumentCompleter | ForEach-Object { 
                $_.EndsWith('-') | Should -Be $True
            }
        }

        It 'shows all words that match a pattern' {
            Get-ApprovedVerbsArgumentCompleter -WordToComplete 'g' | ForEach-Object {
                $_.StartsWith('G') | Should -Be $True
            }
        }
    }

    describe 'CommandFromModuleArgument' {
        BeforeAll {
            function Get-FakeBoundParameters{
                param([String]$ModuleProject)
                return @{
                    'ModuleProject' = $ModuleProject
                }
            }

        }
        It 'Should throw error if no commands exist' {
            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestFunction 'Foo' 'Write-HelloWorld'

            { Get-CommandFromModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters $ViableModule)} | Should -Throw -ExceptionType $InvalidOperationException
        }

        It 'Should show all commands that exist in module from given parameters' {
            $ExpectedFunctions = @('Test-HelloWorld','Test-HowdyWorld')
            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            foreach ($function in $ExpectedFunctions) {
                Add-TestFunction $ViableModule $function
            }

            $Arguments = Get-CommandFromModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters $ViableModule)

            $Arguments | Should -Be $ExpectedFunctions
        }

        It 'Should show all commands that exist in module from given parameters that match WordToComplete' {
            $ExpectedFunction = 'Test-HelloWorld'
            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestFunction $ViableModule $ExpectedFunction
            Add-TestFunction $ViableModule 'Assert-HowdyWorld'
            

            $Arguments = Get-CommandFromModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters $ViableModule) -WordToComplete 'T'

            $Arguments | Should -Be @($ExpectedFunction)
        }

        It 'Should throw error if module does not exist' {
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestFunction 'Foo' 'Write-HelloWorld'

            { Get-CommandFromModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters $ViableModule) } | Should -Throw -ExceptionType $InvalidOperationException
        }

        It 'Should return Aliases if any exist' {
            $ExpectedAliases = @('Hello','Howdy')
            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases

            foreach ($Alias in $ExpectedAliases) {
                Add-TestAlias $ViableModule $Alias
            }

            $Arguments = Get-CommandFromModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters $ViableModule)

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

            $Arguments = Get-CommandFromModuleArgumentCompleter -FakeBoundParameters (Get-FakeBoundParameters $ViableModule) 

            $Arguments | Should -Be ($ExpectedFunctions += $ExpectedAliases)
        }
    }
}