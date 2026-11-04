BeforeAll {
    $here = $PSScriptRoot
    $sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
    $sut | ForEach-Object { . $_.FullName }
}

Describe 'Invoke-Remedy' -Tag Unit {

    BeforeAll {
        Mock Get-RemedyApiConfig -Verifiable { @{ IncidentURL = 'https://mock.setconfig.com/arsys/forms/helpdesk' } }
        Mock Start-Process -Verifiable { }
    }

    It 'Should not Throw for a single ID' {
        { Invoke-Remedy -ID 'INC000002264704' } | Should -Not -Throw
    }

    It 'Should open the incident URL' {
        Invoke-Remedy -ID 'INC000002264704'
        Should -Invoke -CommandName 'Start-Process' -Times 1 -Exactly
    }

    It 'Should pad a short numeric ID to a full Incident Number' {
        Invoke-Remedy -ID '2264704'
        Should -Invoke -CommandName 'Start-Process' -ParameterFilter { $Path -like '*INC000002264704*' }
    }

    It 'Should accept input by ticket object' {
        $Ticket = [PSCustomObject]@{ 'Incident Number' = 'INC000002264704' }
        { $Ticket | Invoke-Remedy } | Should -Not -Throw
    }

    It 'Should Throw if input object has no Incident Number property' {
        $NotATicket = [PSCustomObject]@{ 'Some Other Property' = 'Value' }
        { $NotATicket | Invoke-Remedy } | Should -Throw -ExpectedMessage "Input object did not have an 'Incident Number' property"
    }

    Context 'Missing Incident URL configuration' {

        BeforeAll {
            Mock Get-RemedyApiConfig -Verifiable { @{ IncidentURL = $null } }
        }

        It 'Should Throw' {
            { Invoke-Remedy -ID 'INC000002264704' } | Should -Throw -ExpectedMessage 'Could not get Remedy Incident URL. Please Use Set-RemedyApiConfig first'
        }
    }

    Context 'Opening more than 5 URLs' {

        BeforeAll {
            Mock Read-Host -Verifiable { 'y' }
        }

        It 'Should prompt to continue after the 5th URL and continue when confirmed' {
            { 1..6 | ForEach-Object { "INC00000000000$_" } | Invoke-Remedy } | Should -Not -Throw
            Should -Invoke -CommandName 'Read-Host' -Times 1 -Exactly
            Should -Invoke -CommandName 'Start-Process' -Times 6 -Exactly
        }
    }

    Context 'Opening more than 5 URLs and declining to continue' {

        BeforeAll {
            Mock Read-Host -Verifiable { 'n' }
        }

        It 'Should Throw once the user declines to continue' {
            { 1..5 | ForEach-Object { "INC00000000000$_" } | Invoke-Remedy } | Should -Throw -ExpectedMessage 'Stopped by user choice.'
        }
    }

    Context 'Opening more than 5 URLs with -Force' {

        BeforeAll {
            Mock Read-Host { 'y' }
        }

        It 'Should not prompt' {
            { 1..6 | ForEach-Object { "INC00000000000$_" } | Invoke-Remedy -Force } | Should -Not -Throw
            Should -Invoke -CommandName 'Read-Host' -Times 0 -Exactly
        }
    }

    It 'Should have invoked all verifiable mocks' {
        Should -InvokeVerifiable
    }
}
