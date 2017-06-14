Import-Module "$PSScriptRoot\..\Remedy\*.psd1" -Force


Describe "Get-RemedyTicket" -Tag Integration {
    
    Context "By ID" {

        $Ticket = Get-RemedyTicket -ID INC000002139774 -Exact -Full

        It "Should return ticket data" {
            $Ticket | Should Not BeNullOrEmpty
        }
        It "Should return an Incident Number property" {
            $Ticket.'Incident Number' | Should Be 'INC000002139774'
        }
        It "Should return 1 ticket" {
            @($Ticket).count | Should Be 1
        }
        It "Should be a [PSCustomObject]" {
            $Ticket | Should BeOfType PSCustomObject
        }
    }
    
    Context "By Team" {

        $Tickets = Get-RemedyTicket -Team Windows_T3 -After (get-date).AddMonths(-1) -Exact -Full

        It "Should return ticket data" {
            $Tickets | Should Not BeNullOrEmpty
        }
        It "Should return an Incident Number property" {
            $Tickets.'Incident Number' | Should Not BeNullOrEmpty
        }
        It "Should return at least 1 ticket" {
            @($Tickets).count | Should BeGreaterThan 1
        }
        It "Should be a [PSCustomObject]" {
            $Tickets | Should BeOfType PSCustomObject
        }
    }
}
