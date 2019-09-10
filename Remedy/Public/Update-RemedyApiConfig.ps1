Function Update-RemedyApiConfig {
<#
.SYNOPSIS
    Set credentails and URL for use with the Remedy API. This stores the credentials as an encrypted string.

.DESCRIPTION
    Use this cmdlet to update specific settings of your Remedy API config file.

.EXAMPLE
    Set-RemedyApiConfig -APIURL https://myserver.com/api

    Updates the API URL in your config file to the specified URL.

.EXAMPLE
    Set-RemedyApiConfig -APIURL https://myserver.com/api -Path C:\Temp\Creds.xml

    Updates the API URL in the specified path to the specified URL.
#>
    [cmdletbinding(SupportsShouldProcess = $true)]
    Param(
        # Remedy credentials
        [pscredential]$Credentials = (Get-Credential -UserName $env:USERNAME -Message "Enter Remedy login details"),
        
        # Remedy API URL
        [string]$APIURL = (Get-RemedyApiConfig).APIURL,

        # Remedy Incident URL
        [string]$IncidentURL = (Get-RemedyApiConfig).IncidentURL,
        
        # Path to store the config
        [string]$Path = "$env:USERPROFILE\$env:USERNAME-RemedyApi.xml",
        
        # Use to force overwrite of existing config
        [switch]$Force   
    )

    If (-not $APIURL) {
        Set-RemedyApiConfig -Credentials $Credentials
        Break
    }

    $User = ($Credentials.GetNetworkCredential().username).ToLower()
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
    $Config | Export-Clixml -Path $Path -Force:$Force
}
