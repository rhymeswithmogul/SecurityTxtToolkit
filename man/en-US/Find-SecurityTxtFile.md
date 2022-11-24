---
external help file: SecurityTxtToolkit-help.xml
Module Name: SecurityTxtToolkit
online version: https://github.com/rhymeswithmogul/SecurityTxtToolkit/blob/main/man/en-US/Find-SecurityTxtFile.md
schema: 2.0.0
---

# Find-SecurityTxtFile

## SYNOPSIS
Locates a website's "security.txt" file.

## SYNTAX

```
Find-SecurityTxtFile [-Domain] <String> [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will check and see where a website's "security.txt" file is.  The RFC calls for it to be in the /.well-known folder, but some draft implementations may have the file in the root folder instead.

## EXAMPLES

### Example 1
```powershell
PS C:\> Find-SecurityTxtFile github.com
https://github.com/.well-known/security.txt
```

Locates GitHub's "security.txt" file.  In their case, they have it in the correct location.

## PARAMETERS

### -Domain
The domain to check for a "security.txt" file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: DomainName, Host, HostName, Name, Uri, Url

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
One or more domains.

## OUTPUTS

### System.Uri
The URI of the file.

## NOTES
This cmdlet will attempt to fetch the "security.txt" file via unsecured HTTP, in violation of the specification.  This will only be for testing purposes, and it will print a very visible warning if the file is not available over HTTPS.

## RELATED LINKS
[Get-SecurityTxtFile]()
[Save-SecurityTxtFile]()
[Test-SecurityTxtFile]()
[about_SecurityTxtToolkit]()