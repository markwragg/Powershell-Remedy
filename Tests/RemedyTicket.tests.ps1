$here = $PSScriptRoot
$sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
$sut | ForEach-Object { . $_.FullName }


Describe 'Get-RemedyTicket' -Tag Unit {
    
    Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }
    
    Mock Test-RemedyApiConfig -Verifiable { $True }
    
    Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyTicket-InvokeRestMethod.xml }

    It 'Should Throw if no search criteria is provided' {
        {Get-RemedyTicket} | Should Throw
    }
    
    'ID','Team','Customer','Assignee','Submitter' | ForEach-Object {
        
        $Param = @{$_ = 'SomeValue'}
    
        It "Should return if $_ is provided" {
            {Get-RemedyTicket @Param} | Should Not Throw
            Get-RemedyTicket @Param | Should Not Be NullOrEmpty
        }
    }

    'AllOpen','AllClosed','New','Assigned','In Progress','Pending','Closed','Resolved' | ForEach-Object {
        
        $Param = @{Status = $_}
    
        It "Should return if Status = $_ is provided" {
            {Get-RemedyTicket @Param} | Should Not Throw
            Get-RemedyTicket @Param | Should Not Be NullOrEmpty
        }
    }
    
    'Source','ExcludeSource' | ForEach-Object {
        $PropertyName = $_

        'Email','Automation','Phone','Self Service (Portal)','Event Management','Chat','Instant Message','E-Bonding' | ForEach-Object {
        
            $Param = @{$PropertyName = $_}
    
            It "Should return if $PropertyName = $_ is provided" {
                {Get-RemedyTicket @Param} | Should Not Throw
                Get-RemedyTicket @Param | Should Not Be NullOrEmpty
            }
        }
    }

    'Low','Medium','High','Critical' | ForEach-Object {
        
        $Param = @{Priority = $_}
    
        It "Should return if Priority = $_ is provided" {
            {Get-RemedyTicket @Param} | Should Not Throw
            Get-RemedyTicket @Param | Should Not Be NullOrEmpty
        }
    }

    Context 'Valid ticket' {

        It 'Should not Throw for a valid ticket' {
            {Get-RemedyTicket -ID 'ValidID'} | Should Not Throw
        }
    
        $SomeTicket = Get-RemedyTicket -ID 'ValidID'

        It 'Should Not be Null or Empty for a valid ticket' {
            $SomeTicket | Should Not BeNullOrEmpty
        }
    }

    Context 'Valid ticket with -Full details' {

        It 'Should not Throw for a valid ticket' {
            {Get-RemedyTicket -ID 'ValidID' -Full} | Should Not Throw
        }
    
        $SomeTicketFull = Get-RemedyTicket -ID 'ValidID' -Full
       
        It 'Should Not be Null or Empty for a valid ticket' {
            $SomeTicketFull | Should Not BeNullOrEmpty
        }

    }

    Mock Invoke-RestMethod  -Verifiable { }
    
    Context 'Invalid Ticket' {

        It 'Should be Null or Empty for an invalid ticket' {
            Get-RemedyTicket -ID 'InvalidID' | Should Be $null
        }
    }

    Assert-VerifiableMock
}