﻿Function Get-RemedyTeam {
<#
.SYNOPSIS
    Returns the members of a Remedy Support Group / Team.

.DESCRIPTION
    Use this cmdlet to find details of one or more teams in Remedy.

.EXAMPLE
    Get-RemedyTeam -Name Windows

    Returns the details of the specified team.
#>
    [cmdletbinding()]
    Param(
        # Name of the team you want to return the members of.
        [String]$Name,

        # Return all available fields.
        [Switch]$Full,

        # An encoded string representing your Remedy Credentials as generated by the Set-RemedyApiConfig cmdlet.
        [String]$EncodedCredentials = (Get-RemedyApiConfig).Credentials,
        
        # The Remedy API URL. E.g: https://<localhost>:<port>/api
        [String]$APIURL = (Get-RemedyApiConfig).APIURL
    )

    If (-not (Test-RemedyApiConfig)) { Throw 'Remedy API Test failed. Ensure the config has been set correctly via Set-RemedyApiConfig.' }

    $Headers = @{
        Authorization = "Basic $EncodedCredentials"
    }

    $TeamName = (Get-RemedyInterface "CTM:Support Group/'Support Group Name'=""$Name""").'Support Group ID'

    If (-not $TeamName) {
        Throw "Team $Name not found"
    }

    $URL = "$APIURL/CTM:Support Group Association/'Support Group ID'=""$TeamName"""

    Try {
        $Result = Invoke-RestMethod -URI $URL -Headers $Headers -ErrorAction Stop
        
        $Members = @()
        $Result.PSObject.Properties | ForEach-Object { $Members += $_.Value }
    
        If (-not $Full){
            $Members = $Members | Where-Object { $_.'Assignment Availability' -eq 'Yes' } | Select-Object 'Full Name','Login ID'
        }
                
    } Catch {
        Write-Error $_
    }

    Return $Members
}
