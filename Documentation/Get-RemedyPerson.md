# Get-RemedyPerson

## SYNOPSIS
Returns details of a person in Remedy.
This can be a customer or staff.

## SYNTAX

### ByName (Default)
```
Get-RemedyPerson [-Name] <String> [-Staff] [-Full] [-Exact] [-EncodedCredentials <String>] [-APIURL <String>]
 [<CommonParameters>]
```

### ByID
```
Get-RemedyPerson [-Login] <String> [-Staff] [-Full] [-Exact] [-EncodedCredentials <String>] [-APIURL <String>]
 [<CommonParameters>]
```

### ByEmail
```
Get-RemedyPerson [-Email] <String> [-Staff] [-Full] [-Exact] [-EncodedCredentials <String>] [-APIURL <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Use this cmdlet to return details of one or more customers or staff as stored in Remedy.

## EXAMPLES

### EXAMPLE 1
```
Get-RemedyPerson -Name Wragg -Staff
```

Returns details of the specified staff member.

## PARAMETERS

### -Name
Name of the person you want to return details of.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Login
Login ID of the person you want to return details of.

```yaml
Type: String
Parameter Sets: ByID
Aliases: ID, LoginID

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Email
Email of the person you want to return details of.

```yaml
Type: String
Parameter Sets: ByEmail
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Staff
Use to return only people where Support Staff = Yes.

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

### -Full
Return all available fields.

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
