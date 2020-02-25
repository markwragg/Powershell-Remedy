# Update-RemedyApiConfig

## SYNOPSIS
Set credentails and URL for use with the Remedy API.
This stores the credentials as an encrypted string.

## SYNTAX

```
Update-RemedyApiConfig [[-Credentials] <PSCredential>] [[-APIURL] <String>] [[-IncidentURL] <String>]
 [[-Path] <String>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Use this cmdlet to update specific settings of your Remedy API config file.

## EXAMPLES

### EXAMPLE 1
```
Set-RemedyApiConfig -APIURL https://myserver.com/api
```

Updates the API URL in your config file to the specified URL.

### EXAMPLE 2
```
Set-RemedyApiConfig -APIURL https://myserver.com/api -Path C:\Temp\Creds.xml
```

Updates the API URL in the specified path to the specified URL.

## PARAMETERS

### -Credentials
Remedy credentials

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Get-Credential -UserName $env:USERNAME -Message "Enter Remedy login details")
Accept pipeline input: False
Accept wildcard characters: False
```

### -APIURL
Remedy API URL

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Get-RemedyApiConfig).APIURL
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncidentURL
Remedy Incident URL

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: (Get-RemedyApiConfig).IncidentURL
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to store the config

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: "$env:USERPROFILE\$env:USERNAME-RemedyApi.xml"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Use to force overwrite of existing config

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
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
