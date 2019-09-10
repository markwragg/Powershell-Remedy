# Get-RemedyKnownError

## SYNOPSIS
Retrieves BMC Remedy Known Error details via the API by ID number or other specified criteria such as Assignee, Customer, Team.

## SYNTAX

```
Get-RemedyKnownError [[-ID] <String[]>] [-Team <String>] [-Customer <String>] [-ConfigurationItem <String>]
 [-Assignee <String[]>] [-Submitter <String[]>] [-Status <String>] [-Type <String[]>] [-ExcludeType <String[]>]
 [-Priority <String[]>] [-After <DateTime>] [-Before <DateTime>] [-Full] [-Exact]
 [-EncodedCredentials <String>] [-APIURL <String>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet queries the Remedy API for Known Errors as specified by ID number or by combining one or more of the filter parameters.
Beware that the Remedy API will return a maximum of 5000 incidents in a single request.
If you need to exceed this, make multiple
requests (e.g by separating by date range) and then combine the results.

## EXAMPLES

### EXAMPLE 1
```
Get-RemedyKnownError -ID 1234567
```

Returns the specified Known Error.

### EXAMPLE 2
```
Get-RemedyKnownError -Status Open -Team Windows
```

Returns all open Known Error records for the specified team.

### EXAMPLE 3
```
Get-RemedyKnownError -Status Open -Customer 'Contoso'
```

Returns all open Known Error records for the specified customer.

### EXAMPLE 4
```
Get-RemedyKnownError -Status Open -Team Windows -Customer 'Fabrikam'
```

Returns all open Known Error records for the specified customer where assigned to the specified team.

### EXAMPLE 5
```
Get-RemedyKnownError -Team Windows -After 01/15/2019 -Before 02/15/2019
```

Returns all open Known Error records for the specified team between the specified dates.

## PARAMETERS

### -ID
One or more Known Error ID numbers.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Team
Known Errors assigned to the specified team.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Customer
Known Errors raised by the specified customer.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigurationItem
Known Errors raised for a specific configuration item, e.g a server or other device.

```yaml
Type: String
Parameter Sets: (All)
Aliases: CI

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Assignee
Known Errors assigned to the specified individual.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Submitter
Known Errors submitted by the specified individual.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Status
Known Errors filtered by specified status.
You can also specific 'AllOpen' or 'AllClosed': AllOpen = ('Assigned','Scheduled For Correction','Assigned To Vendor','No Action Planned','Corrected'); AllClosed = ('Closed','Cancelled')

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Include Known Errors of one or more specific types: Normal, Standard, Expedited.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeType
Exclude Known Errors of one or more specific types: Normal, Standard, Expedited.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Priority
Include Known Errors of one or more specific priorities: Low, Medium, High, Critical.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -After
Known Errors with a 'submit date' that is after this date.
Use US date format: mm/dd/yyyy

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Before
Known Errors with a 'submit date' that is before this date.
Use US date format: mm/dd/yyyy

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Full
Return all available data fields from Remedy.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exact
Match the string exactly.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -EncodedCredentials
An encoded string representing your Remedy Credentials as generated by the Set-RemedyApiConfig cmdlet.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: (Get-RemedyApiConfig).Credentials
Accept pipeline input: False
Accept wildcard characters: False
```

### -APIURL
The Remedy API URL.
E.g: https://\<localhost\>:\<port\>/api

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: (Get-RemedyApiConfig).APIURL
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
