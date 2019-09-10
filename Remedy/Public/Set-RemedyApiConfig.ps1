Function Encrypt ([string]$string) {
    If($String -notlike '')
    {
        ConvertTo-SecureString -String $string -AsPlainText -Force
    }
}

Function Set-RemedyApiConfig {
<#
.SYNOPSIS
    Set credentails and URL for use with the Remedy API. This stores the credentials as an encrypted string.

.DESCRIPTION
    Use this cmdlet to set your credentials for Remedy which in an XML file for automatic use by the other cmdlets.

.EXAMPLE
    Set-RemedyApiConfig -APIURL https://myserver.com/api

    Set the specified URL as your Remedy endpoint.

.EXAMPLE
    Set-RemedyApiConfig -APIURL https://myserver.com/api -Path C:\Temp\Creds.xml

    Set the specified URL as your remedy endpoint and store credentials in the specified path.
#>
    [cmdletbinding(SupportsShouldProcess = $true)]
    Param(
        # Remedy credentials
        [pscredential]$Credentials = (Get-Credential -UserName ($env:USERNAME).ToLower() -Message "Enter Remedy login details"),
        
        # URL of the API
        [Parameter(Mandatory=$true)]
        [string]$APIURL,

        # URL for Incidents
        [string]$IncidentURL,

        # Path to store the credentials/settings.
        [string]$Path = "$env:USERPROFILE\$env:USERNAME-RemedyApi.xml",

        # Use -Force to force replacement of any existing config.
        [switch]$Force   
    )

    $User = $Credentials.GetNetworkCredential().username
    $Pass = $Credentials.GetNetworkCredential().password
    $EncodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$user`:$pass"))

    $Properties = @{
        Credentials = Encrypt $EncodedCreds
        APIURL = $APIURL
        IncidentURL = $IncidentURL
    }

    $Config = New-Object -TypeName PSObject -Property $Properties 
    $Config | Export-Clixml -Path $Path -Force:$Force
}
