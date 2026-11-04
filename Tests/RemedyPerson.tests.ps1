BeforeAll {
    $here = $PSScriptRoot
    $sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
    $sut | ForEach-Object { . $_.FullName }
}

$PersonCases = '', 'Staff', 'Exact', @('Staff', 'Exact') | ForEach-Object {

    $Settings = @{ Name = 'Clark Kent' }

    foreach ($Switch in @($_)) {
        if ($Switch -eq 'Staff') { $Settings.Staff = $true }
        if ($Switch -eq 'Exact') { $Settings.Exact = $true }
    }

    $Option = if ($_) { '-' + (@($_) -Join ' -') } else { '' }

    @{ Settings = $Settings; Option = $Option }
}

Describe 'Get-RemedyPerson' -Tag Unit {

    BeforeAll {
        Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }

        Mock Test-RemedyApiConfig -Verifiable { $true }

        Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyPerson-InvokeRestMethod.xml }
    }

    Context 'Valid user tests for Get-RemedyPerson <Option>' -ForEach $PersonCases {

        It 'Should not Throw for a valid user' {
            { Get-RemedyPerson @Settings } | Should -Not -Throw
        }

        It 'Should Not be Null or Empty for a valid user' {
            Get-RemedyPerson @Settings | Should -Not -BeNullOrEmpty
        }

        It 'Should return Clark Kent' {
            (Get-RemedyPerson @Settings).'Full Name' | Should -Be 'Clark Kent'
        }

        It 'Should return a <_> property' -ForEach 'Full Name', 'Remedy Login ID', 'JobTitle', 'Company', 'Internet E-mail', 'Support Staff', 'Submit Date' {
            (Get-RemedyPerson @Settings).$_ | Should -Not -Be $null
        }
    }

    Context 'Valid user tests for Get-RemedyPerson -Full <Option>' -ForEach $PersonCases {

        It 'Should Not be Null or Empty for a valid user with -Full details' {
            Get-RemedyPerson @Settings -Full | Should -Not -BeNullOrEmpty
        }

        It "Should return Clark Kent's Nick Name as 'Superman'" {
            (Get-RemedyPerson @Settings -Full).'Nick Name' | Should -Be 'Superman'
        }

        It 'Should return a <_> property' -ForEach 'Full Name', 'Remedy Login ID', 'JobTitle', 'Company', 'Internet E-mail', 'Support Staff', 'Submit Date' {
            (Get-RemedyPerson @Settings -Full).$_ | Should -Not -Be $null
        }
    }

    Context 'Invalid User for Get-RemedyPerson <Option>' -ForEach $PersonCases {

        BeforeAll {
            Mock Invoke-RestMethod -Verifiable { }
        }

        It 'Should not Throw for an invalid user' {
            { Get-RemedyPerson @Settings } | Should -Not -Throw
        }

        It 'Should be Null or Empty for an invalid user' {
            Get-RemedyPerson @Settings | Should -BeNullOrEmpty
        }
    }

    Context 'Failed API config test for Get-RemedyPerson <Option>' -ForEach $PersonCases {

        BeforeAll {
            Mock Test-RemedyApiConfig -Verifiable { }
        }

        It 'Should Throw' {
            { Get-RemedyPerson @Settings } | Should -Throw -ExpectedMessage 'Remedy API Test failed. Ensure the config has been set correctly via Set-RemedyApiConfig.'
        }
    }

    It 'Should have invoked all verifiable mocks' {
        Should -InvokeVerifiable
    }
}
