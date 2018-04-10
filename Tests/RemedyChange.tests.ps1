$here = $PSScriptRoot
$sut = Get-ChildItem "$here\..\Remedy\*.ps1" -Recurse -File
$sut | ForEach-Object { . $_.FullName }

Describe 'Get-RemedyChange' -Tag Unit {
    
    Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }
    
    Mock Test-RemedyApiConfig -Verifiable { $True }
    
    Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyChange-InvokeRestMethod.xml }

    It 'Should Throw if no search criteria is provided' {
        {Get-RemedyChange} | Should Throw
    }
    
    'ID','Team','Customer','Assignee','Submitter' | ForEach-Object {
        
        $Param = @{$_ = 'SomeValue'}
    
        It "Should return if $_ is provided" {
            {Get-RemedyChange @Param} | Should Not Throw
            Get-RemedyChange @Param | Should Not Be NullOrEmpty
        }
    }

    'AllOpen','AllClosed','Draft','Request For Authorization','Request For Change','Planning In Progress','Scheduled For Review',
    'Scheduled For Approval','Scheduled','Implementation In Progress','Pending','Rejected','Completed','Closed','Cancelled' | ForEach-Object {
        
        $Param = @{Status = $_}
    
        It "Should return if Status = $_ is provided" {
            {Get-RemedyChange @Param} | Should Not Throw
            Get-RemedyChange @Param | Should Not Be NullOrEmpty
        }
    }
    
    'Pending','Approved','Rejected' | ForEach-Object {
        
        $Param = @{ApprovalStatus = $_}
    
        It "Should return if Status = $_ is provided" {
            {Get-RemedyChange @Param} | Should Not Throw
            Get-RemedyChange @Param | Should Not Be NullOrEmpty
        }
    }

    'Type','ExcludeType' | ForEach-Object {
        $PropertyName = $_

        'Normal','Standard','Expedited','Emergency','Latent','No Impact' | ForEach-Object {
        
            $Param = @{$PropertyName = $_}
    
            It "Should return if $PropertyName = $_ is provided" {
                {Get-RemedyChange @Param} | Should Not Throw
                Get-RemedyChange @Param | Should Not Be NullOrEmpty
            }
        }
    }

    'Low','Medium','High','Critical' | ForEach-Object {
        
        $Param = @{Priority = $_}
    
        It "Should return if Priority = $_ is provided" {
            {Get-RemedyChange @Param} | Should Not Throw
            Get-RemedyChange @Param | Should Not Be NullOrEmpty
        }
    }

    Context 'Valid Change' {

        It 'Should not Throw for a valid Change' {
            {Get-RemedyChange -ID 'ValidID'} | Should Not Throw
        }
    
        $SomeChange = Get-RemedyChange -ID 'ValidID'

        It 'Should Not be Null or Empty for a valid Change' {
            $SomeChange | Should Not BeNullOrEmpty
        }
    }

    Context 'Valid Change with -Full details' {

        It 'Should not Throw for a valid Change' {
            {Get-RemedyChange -ID 'ValidID' -Full} | Should Not Throw
        }
    
        $SomeChangeFull = Get-RemedyChange -ID 'ValidID' -Full
       
        It 'Should Not be Null or Empty for a valid Change' {
            $SomeChangeFull | Should Not BeNullOrEmpty
        }

    }

    Mock Invoke-RestMethod  -Verifiable { }
    
    Context 'Invalid Change' {

        It 'Should be Null or Empty for an invalid Change' {
            Get-RemedyChange -ID 'InvalidID' | Should Be $null
        }
    }

    Assert-VerifiableMock
}