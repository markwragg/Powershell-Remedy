BeforeAll {
    $here = $PSScriptRoot
    $sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
    $sut | ForEach-Object { . $_.FullName }
}


Describe 'Get-RemedyTeam' -Tag Unit {

    BeforeAll {
        Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }
        Mock Test-RemedyApiConfig -Verifiable { $true }
        Mock Get-RemedyInterface -Verifiable { @{ 'Support Group ID' = 'SGP000000001234' } }
        Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyTeam-InvokeRestMethod.xml }
    }

    Context 'Valid team' {

        It 'Should not Throw for a valid team' {
            { Get-RemedyTeam -Name 'Reporters' } | Should -Not -Throw
        }

        It 'Should Not be Null or Empty for a valid team' {
            Get-RemedyTeam -Name 'Reporters' | Should -Not -BeNullOrEmpty
        }

        It 'Should return <_>' -ForEach 'Clark Kent', 'Lois Lane' {
            $SomeTeam = Get-RemedyTeam -Name 'Reporters'
            $_ -in $SomeTeam.'Full Name' | Should -Be $true
        }

        It 'Should return a <_> property' -ForEach 'Full Name', 'Login ID' {
            $SomeTeam = Get-RemedyTeam -Name 'Reporters'
            $SomeTeam.$_ | Should -Not -Be $null
        }
    }


    Context 'Valid team with -Full details' {

        It 'Should not Throw for a valid team' {
            { Get-RemedyTeam -Name 'Reporters' -Full } | Should -Not -Throw
        }

        It 'Should Not be Null or Empty for a valid team' {
            Get-RemedyTeam -Name 'Reporters' -Full | Should -Not -BeNullOrEmpty
        }

        It 'Should return <_>' -ForEach 'Clark Kent', 'Lois Lane' {
            $SomeTeamFull = Get-RemedyTeam -Name 'Reporters' -Full
            $_ -in $SomeTeamFull.'Full Name' | Should -Be $true
        }

        It 'Should return a <_> property' -ForEach 'Full Name', 'Login ID', 'Status', 'Submit Date' {
            $SomeTeamFull = Get-RemedyTeam -Name 'Reporters' -Full
            $SomeTeamFull.$_ | Should -Not -Be $null
        }
    }

    Context 'Invalid Team' {

        BeforeAll {
            Mock Get-RemedyInterface -Verifiable { }
        }

        It 'Should Throw for an invalid team' {
            { Get-RemedyTeam -Name 'SuperVillians' } | Should -Throw
        }
    }

    Context 'Failed API config test' {

        BeforeAll {
            Mock Test-RemedyApiConfig -Verifiable { $false }
        }

        It 'Should Throw' {
            { Get-RemedyTeam -Name 'Reporters' } | Should -Throw -ExpectedMessage 'Remedy API Test failed. Ensure the config has been set correctly via Set-RemedyApiConfig.'
        }
    }

    Context 'API connectivity error' {

        BeforeAll {
            Mock Invoke-RestMethod -Verifiable { throw 'Some error' }
        }

        It 'Should write a non-terminating error without throwing' {
            { Get-RemedyTeam -Name 'Reporters' -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }

    It 'Should have invoked all verifiable mocks' {
        Should -InvokeVerifiable
    }
}
