Function Set-RemedyApiConfig {
<#
.SYNOPSIS
    Set credentails and URL for use with the Remedy API. This stores the credentials as an encrypted string.
.EXAMPLE
    Set-RemedyApiConfig -APIURL https://myserver.com/api
.EXAMPLE
    Set-RemedyApiConfig -APIURL https://myserver.com/api -Path C:\Temp\Creds.xml
#>
    [cmdletbinding(SupportsShouldProcess = $true)]
    Param(
        [pscredential]$Credentials = (Get-Credential -UserName ($env:USERNAME).ToLower() -Message "Enter Remedy login details"),
        
        [Parameter(Mandatory=$true)]
        [string]$APIURL,

        [string]$IncidentURL,
        [string]$Path = "$env:USERPROFILE\$env:USERNAME-RemedyApi.xml",
        [switch]$Force   
    )

    $User = $Credentials.GetNetworkCredential().username
    $Pass = $Credentials.GetNetworkCredential().password
    $EncodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$user`:$pass"))

    Function Encrypt ([string]$string) {
        If($String -notlike '')
        {
            ConvertTo-SecureString -String $string -AsPlainText -Force
        }
    }

    $Properties = @{
        Credentials = Encrypt $EncodedCreds
        APIURL = $APIURL
        IncidentURL = $IncidentURL
    }

    $Config = New-Object -TypeName PSObject -Property $Properties 
    $Config | Export-Clixml -Path $Path -Force
}
