$here = $PSScriptRoot
$sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
$sut | ForEach-Object { . $_.FullName }


Describe "Get-RemedyInterface" -Tag Unit {
    
    Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }
    Mock Test-RemedyApiConfig -Verifiable { $True }
    Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyInterface-InvokeRestMethod.xml }
    
    It "Should not Throw" {
        {Get-RemedyInterface} | Should Not Throw
    }

    $Interface = Get-RemedyInterface

    It "Should not be Null or Empty" {
        $Interface | Should Not BeNullOrEmpty
    }

    'AR System Administration: Server Information',
    'AR System Report Console',
    'AST:AssetMaintenance',
    'HPD:Help Desk' | ForEach-Object {
    
        It "Should return $_" {
            $Interface -contains $_ | Should Be True
        }
    }

    Context 'Failed API config test' {

        Mock Test-RemedyApiConfig -Verifiable { $False }
    
        It "Should Throw" {
            {Get-RemedyInterface} | Should Throw 'Remedy API Test failed. Ensure the config has been set correctly via Set-RemedyApiConfig.'
        }
    }

    Context 'Failed API connectivity' {

        Mock Invoke-RestMethod -Verifiable { Throw 'Some error' }
    
        It "Should Throw" {
            {Get-RemedyInterface} | Should Throw 'Some error'
        }
    }


    Assert-VerifiableMocks
}