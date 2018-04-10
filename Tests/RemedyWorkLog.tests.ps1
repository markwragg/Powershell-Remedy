$here = $PSScriptRoot
$sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
$sut | ForEach-Object { . $_.FullName }


Describe 'Get-RemedyWorkLog' -Tag Unit {
    
    Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }
    
    Mock Test-RemedyApiConfig -Verifiable { $True }
    
    Mock Invoke-RestMethod -Verifiable { Import-Clixml $here\Mock-GetRemedyWorkLog-InvokeRestMethod.xml }

    It 'Should Throw if no search criteria is provided' {
        {Get-RemedyWorkLog} | Should Throw
    }
    
    'ID','Team','Title','Note','Submitter' | ForEach-Object {
        
        $Param = @{$_ = 'SomeValue'}
    
        It "Should return if $_ is provided" {
            {Get-RemedyWorkLog @Param} | Should Not Throw
            Get-RemedyWorkLog @Param | Should Not Be NullOrEmpty
        }
    }

    Context 'Valid worklog' {

        It 'Should not Throw for a valid worklog' {
            {Get-RemedyWorkLog -ID 'ValidID'} | Should Not Throw
        }
    
        $SomeTicket = Get-RemedyWorkLog -ID 'ValidID'

        It 'Should Not be Null or Empty for a valid worklog' {
            $SomeTicket | Should Not BeNullOrEmpty
        }
    }

    Context 'Valid worklog with -Full details' {

        It 'Should not Throw for a valid worklog' {
            {Get-RemedyWorkLog -ID 'ValidID' -Full} | Should Not Throw
        }
    
        $SomeTicketFull = Get-RemedyWorkLog -ID 'ValidID' -Full
       
        It 'Should Not be Null or Empty for a valid worklog' {
            $SomeTicketFull | Should Not BeNullOrEmpty
        }

    }

    Mock Invoke-RestMethod  -Verifiable { }
    
    Context 'Invalid worklog' {

        It 'Should be Null or Empty for an invalid worklog' {
            Get-RemedyWorkLog -ID 'InvalidID' | Should Be $null
        }
    }

    Assert-VerifiableMock
}