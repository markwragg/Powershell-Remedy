BeforeAll {
    $here = $PSScriptRoot
    $sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
    $sut | ForEach-Object { . $_.FullName }
}

Describe 'Get-RemedyTicket' -Tag Integration {
    Import-Module "$PSScriptRoot\..\Remedy\*.psd1" -Force

    Context 'By ID' {

        BeforeAll {
            $Ticket = Get-RemedyTicket -ID INC000002139774 -Exact -Full
        }

        It 'Should return ticket data' {
            $Ticket | Should -Not -BeNullOrEmpty
        }
        It 'Should return an Incident Number property' {
            $Ticket.'Incident Number' | Should -Be 'INC000002139774'
        }
        It 'Should return 1 ticket' {
            @($Ticket).count | Should -Be 1
        }
        It 'Should be a [PSCustomObject]' {
            $Ticket | Should -BeOfType [System.Management.Automation.PSCustomObject]
        }
    }

    Context 'By Team' {

        BeforeAll {
            $Tickets = Get-RemedyTicket -Team Windows_T3 -After (Get-Date).AddMonths(-1) -Exact -Full
        }

        It 'Should return ticket data' {
            $Tickets | Should -Not -BeNullOrEmpty
        }
        It 'Should return an Incident Number property' {
            $Tickets.'Incident Number' | Should -Not -BeNullOrEmpty
        }
        It 'Should return at least 1 ticket' {
            @($Tickets).count | Should -BeGreaterThan 1
        }
        It 'Should be a [PSCustomObject]' {
            $Tickets | Should -BeOfType [System.Management.Automation.PSCustomObject]
        }
    }
}
