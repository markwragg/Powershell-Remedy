﻿Function Get-RemedyTicket {
<#
.SYNOPSIS
    Retrieves BMC Remedy Ticket details via the API by ID number or other specified criteria such as Assignee, Customer, Team.

.DESCRIPTION
    This cmdlet queries the Remedy API for Incidents as specified by ID number or by combining one or more of the filter parameters.
    Beware that the Remedy API will return a maximum of 5000 incidents in a single request. If you need to exceed this, make multiple
    requests (e.g by separating by date range) and then combine the results.

.EXAMPLE
    Get-RemedyTicket -ID 1234567

    Returns the specified Ticket.

.EXAMPLE
    Get-RemedyTicket -Status Open -Team Windows

    Returns all open tickets for the specified team.

.EXAMPLE
    Get-RemedyTicket -Status Open -Customer 'Contoso'

    Returns all open tickets for the specified customer.

.EXAMPLE
    Get-RemedyTicket -Status Open -Team Windows -Customer 'Fabrikam'

    Returns all open tickets for the specified customer assigned to the specified team.

.EXAMPLE
    Get-RemedyTicket -Team Windows -After 01/15/2017 -Before 02/15/2017

    Returns all tickets for the specified team between the specified dates.
#>
    [cmdletbinding()]
    Param(
        # One or more Incident ID numbers.
        [Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String[]]$ID = '',
        
        # Incidents assigned to the specified team.
        [String]$Team,
        
        # Incidents raised by the specified customer.
        [String]$Customer,
        
        # Incidents raised for a specific configuration item, e.g a server or other device.
        [Alias('CI')]
        [String]$ConfigurationItem,
        
        # Incidents assigned to the specified individual.
        [String[]]$Assignee,

        # Incidents submitted by the specified individual.
        [String[]]$Submitter,

        # Incidents filtered by specified status. You can also specific 'AllOpen' or 'AllClosed': AllOpen = ('New','Assigned','In Progress','Pending'); AllClosed = ('Closed','Resolved')
        [ValidateSet('AllOpen','AllClosed','New','Assigned','In Progress','Pending','Closed','Resolved')] 
        [String]$Status,
        
        # Incidents from a specific source.
        [ValidateSet('Email','Automation','Phone','Self Service (Portal)','Event Management','Chat','Instant Message','E-Bonding','')]
        [String]$Source = '',
        
        # Incidents of a specific type.
        [ValidateSet('User Service Restoration','User Service Request','Service Improvement','Infrastructure Event','')]
        [String]$Type = '',

        # Exclude Incidents from a specific source.
        [ValidateSet('Email','Automation','Phone','Self Service (Portal)','Event Management','Chat','Instant Message','E-Bonding','')]
        [String[]]$ExcludeSource = '',
        
        # Exclude Incidents of a specific type.
        [ValidateSet('User Service Restoration','User Service Request','Service Improvement','Infrastructure Event','')]
        [String[]]$ExcludeType = '',

        # Include Incidents of one or more specific priorities: Low, Medium, High, Critical.
        [ValidateSet('Low','Medium','High','Critical','')]
        [String[]]$Priority = '',
        
        # Incidents with a 'submit date' that is after this date. Use US date format: mm/dd/yyyy
        [DateTime]$After,
        
        # Incidents with a 'submit date' that is before this date. Use US date format: mm/dd/yyyy
        [DateTime]$Before,

        # Return all available data fields from Remedy.
        [Switch]$Full,

        # Match the string exactly.
        [Switch]$Exact,

        # An encoded string representing your Remedy Credentials as generated by the Set-RemedyApiConfig cmdlet.
        [String]$EncodedCredentials = (Get-RemedyApiConfig).Credentials,

        # The Remedy API URL. E.g: https://<localhost>:<port>/api
        [String]$APIURL = (Get-RemedyApiConfig).APIURL
    )
    
    If (-not $EncodedCredentials -or -not $APIURL) { Throw 'Remedy API Config not set. Set-RemedyApiConfig first.' }
    
    If (-not (Test-RemedyApiConfig)) { Throw 'Remedy API Test failed. Ensure the config has been set correctly via Set-RemedyApiConfig.' }

    Switch ($Status) {
        'AllOpen'   { $Filter = 'New','Assigned','In Progress','Pending' }
        'AllClosed' { $Filter = 'Closed','Resolved' }
        Default     { $Filter = $Status }  
    }
    
    If ($Filter) { $StatusString = ($Filter | ForEach-Object { "('Status'=""$_"")" }) -join 'OR' }
    
    If ($ExcludeSource) { $ExcludeSourceString = ($ExcludeSource | ForEach-Object { "('Reported Source'!=""$_"")" }) -join 'AND' }
    
    If ($ExcludeType) {
        $ExcludeTypeString = ($ExcludeType | ForEach-Object { 
            If ($_ -eq 'Service Improvement'){ $_ = 'Infrastructure Restoration' }
            "('Service Type'!=""$_"")" 
         }) -join 'AND'
    }

    If ($Priority) { $PriorityString = ($Priority | ForEach-Object { "('Priority'=""$_"")" }) -join 'OR' }
    
     
    ForEach ($IDNum in $ID) {
        Write-Verbose "$IDNum"
        
        $Filter = @()
        
        If ($Exact) { $Op = '='; $Wc = '' } Else { $Op = 'LIKE'; $Wc = '%25' }
        If ($Exact -or $IDNum -match '^INC\d{12}') { $IDOp = '='; $IDWc = '' } Else { $IDOp = 'LIKE'; $IDWc = '%25' }
            
        If ($IDNum)    { $Filter += "'Incident Number'$IDOp""$IDWc$IDNum""" }
        If ($Team)     { $Filter += "'Assigned Group'=""$Team""" }
        If ($Customer) { $Filter += "'Organization'$Op""$Wc$Customer$Wc""" }
        If ($ConfigurationItem) { $Filter += "'CI'$Op""$Wc$ConfigurationItem$Wc""" }
        
        If ($Assignee -is [Array]) { 
            $AssigneeString = ($Assignee | ForEach-Object { "('Assignee'$Op""$Wc$_$Wc"")" }) -join 'OR'
            $Filter += "($AssigneeString)"
        } ElseIf ($Assignee -is [String]) {
             $Filter += "'Assignee'$Op""$Wc$Assignee$Wc""" 
        }
        
        If ($Submitter -is [Array]) { 
            $SubmitterString = ($Submitter | ForEach-Object { "('Submitter'$Op""$Wc$_$Wc"")" }) -join 'OR'
            $Filter += "($SubmitterString)"
        } ElseIf ($Submitter -is [String]) {
             $Filter += "'Submitter'$Op""$Wc$Submitter$Wc""" 
        }
        
        If ($Source)        { $Filter += "'Reported Source'=""$Source""" }
        If ($Type)          { If ($Type -eq 'Service Improvement'){ $Filter += "'Service Type'=""Infrastructure Restoration""" } Else { $Filter += "'Service Type'=""$Type""" } }
        
        If ($ExcludeSource) { $Filter += "($ExcludeSourceString)" }
        If ($ExcludeType)   { $Filter += "($ExcludeTypeString)" }
        If ($Priority)      { $Filter += "($PriorityString)" }
        
        If ($After)  { $Filter += "'Submit Date'>""$($After.ToString("yyyy-MM-dd"))""" }
        If ($Before) { $Filter += "'Submit Date'<""$($Before.ToString("yyyy-MM-dd"))""" }

        If ($StatusString) { $Filter += "($StatusString)" }
        $FilterString = $Filter -Join 'AND'

        $Headers = @{
            Authorization = "Basic $EncodedCredentials"
        }

        If (-not $FilterString) { Throw 'Please provide at least one search criteria. Enter Help Get-RemedyTicket for further guidance.' }

        $URL = "$APIURL/HPD:Help%20Desk/$FilterString"
    
    
        Try {
            $Result = Invoke-RestMethod -URI $URL -Headers $Headers -ErrorAction Stop

            $Tickets = @()
            $Result.PSObject.Properties | ForEach-Object { $Tickets += $_.Value }
            
            #Convert all date containing fields to PS datetime
            ForEach ($Ticket in $Tickets) { 
                
                $Ticket.PSObject.Properties.Name -like '* Date*' | ForEach-Object {
                        
                    If ($Ticket.$_ -match 'UTC'){
                        $Ticket.$_ = [datetime]::ParseExact(($Ticket.$_ -Replace 'UTC ',''), 'ddd MMM dd HH:mm:ss yyyy', $null)
                    }
                }
            }
                                
            #Could replace this with a format.ps1.xml
            If (-not $Full){
                $Tickets = $Tickets |  Select-Object 'Incident Number','Priority','Organization',
                                                        'Description','Status','Assigned Group','Assignee','CI',
                                                        'Submit Date','Last Modified Date','Last Modified By'
            }
            
        } Catch {
            Write-Error "Error: $_"
        }

        If ($null -ne $Tickets.'Incident Number') {
            $Tickets.psobject.TypeNames.Insert(0, 'RemedyIncident')
            $Tickets
        } Else {
            Write-Verbose 'No ticket data returned'
        }
    }
}
