﻿Function Get-RemedyChange {
<#
    .SYNOPSIS
        Retrieves BMC Remedy Change details via the API by ID number or other specified criteria such as Assignee, Customer, Team.

    .DESCRIPTION
        This cmdlet queries the Remedy API for Changes as specified by ID number or by combining one or more of the filter parameters.
        Beware that the Remedy API will return a maximum of 5000 incidents in a single request. If you need to exceed this, make multiple
        requests (e.g by separating by date range) and then combine the results.

    .EXAMPLE
        Get-RemedyChange -ID 1234567

        Returns the specified change record.

    .EXAMPLE
        Get-RemedyChange -Status Open -Team Windows

        Returns all open changes for the specified team.

    .EXAMPLE
        Get-RemedyChange -Status Open -Customer 'Contoso'

        Returns all open changes for the specified customer.

    .EXAMPLE
        Get-RemedyChange -Status Open -Team Windows -Customer 'Fabrikam'

        Returns all open changes for the specified customer where assigned to the specified team.

    .EXAMPLE
        Get-RemedyChange -Team Windows -After 01/15/2019 -Before 02/15/2019

        Returns all changes for the specified team between the specified dates.
#>
    [cmdletbinding()]
    Param(
        # One or more Change ID numbers.
        [Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String[]]$ID = '',
        
        # Changes assigned to the specified team.
        [String]$Team,
        
        # Changes raised by the specified customer.
        [String]$Customer,
        
        # Changes raised for a specific configuration item, e.g a server or other device.
        [Alias('CI')]
        [String]$ConfigurationItem,
        
        # Changes assigned to the specified individual.
        [String[]]$Assignee,

        # Changes submitted by the specified individual.
        [String[]]$Submitter,

        # Changes filtered by specified status. You can also specify 'AllOpen' or 'AllClosed': AllOpen = ('Draft','Request For Authorization','Request For Change','Planning In Progress','Scheduled For Review','Scheduled For Approval','Scheduled','Implementation In Progress','Pending','Rejected'); AllClosed = ('Completed','Closed','Cancelled')
        [ValidateSet('AllOpen','AllClosed','Draft','Request For Authorization','Request For Change','Planning In Progress','Scheduled For Review','Scheduled For Approval','Scheduled','Implementation In Progress','Pending','Rejected','Completed','Closed','Cancelled')] 
        [String]$Status,
        
        # Changes filtered by one or more specified approval status: Pending, Approved or Rejected.
        [ValidateSet('Pending','Approved','Rejected','')]
        [String[]]$ApprovalStatus,

        # Include Changes of one or more specific types: Normal, Standard, Expedited.
        [ValidateSet('Normal','Standard','Expedited','Emergency','Latent','No Impact','')]
        [String[]]$Type,

        # Exclude Changes of one or more specific types: Normal, Standard, Expedited.
        [ValidateSet('Normal','Standard','Expedited','Emergency','Latent','No Impact','')]
        [String[]]$ExcludeType,

        # Include Changes of one or more specific priorities: Low, Medium, High, Critical.
        [ValidateSet('Low','Medium','High','Critical','')]
        [String[]]$Priority = '',
        
        # Changes with a 'scheduled start date' that is after this date. Use US date format: mm/dd/yyyy
        [DateTime]$After,
        
        # Changes with a 'scheduled start date' that is before this date. Use US date format: mm/dd/yyyy
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
        'AllOpen'   { $Filter = 'Draft','Request For Authorization','Request For Change','Planning In Progress','Scheduled For Review','Scheduled For Approval','Scheduled','Implementation In Progress','Pending','Rejected' }
        'AllClosed' { $Filter = 'Completed','Closed','Cancelled' }
        Default     { $Filter = $Status }  
    }
    
    If ($Filter) { $StatusString = ($Filter | ForEach-Object { "('Change Request Status'=""$_"")" }) -join 'OR' }
    
    If ($ApprovalStatus) { $ApprovalStatusString = ($ApprovalStatus | ForEach-Object { "('Approval Status'=""$_"")" }) -join 'OR' }

    If ($Type)           { $TypeString = ($Type | ForEach-Object { "('Change Timing'=""$_"")" }) -join 'OR' }
    If ($ExcludeType)    { $ExcludeTypeString = ($ExcludeType | ForEach-Object { "('Change Timing'!=""$_"")" }) -join 'AND' }
    
    If ($Priority) { $PriorityString = ($Priority | ForEach-Object { "('Priority'=""$_"")" }) -join 'OR' }
     
    ForEach ($IDNum in $ID) {
        Write-Verbose "$IDNum"
        
        $Filter = @()
        
        If ($Exact) { $Op = '='; $Wc = '' } Else { $Op = 'LIKE'; $Wc = '%25' }
        If ($Exact -or $IDNum -match '^CRQ\d{12}') { $IDOp = '='; $IDWc = '' } Else { $IDOp = 'LIKE'; $IDWc = '%25' }
        
        If ($IDNum)    { $Filter += "'Infrastructure Change ID'$IDOp""$IDWc$IDNum""" }
        If ($Team)     { $Filter += "'ASGRP'=""$Team""" }
        If ($Customer) { $Filter += "'Customer Company'$Op""$Wc$Customer$Wc""" }
        If ($ConfigurationItem) { $Filter += "'zTmp_CIName'$Op""$Wc$ConfigurationItem$Wc""" }
        
        If ($Assignee -is [Array]) { 
            $AssigneeString = ($Assignee | ForEach-Object { "('ASCHG'$Op""$Wc$_$Wc"")" }) -join 'OR'
            $Filter += "($AssigneeString)"
        } ElseIf ($Assignee -is [String]) {
             $Filter += "'ASCHG'$Op""$Wc$Assignee$Wc""" 
        }
        
        If ($Submitter -is [Array]) { 
            $SubmitterString = ($Submitter | ForEach-Object { "('Submitter'$Op""$Wc$_$Wc"")" }) -join 'OR'
            $Filter += "($SubmitterString)"
        } ElseIf ($Submitter -is [String]) {
             $Filter += "'Submitter'$Op""$Wc$Submitter$Wc""" 
        }
        
        If ($ApprovalStatus){ $Filter += "($ApprovalStatusString)" }
        
        If ($Type)          { $Filter += "($TypeString)" }
        If ($ExcludeType)   { $Filter += "($ExcludeTypeString)" }
        
        If ($Priority)      { $Filter += "($PriorityString)" }
        
        If ($After)  { $Filter += "'Scheduled Start Date'>""$($After.ToString("yyyy-MM-dd"))""" }
        If ($Before) { $Filter += "'Scheduled Start Date'<""$($Before.ToString("yyyy-MM-dd"))""" }

        If ($StatusString) { $Filter += "($StatusString)" }
        $FilterString = $Filter -Join 'AND'

        $Headers = @{
            Authorization = "Basic $EncodedCredentials"
        }

        If (-not $FilterString) { Throw 'Please provide at least one search criteria. Enter Help Get-RemedyChange for further guidance.' }

        $URL = "$APIURL/CHG:Infrastructure Change/$FilterString"
    
    
        Try {
            $Result = Invoke-RestMethod -URI $URL -Headers $Headers -ErrorAction Stop

            $Changes = @()
            $Result.PSObject.Properties | ForEach-Object { $Changes += $_.Value }
            
            #Convert all date containing fields to PS datetime
            ForEach ($Change in $Changes) { 
                
                $Change.PSObject.Properties.Name -like '* Date*' | ForEach-Object {
                        
                    If ($Change.$_ -match 'UTC'){
                        $Change.$_ = [datetime]::ParseExact(($Change.$_ -Replace 'UTC ',''), 'ddd MMM dd HH:mm:ss yyyy', $null)
                    }
                }
            }
                                
            #Could replace this with a format.ps1.xml
            If (-not $Full){
                $Changes = $Changes |  Select-Object 'Infrastructure Change ID','Priority',@{N='Customer';E={$_.'Customer Company'}},
                                                     'Description',@{N='Status';E={$_.'Change Request Status'}},@{N='Assigned Group';E={$_.ASGRP}},@{N='Assignee';E={$_.ASCHG}},@{N='CI';E={$_.zTmp_CIName}},
                                                     'Scheduled Start Date','Scheduled End Date','Last Modified By','Last Modified Date'
            }
        } Catch {
            
            Write-Error "Error: $_"
        }

        If ($null -ne $Changes.'Infrastructure Change ID') {
            $Changes.psobject.TypeNames.Insert(0, 'RemedyChange')
            $Changes
        } Else {
            Write-Verbose 'No change data returned'
        }
    }
}
