$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$tfn = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$sut = Get-ChildItem "$here\..\Remedy\*-$tfn" -Recurse
$sut | ForEach-Object { . $_.FullName }


Describe 'Get-RemedyPerson' -Tag Unit {
    
    Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }
    Mock Test-RemedyApiConfig -Verifiable { $True }
    
    Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyPerson-InvokeRestMethod.xml }
    
    Context 'Valid user' {

        It 'Should not Throw for a valid user' {
            {Get-RemedyPerson -Name 'Clark Kent'} | Should Not Throw
        }
    
        $SomeUser = Get-RemedyPerson -name 'Clark Kent'

        It 'Should Not be Null or Empty for a valid user' {
            $SomeUser | Should Not BeNullOrEmpty
        }

        It 'Should return Clark Kent' {
            $SomeUser.'Full Name' | Should Be 'Clark Kent'
        }

        'Full Name','Remedy Login ID','JobTitle','Company','Internet E-mail','Support Staff','Submit Date' | ForEach-Object {
            It "Should return a $_ property" {
                $SomeUser.$_ | Should Not Be $null
            }
        }
    }

    Context 'Valid user with -Full details' {

        $SomeUserFull = Get-RemedyPerson -name 'Clark Kent' -Full

        It 'Should Not be Null or Empty for a valid user with -Full details' {
            $SomeUserFull | Should Not BeNullOrEmpty
        }

        It "Should return Clark Kent's Nick Name as 'Superman'" {
            $SomeUserFull.'Nick Name' | Should Be 'Superman'
        }

        'Full Name','Remedy Login ID','JobTitle','Company','Internet E-mail','Support Staff','Submit Date' | ForEach-Object {
            It "Should return a $_ property" {
                $SomeUserFull.$_ | Should Not Be $null
            }
        }
    }

    Mock Invoke-RestMethod -Verifiable { }
    
    Context 'Invalid User' {

        It 'Should not Throw for an invalid user' {
            {Get-RemedyPerson -Name 'NotAUser'} | Should Not Throw
        }

        $NotAUser = Get-RemedyPerson -name 'NotAUser'

        It 'Should be Null or Empty for an invalid user' { 
            $NotAUser | Should BeNullOrEmpty 
        }
    }

    Assert-VerifiableMocks
}