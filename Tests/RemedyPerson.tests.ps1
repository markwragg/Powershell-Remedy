$here = $PSScriptRoot
$tfn = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$sut = Get-ChildItem "$here\..\Remedy\*-$tfn" -Recurse
$sut | ForEach-Object { . $_.FullName }


Describe 'Get-RemedyPerson' -Tag Unit {
    
    Mock Get-RemedyApiConfig -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml }
    
    Mock Test-RemedyApiConfig -Verifiable { $True }
    
    Mock Invoke-RestMethod -Verifiable { Import-Clixml -Path $here\Mock-GetRemedyPerson-InvokeRestMethod.xml }
    

    '','Staff','Exact',@('Staff','Exact') | ForEach-Object {

        $Settings = @{Name = 'Clark Kent'}
        
        Switch ($_) {
            'Staff' { $Settings.Add('Staff',$True) }
            'Exact' { $Settings.Add('Exact',$True) }
        }

        $Option = @()
        If ($_) { $_ | ForEach-Object { $Option += ", -$_" } }

        Context "Valid user tests $Option" {

            It 'Should not Throw for a valid user' {
                {Get-RemedyPerson @Settings } | Should Not Throw
            }
    
            $SomeUser = Get-RemedyPerson @Settings

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

        Context "Valid user tests , -Full $Option" {

            $SomeUserFull = Get-RemedyPerson @Settings -Full

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

        Context "Invalid User" {
    
            Mock Invoke-RestMethod -Verifiable { }
        
            It 'Should not Throw for an invalid user' {
                {Get-RemedyPerson @Settings } | Should Not Throw
            }

            $NotAUser = Get-RemedyPerson @Settings

            It 'Should be Null or Empty for an invalid user' { 
                $NotAUser | Should BeNullOrEmpty 
            }
        }
    }    

    Context 'Failed API config test' {

        Mock Test-RemedyApiConfig -Verifiable { $False }
    
        It "Should Throw" {
            {Get-RemedyInterface} | Should Throw 'Remedy API Test failed. Ensure the config has been set correctly via Set-RemedyApiConfig.'
        }
    }

    Assert-VerifiableMocks
}