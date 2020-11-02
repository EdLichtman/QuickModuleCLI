describe 'Argument Transformations' {
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
        . "$PSScriptRoot\ArgumentTransformations.ps1"
        . "$PSScriptRoot\Validators.ps1"

        $ViableModule = "Viable"
        $NonviableModule = "Nonviable"
        $ArgumentException = 'System.ArgumentException'
        $ParameterBindingException = 'System.Management.Automation.ParameterBindingException'
    }
    
    describe 'SemicolonCreatesLineBreakTranformAttribute' {
        BeforeAll {
            function Test-SemicolonCreatesLineBreakTransform {
                param(
                    [SemicolonCreatesLineBreakTransformation()]
                    [String]
                    $Test
                )
                return $Test;
            }
        }

        It "throws error if non-string value is sent in" {
            $DateTime = [DateTime]'2020-01-01'
            { Test-SemicolonCreatesLineBreakTransform -Test $DateTime } | Should -Throw -ExceptionType $ParameterBindingException
        }

        It "does nothing if string has no semicolon" {
            $ExpectedValue = 'Hello World'
            $ActualValue = Test-SemicolonCreatesLineBreakTransform -Test $ExpectedValue
            $ActualValue | Should -Be $ExpectedValue
        }

        It "automatically replaces semi-colons with line breaks" {
            $actualInput = "Write-Output 'hello';return;"

            # 2nd-to-last line ends with Semi-colon but should not creates extra blank line
            $expectedOutput = 
@"
Write-Output 'hello';
return;
"@

            $actualOutput = Test-SemicolonCreatesLineBreakTransform -Test $actualInput

            $actualOutput | Should -Be $expectedOutput
         }

        It "does not replace semi-colons within single-quote strings" {
            $actualInput = "Write-Output 'hello; world';return;"

            $expectedOutput = 
@"
Write-Output 'hello; world';
return;
"@

            $actualOutput = Test-SemicolonCreatesLineBreakTransform -Test $actualInput

            $actualOutput | Should -Be $expectedOutput
        }

        It "does not replace semi-colons within double-quote strings" {
            $actualInput = 'Write-Output "hello; world";return;'
            # 2nd-to-last line of function contains 4 spaces
            $expectedOutput = 
@"
Write-Output "hello; world";
return;
"@

            $actualOutput = Test-SemicolonCreatesLineBreakTransform -Test $actualInput

            $actualOutput | Should -Be $expectedOutput
            
        }

    }

}