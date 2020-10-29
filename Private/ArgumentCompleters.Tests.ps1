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
        . "$PSScriptRoot\PrivateFunctions.ps1"

        $ViableModule = "Viable"
        $NonviableModule = "Nonviable"
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
   
    describe 'Get-ModuleProjectChoices' {
        It 'Throws Error if no viable modules exist' {
            { Get-ModuleProjectChoices } | Should -Throw -ExceptionType 'System.Management.Automation.ItemNotFoundException'
        }

        It 'Uses Tested Get-ValidModuleProjects logic to figure out Valid Choices' {
            Mock Get-ValidModuleProjectNames { return @('Test') }
            Get-ModuleProjectChoices 

            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }

        It 'Does not consider a folder without psd1 and psm1 as a viable module' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases
            Add-TestModule -Name $NonViableModule

            Get-ModuleProjectChoices | Should -not -contain $NonViableModule
        }
        
        It 'Does not throw error if a viable module exists' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot -IncludeFunctions -IncludeAliases

            { Get-ModuleProjectChoices } | Should -Not -Throw -ExceptionType 'System.Management.Automation.ItemNotFoundException'
        }

        It 'Gets all valid Module Project choices' {
            Add-TestModule -Name $ViableModule -IncludeManifest -IncludeRoot  -IncludeFunctions -IncludeAliases

            Get-ModuleProjectChoices | Should -contain $ViableModule
        }
    }

    describe 'ModuleProjectArgument' {
        It 'Uses Tested Get-ValidModuleProjects logic to figure out Valid Choices' {
            Mock Get-ValidModuleProjectNames { return @('Test') }
            [ModuleProjectArgument]::GetArguments('')

            Assert-MockCalled Get-ValidModuleProjectNames -Times 1
        }


        It 'Gets all valid Module Project choices' {
            $ExpectedArguments = @('Foo','Bar')
            Mock Get-ValidModuleProjectNames { return $ExpectedArguments }
            
            $Arguments = [ModuleProjectArgument]::GetArguments('')

            $Arguments | Should -Be $ExpectedArguments
        }

        It 'Gets all valid modules that match the WordToComplete' {
            $ExpectedArgument = @('Foo')
            Mock Get-ValidModuleProjectNames { return @($expectedArgument, 'Bar') }
            
            $Arguments = [ModuleProjectArgument]::GetArguments('F')

            $Arguments | Should -Be @($ExpectedArgument)
        }

        It 'Should return [None] if no modules exist' {
            Mock Get-ValidModuleProjectNames { return @() }
            
            $Arguments = [ModuleProjectArgument]::GetArguments('')

            $Arguments | Should -Be @('[None]')
        }
    }

    describe 'ApprovedVerbsArgument' {
        It 'Gets approved verbs' {
            $ApprovedVerbs = [HashSet[String]]::new()
            (Get-Verb) | Select-Object -Property Verb | ForEach-Object {$ApprovedVerbs.Add("$($_.Verb)")}

            $Arguments = [ApprovedVerbsArgument]::GetArguments('') | ForEach-Object { 
                ($_ -replace '-', '')
            }

            foreach($Argument in $Arguments) {
                $ApprovedVerbs.Contains($Argument) | Should -be $True
            }
        }

        It 'Ends each verb with dash' {
            [ApprovedVerbsArgument]::GetArguments('') | ForEach-Object { 
                $_.EndsWith('-') | Should -Be $True
            }
        }

        It 'shows all words that match a pattern' {
            [ApprovedVerbsArgument]::GetArguments('g') | ForEach-Object {
                $_.StartsWith('G') | Should -Be $True
            }
        }
    }

    describe 'CommandFromModuleArgument' {
        It 'Should return [None] if no commands exist' {
            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestFunction 'Foo' 'Write-HelloWorld'

            $Arguments = [CommandFromModuleArgument]::GetArguments($ViableModule,'')

            $Arguments | Should -Be @('[None]')
        }

        It 'Should show all commands that exist in module from given parameters' {
            $ExpectedFunctions = @('Test-HelloWorld', 'Test-HowdyWorld')
            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            foreach ($function in $ExpectedFunctions) {
                Add-TestFunction $ViableModule $function
            }

            $Arguments = [CommandFromModuleArgument]::GetArguments($ViableModule,'')

            $Arguments | Should -Be $ExpectedFunctions
        }

        It 'Should show all commands that exist in module from given parameters that match WordToComplete' {
            $ExpectedFunction = 'Test-HelloWorld'
            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestFunction $ViableModule $ExpectedFunction
            Add-TestFunction $ViableModule 'Assert-HowdyWorld'
            

            $Arguments = [CommandFromModuleArgument]::GetArguments($ViableModule,'T')

            $Arguments | Should -Be @($ExpectedFunction)
        }

        It 'Should return [Invalid] if module does not exist' {
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestFunction 'Foo' 'Write-HelloWorld'

            $Arguments = [CommandFromModuleArgument]::GetArguments($ViableModule,'')

            $Arguments | Should -Be @('[invalid]')
        }

        It 'Should return Aliases if any exist' {
            $ExpectedAliases = @('Hello','Howdy')
            Add-TestModule $ViableModule -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases
            Add-TestModule 'Foo' -IncludeRoot -IncludeManifest -IncludeFunctions -IncludeAliases

            foreach ($Alias in $ExpectedAliases) {
                Add-TestAlias $ViableModule $Alias
            }

            $Arguments = [CommandFromModuleArgument]::GetArguments($ViableModule,'')

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

            $Arguments = [CommandFromModuleArgument]::GetArguments($ViableModule,'')

            $Arguments | Should -Be ($ExpectedFunctions += $ExpectedAliases)
        }
    }
}