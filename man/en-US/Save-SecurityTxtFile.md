---
external help file: SecurityTxtToolkit-help.xml
Module Name: SecurityTxtToolkit
online version: https://github.com/rhymeswithmogul/SecurityTxtToolkit/blob/main/man/en-US/Save-SecurityTxtFile.md
schema: 2.0.0
---

# Save-SecurityTxtFile

## SYNOPSIS
Downloads a "security.txt" file from a remote domain.

## SYNTAX

```
Save-SecurityTxtFile [-Domain] <String> [-OutFile] <String> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will find a website's "security.txt" file and download it.  It will save the file to your disk, without performing any testing or evaluation.

For compatibility and testing purposes, this cmdlet will attempt to fetch it over unencrypted HTTP, but will emit a warning because this is a very bad idea.

## EXAMPLES

### Example 1
```powershell
PS C:\> Save-SecurityTxtFile -Domain google.com -OutFile "GoogleSecurity.txt"
```

Downloads Google's "security.txt" file and saves it to GoogleSecurity.txt.

### Example 2
```powershell
PS C:\> Save-SecurityTxtFile github.com 'Documents\Hacking\GitHub\security.txt'
```

Saves GitHub's "security.txt" file to the specified folder and path.  Note that you must specify a file name.

### Example 3
```powershell
PS C:\> Save-SecurityTxtFile bing.com 'security.txt' -Force
```

Downloads Bing's "security.txt" file to security.txt, overwriting whatever is already there.

## PARAMETERS

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

### -Domain
The domain name to search for a "security.txt" file.  It will check in the recommended /.well-known folder, before falling back to legacy behavior and looking in the root folder.

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

### -Force
Overwrite an existing file without confirmation.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutFile
The file name (and optionally, path) to where the contents will be saved.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path, FileName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
This cmdlet accepts one or more domain names from the pipeline.

## OUTPUTS

### System.Void
This cmdlet generates no output to the terminal or pipeline.

## NOTES

## RELATED LINKS

[Get-SecurityTxtFile]()
[Test-SecurityTxtFile]()
[about_SecurityTxtToolkit]()
