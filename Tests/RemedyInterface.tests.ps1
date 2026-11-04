BeforeAll {
    $here = $PSScriptRoot
    $sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
    $sut | ForEach-Object { . $_.FullName }
}


Describe 'Get-RemedyInterface' -Tag Unit {

    BeforeAll {
        Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }
        Mock Test-RemedyApiConfig -Verifiable { $true }
        Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyInterface-InvokeRestMethod.xml }
    }

    It 'Should not Throw' {
        { Get-RemedyInterface } | Should -Not -Throw
    }

    It 'Should not be Null or Empty' {
        Get-RemedyInterface | Should -Not -BeNullOrEmpty
    }

    It 'Should return <_>' -ForEach 'AR System Administration: Server Information',
    'AR System Report Console',
    'AST:AssetMaintenance',
    'HPD:Help Desk' {
        $Interface = Get-RemedyInterface
        $Interface -contains $_ | Should -Be $true
    }

    Context 'Failed API config test' {

        BeforeAll {
            Mock Test-RemedyApiConfig -Verifiable { $false }
        }

        It 'Should Throw' {
            { Get-RemedyInterface } | Should -Throw -ExpectedMessage 'Remedy API Test failed. Ensure the config has been set correctly via Set-RemedyApiConfig.'
        }
    }

    Context 'Failed API connectivity' {

        BeforeAll {
            Mock Invoke-RestMethod -Verifiable { throw 'Some error' }
        }

        It 'Should Throw' {
            { Get-RemedyInterface } | Should -Throw -ExpectedMessage 'Some error'
        }
    }


    It 'Should have invoked all verifiable mocks' {
        Should -InvokeVerifiable
    }
}
