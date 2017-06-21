$here = $PSScriptRoot
$tfn = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$sut = Get-ChildItem "$here\..\Remedy\*-$tfn" -Recurse
$sut | ForEach-Object { . $_.FullName }


Describe "Set-RemedyApiConfig" -Tag Unit {
    
    $ExportClixml = Get-Command Export-Clixml
    $TestPath = "SetRemedyApiConfig.xml"
    
    Mock Export-Clixml -Verifiable {
        $InputObject | & $ExportClixml -Path $TestPath
    }
    
    Mock Get-Credential -Verifiable { 
        $secpasswd = ConvertTo-SecureString 'testpassword' -AsPlainText -Force
        New-Object System.Management.Automation.PSCredential ('testuser', $secpasswd)
    }    
    
    It "Should not Throw" {
        {Set-RemedyApiConfig -APIURL 'https://mock.setconfig.com/arapi/midservername' -IncidentURL 'https://mock.setconfig.com/arsys/forms/helpdesk'} | Should Not Throw
    }
    It "Should create $TestPath" {
        $TestPath | Should Exist
    }
    
    $SetConfig = Import-Clixml $TestPath
    
    It "Should set an APIURL String" {
        $SetConfig.APIURL | Should BeOfType String
        $SetConfig.APIURL | Should Be 'https://mock.setconfig.com/arapi/midservername'
    }
    It "Should set an IncidentURL String" {
        $SetConfig.IncidentURL | Should BeOfType String
        $SetConfig.IncidentURL | Should Be 'https://mock.setconfig.com/arsys/forms/helpdesk'
    }
    It "Should set a Credentials SecureString" {
        $SetConfig.Credentials | Should BeOfType SecureString
        {$SetConfig.Credentials | ConvertFrom-SecureString} | Should Not Throw
    }

    Assert-VerifiableMocks
}


Describe "Get-RemedyApiConfig" -Tag Unit {
    
    $ImportClixml = Get-Command Import-Clixml
    
    Context 'Valid config' {    
    
        Mock Import-Clixml -Verifiable { 
            & $ImportClixml -Path SetRemedyApiConfig.xml
        }

        Mock Decrypt -Verifiable {
            "dGVzdHVzZXI6dGVzdHBhc3N3b3Jk"
        }
    
        It "Should not Throw" {
            {Get-RemedyApiConfig} | Should Not Throw
        }
    
        $GetConfig = Get-RemedyApiConfig
    
        It "Should return config data" {
            $GetConfig | Should Not BeNullOrEmpty
        }
        It "Should return an APIURL property" {
            $GetConfig.APIURL | Should BeOfType String
            $GetConfig.APIURL | Should Be 'https://mock.setconfig.com/arapi/midservername'
        }
    
        It "Should return an IncidentURL property" {
            $GetConfig.IncidentURL | Should BeOfType String
            $GetConfig.IncidentURL | Should Be 'https://mock.setconfig.com/arsys/forms/helpdesk'
        }
        It "Should return a Credentials property" {
            $GetConfig.Credentials | Should BeOfType String
            $GetConfig.Credentials | Should Be 'dGVzdHVzZXI6dGVzdHBhc3N3b3Jk'
        }
    }

    Context 'Invalid config' {    
    
        Mock Import-Clixml -Verifiable { Throw }
    
        It "Should Throw" {
            {Get-RemedyApiConfig} | Should Throw 'Remedy API config not set. Use Set-RemedyApiConfig first.'
        }
    }
    
    Assert-VerifiableMocks
}


Describe "Update-RemedyApiConfig" -Tag Unit {
    
    $ExportClixml = Get-Command Export-Clixml
    $TestPath = 'TestDrive:\UpdateRemedyApiConfig.xml'
    
    Mock Get-RemedyApiConfig -Verifiable { 
        Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml
    }
    
    Mock Export-Clixml -Verifiable {
        $InputObject | & $ExportClixml -Path $TestPath
    }
    
    Mock Get-Credential -Verifiable { 
        $secpasswd = ConvertTo-SecureString 'testpassword' -AsPlainText -Force
        New-Object System.Management.Automation.PSCredential ('testuser', $secpasswd)
    }    
    
    It "Should not Throw" {
        {Update-RemedyApiConfig} | Should Not Throw
    }
    It "Should create $TestPath" {
        $TestPath | Should Exist
    }
    
    $UpdateConfig = Import-Clixml $TestPath
    
    It "Should update an APIURL String" {
        $UpdateConfig.APIURL | Should BeOfType String
        $UpdateConfig.APIURL | Should Be 'https://mock.server.com/arapi/midservername'
    }
    It "Should update an IncidentURL String" {
        $UpdateConfig.IncidentURL | Should BeOfType String
        $UpdateConfig.IncidentURL | Should Be 'https://mock.server.com/arsys/forms/helpdesk'
    }
    It "Should update a Credentials SecureString" {
        $UpdateConfig.Credentials | Should BeOfType SecureString
        {$UpdateConfig.Credentials | ConvertFrom-SecureString} | Should Not Throw
    }

    Assert-VerifiableMocks
}


Describe "Test-RemedyApiConfig" -Tag Unit {
    
    Context "Successful API Response" {
        $ImportClixml = Get-Command Import-Clixml
    
        Mock Get-RemedyApiConfig -Verifiable { 
            Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml
        }
        Mock Invoke-WebRequest -Verifiable {
            & $ImportClixml -Path $here\Mock-TestRemedyApiConfig-InvokeWebRequest.xml   
        }

        Mock Update-RemedyApiConfig { }

        It "Should not Throw" {
            {Test-RemedyApiConfig} | Should Not Throw
        }
    
        $TestConfig = Test-RemedyApiConfig

        It "Should return True" {
            $TestConfig | Should Be True
        }
    
        Assert-VerifiableMocks
    }

    Context "Authentication Failure API Response" {
        
        $Script:UpdateConfigCount = 0

        Mock Get-RemedyApiConfig -Verifiable { 
            Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml
        }
        Mock Invoke-WebRequest -Verifiable { 
            $Result = If ($UpdateConfigCount -lt 3) { "$here\Mock-TestRemedyApiConfig-InvokeWebRequest-AuthFail.xml" } Else { "$here\Mock-TestRemedyApiConfig-InvokeWebRequest.xml" }
            Import-Clixml -Path $Result
        }
        
        Mock Update-RemedyApiConfig -Verifiable { $Script:UpdateConfigCount++ }
        
        It "Should return False (first test)" {
            Test-RemedyApiConfig | Should Be False
        }
    
        It "Should return True (fixed via Update-RemedyApiConfig)" {
            Test-RemedyApiConfig | Should Be True
        }
    
        Assert-MockCalled Update-RemedyApiConfig -Times 3 -Exactly
    }

    Context "Bad URL API Response" {
        
        Mock Get-RemedyApiConfig -Verifiable { 
            Import-Clixml -Path $here\Mock-GetRemedyApiConfig.xml
        }
        
        Mock Update-RemedyApiConfig { }

        Mock Invoke-WebRequest -Verifiable { Import-Clixml -Path "$here\Mock-TestRemedyApiConfig-InvokeWebRequest-BadResponse.xml" }
        
        It "Should return False for a bad URL" {
            Test-RemedyApiConfig | Should Be False
        }
    }

    Assert-VerifiableMocks
}