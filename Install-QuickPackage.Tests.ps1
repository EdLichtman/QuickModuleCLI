$here = (Split-Path -Parent $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

Describe 'Install-QuickPackage' {
    BeforeAll {
        $UnderTest = $true
        . ".\Required\Reserved\Import-TestHeader.ps1"
        # Mock Remove-QuickUtilityBelt
        # Mock Remove-QuickPackage
        # Mock Add-QuickPackage
        # Mock Add-QuickPackageToProfile
        # Mock Add-QuickUtility
    }

    It "does nothing if no flag is called" {
        

        Install-QuickPackage
        Assert-MockCalled Remove-QuickUtilityBelt -Times 0
        Assert-MockCalled Remove-QuickPackage -Times 0
        Assert-MockCalled Add-QuickPackage -Times 0
        Assert-MockCalled Add-QuickPackageToProfile -Times 0
        Assert-MockCalled Add-QuickUtility -Times 0
        
    }
}

