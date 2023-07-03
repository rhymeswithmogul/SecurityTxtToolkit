#Requires -Version 5.1
New-Variable -Scope 'Script' -Name 'UserAgent' -Option 'Constant' -Value 'SecurityTxtToolkit/1.4.0 (https://github.com/rhymeswithmogul/SecurityTxtToolkit)'

Function Find-SecurityTxtFile {
	[Alias('fsectxt', 'Search-SecurityTxtFile')]
	[OutputType([Uri])]
	Param(
		[Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
		[Alias('DomainName','Host','HostName','Name','Uri','Url')]
		[ValidateNotNullOrEmpty()]
		[String] $Domain
	)

	# Below are the parameters we will be using for Invoke-WebRequest.
	$Params = @{
		'Method'          = 'HEAD'
		'UseBasicParsing' = $true
		'UserAgent'       = $script:UserAgent
	}

	$WebRequest = $null
	ForEach ($Uri in @(
		"https://$Domain/.well-known/security.txt",
		"https://$Domain/security.txt",
		"http://$Domain/.well-known/security.txt",
		"http://$Domain/security.txt")
	) {
		Write-Verbose "Checking $Uri"
		$WebRequest = Invoke-WebRequest @Params -Uri $Uri -ErrorAction SilentlyContinue
		If ($null -ne $WebRequest -and $WebRequest.StatusCode -eq 200) {
			Break
		}
	}
	If (-Not $WebRequest -Or $WebRequest.StatusCode -NotLike '2*') {
		Write-Error -Message "No `"security.txt`" file was found at $Domain."
		Return $null
	}

	If ($WebRequest.BaseResponse.RequestMessage.RequestUri.Scheme -eq 'http') {
		Write-Warning -Message "The `"security.txt`" file for $Domain could not be downloaded via HTTPS."
	}

	If ($WebRequest.BaseResponse.RequestMessage.RequestUri.AbsolutePath -eq 'security.txt') {
		Write-Warning -Message "The `"security.txt`" file for $Domain was found in the root folder, but not in the .well-known folder."
	}

	# Check to make sure this file was served via HTTP 1.0 or higher.
	If ($WebRequest.RawContent.Substring(0,6) -Cne 'HTTP/1') {
		Write-Warning -Message "The `"security.txt`" file for $Domain was not downloaded by HTTP 1.0 or newer."
	}

	# Check to make sure that this file has the correct content type.
	If ($WebRequest.Headers.'Content-Type' -NotMatch 'text\/plain(;\s*charset=[Uu][Tt][Ff]-8)?') {
		Write-Warning -Message "The `"security.txt`" file for $Domain was served with the incorrect MIME type."
	}

	Return $Uri
}

Function Get-SecurityTxtFile {
	[Alias('gsectxt')]
	[OutputType([String])]
	Param(
		[Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
		[Alias('DomainName','Host','HostName','Name','Uri','Url')]
		[ValidateNotNullOrEmpty()]
		[String] $Domain
	)

	# Below are the parameters we will be using for Invoke-WebRequest.
	$Params = @{
		'Method'          = 'GET'
		'Uri'             = (Find-SecurityTxtFile -Domain $Domain)
		'UseBasicParsing' = $true
		'UserAgent'       = $script:UserAgent
	}

	Write-Verbose "Downloading $($Params.Uri)"
	$WebRequest = Invoke-WebRequest @Params -ErrorAction SilentlyContinue

	If ($null -ne $WebRequest -and $WebRequest.StatusCode -eq 200) {
		Return $WebRequest.Content
	}
	Write-Error "The `"security.txt`" file at $($Params.Uri) could not be downloaded."
	Return $null
}

Function Save-SecurityTxtFile {
	[Alias('ssectxt')]
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
	[OutputType([Void])]
	Param(
		[Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
		[Alias('DomainName','Host','HostName','Name','Uri','Url')]
		[ValidateNotNullOrEmpty()]
		[String] $Domain,

		[Parameter(Mandatory, Position=1, ValueFromPipelineByPropertyName)]
		[Alias('Path', 'FileName')]
		[ValidateNotNullOrEmpty()]
		[String] $OutFile,

		[Switch] $Force
	)

	$SecurityTxtFile = Get-SecurityTxtFile -Domain $Domain -ErrorAction Stop

	#region Does this file already exist?
	If ((Test-Path -PathType Leaf -Path $OutFile)) {
		If ($Force) {
			Write-Verbose "The file $OutFile already exists and will be overwritten!"
		}
		$Operation = 'Overwrite file'
	}
	Else {
		$Operation = 'Create file'
	}
	#endregion

	If ($PSCmdlet.ShouldProcess($OutFile, $Operation))
	{
		$Arguments = @{
			'Force'    = $Force
			'ItemType' = 'File'
			'Path'     = $OutFile
			'Value'    = $SecurityTxtFile
			'Confirm'  = $ConfirmPreference
			'Debug'    = $DebugPreference
			'Verbose'  = $VerbosePreferece
			'WhatIf'   = $WhatIfPreference
		}
		New-Item @Arguments -ErrorAction Stop
	}
	Return
}

Function Test-SecurityTxtFile {
	[Alias('tsectxt')]
	[CmdletBinding(DefaultParameterSetName='Online')]
	[OutputType([PSCustomObject])]
	Param(
		[Parameter(ParameterSetName='Online', Position=0, ValueFromPipelineByPropertyName)]
		[Alias('DomainName','Host','HostName','Name','Uri','Url')]
		[ValidateNotNullOrEmpty()]
		[String] $Domain,

		[Parameter(ParameterSetName='Offline', Mandatory, Position=0, ValueFromPipeline)]
		[AllowNull()]
		[String[]] $InputObject,

		[Parameter(ParameterSetName='Offline', Position=1)]
		[Uri] $TestCanonicalUri
	)

	$Return = [PSCustomObject]@{
		'For' = 'stdin'
		'IsValid' = $true
		'IsCanonical' = $false
		'Acknowledgements' = @()
		'Canonical' = @()
		'Contact' = @()
		'Encryption' = @()
		'Expires' = $null
		'Hiring' = @()
		'Policy' = @()
		'PreferredLanguages' = @()
		'IsSigned' = $false
		'IsSignedBy' = $null
		'HasGoodSignature' = $false
	}

	#region Get "security.txt" file.
	If ($PSCmdlet.ParameterSetName -eq 'Offline') {
		$securityTxt = $input
		Write-Debug -Message "Parsing a $($securityTxt.Length)-character string."
	}
	Else {
		$Return.For = $Domain

		# Below are the parameters we will be using for Invoke-WebRequest.
		$Params = @{
			'Method'          = 'GET'
			'UseBasicParsing' = $true
			'UserAgent'       = $script:UserAgent
		}

		# We are duplicating much of the code inside Find-SecurityTxtFile and
		# Get-SecurityTxtFile.  However, some warnings should be treated as
		# errors, and we do need to keep track of that state as we go.
		$WebRequest = $null
		ForEach ($Uri in @(
			"https://$Domain/.well-known/security.txt",
			"https://$Domain/security.txt",
			"http://$Domain/.well-known/security.txt",
			"http://$Domain/security.txt")
		) {
			Write-Verbose "Downloading $Uri"
			$WebRequest = Invoke-WebRequest @Params -Uri $Uri -ErrorAction SilentlyContinue
			If ($WebRequest.StatusCode -eq 200) {
				Break
			}
		}
		If (-Not $WebRequest -Or $WebRequest.StatusCode -NotLike '2*') {
			Write-Error -Message "No `"security.txt`" file was found at $Domain."
			Return $null
		}

		If ($WebRequest.BaseResponse.RequestMessage.RequestUri.Scheme -eq 'http') {
			Write-Error -Message "The `"security.txt`" file for $Domain could not be downloaded via HTTPS."
			$Return.IsValid = $false
		}

		If ($WebRequest.BaseResponse.RequestMessage.RequestUri.AbsolutePath -eq 'security.txt') {
			Write-Warning -Message "The `"security.txt`" file for $Domain was found in the root folder, but not in the .well-known folder."
		}

		# Check to make sure this file was served via HTTP 1.0 or higher.
		If ($WebRequest.RawContent.Substring(0,6) -Cne 'HTTP/1') {
			Write-Error -Message "The `"security.txt`" file for $Domain was not downloaded by HTTP 1.0 or newer."
			$Return.IsValid = $false
		}

		# Check to make sure that this file has the correct content type.
		If ($WebRequest.Headers.'Content-Type' -NotMatch 'text\/plain(;\s*charset=[Uu][Tt][Ff]-8)?') {
			Write-Error -Message "The `"security.txt`" file for $Domain was served with the incorrect MIME type."
			$Return.IsValid = $false
		}

		$securityTxt = $WebRequest.Content
	}
	#endregion

	#region Read all fields from the file.
	$securityTxt -Split "`r?`n+" `
	  | Select-String -Pattern '^[A-Za-z-]+:\s+' `
	  | ForEach-Object {
			$FieldName, $FieldValue = $_ -Split ":\s+",2
			Switch ($FieldName)
			{
				'Acknowledgments' {
					$AckUri = [Uri]$FieldValue
					If ($AckUri.Scheme -eq 'http') {
						Write-Error -Message 'An Acknowledgments URI uses insecure HTTP.'
						$Return.IsValid = $false
					}
					$Return.Acknowledgements += $AckUri
				}

				'Canonical' {
					$CanonicalUri = [Uri]$FieldValue
					If ($CanonicalUri.Scheme -eq 'http') {
						Write-Error -Message 'A Canonical URI uses insecure HTTP.'
						$Return.IsValid = $false
					}
					
					# We will check for canonicity by testing against both the
					# $Uri parameter and the URI used to request this resource
					# (i.e., after an HTTP 301 redirects).  The RFC leaves the
					# behavior intentionally vague, so we will leave the final
					# decision up to the human instead of the code.
					# See https://github.com/securitytxt/security-txt/issues/217
					#
					# If we have already established canonicity, we don't need
					# to continue checking URIs.  Some "security.txt" files may
					# have a lot of them.
					If (-Not $Return.IsCanonical) {
						Write-Verbose "The URL requested was: $Uri"
						Write-Verbose "The URL used was:      $($WebRequest.BaseResponse.RequestMessage.RequestUri)"
						Write-Verbose "This Canonical URL is: $canonicalUri"
						If ($PSCmdlet.ParameterSetName -eq 'Offline') {
							Write-Verbose "The testing URL is:  $TestCanonicalUri"
						}
						If (($PSCmdlet.ParameterSetName -eq 'Online' -and (
								$CanonicalUri -eq $Uri -or
								$CanonicalUri -eq $WebRequest.BaseResponse.RequestMessage.RequestUri
							)) `
							-or $CanonicalUri -eq $TestCanonicalUri
						) {
							Write-Verbose "^^ MATCHED!"
							$Return.IsCanonical = $true
						}
					}
					$Return.Canonical += $CanonicalUri
				}

				'Contact' {
					$ContactUri = [Uri]$FieldValue
					If ($ContactUri.Scheme -eq 'http') {
						Write-Error -Message 'A Contact URI uses insecure HTTP.'
						$Return.IsValid = $false
					}

					$Return.Contact += $ContactUri
				}
				
				'Encryption' {
					$KeyUri = [Uri]$FieldValue
					If ($KeyUri.Scheme -eq 'http') {
						Write-Error -Message 'An Encryption URI uses insecure HTTP.'
						$Return.IsValid = $false
					}
					$Return.Encryption += $KeyUri
				}

				'Expires' {
					If ($null -ne $Return.Expires) {
						Write-Error -Message 'The Expires field is specified more than once!'
						$Return.IsValid = $false
					}

					Try {
						$Return.Expires = Get-Date $FieldValue
						If ((Get-Date) -gt $Return.Expires) {
							Write-Error -Message "This file expired at $($Return.Expires)!"
							$Return.IsValid = $false
						}
					}
					Catch {
						Write-Error -Message 'The Expires field could not be parsed.'
						$Return.IsValid = $false
					}
				}
				
				'Hiring' {
					$JobsUri = [Uri]$FieldValue
					If ($JobsUri.Scheme -eq 'http') {
						Write-Error -Message 'A Hiring URI uses insecure HTTP.'
						$Return.IsValid = $false
					}
					$Return.Hiring += $JobsUri
				}

				'Preferred-Languages' {
					If ($Return.PreferredLanguages.Count -ne 0) {
						Write-Error -Message 'The Preferred-Languages field was specified more than once.'
						$Return.IsValid = $false
					}

					$FieldValue -Split ',\s*' | ForEach-Object {
						$Return.PreferredLanguages += $_
					}
				}
				
				'Policy' {
					$PolicyUri = [Uri]$FieldValue
					If ($PolicyUri.Scheme -eq 'http') {
						Write-Error -Message 'A Hiring URI uses insecure HTTP.'
						$Return.IsValid = $false
					}
					$Return.Policy += $PolicyUri
				}
			}
	}
	#endregion

	#region Check for mandatory fields, expiration, and signatures.
	If (-Not $Return.IsCanonical) {
		Write-Error -Message 'A matching Canonical field was not found.  This file should not be trusted for this domain.'
		# However, we're not going to call the file invalid.
	}
	If ($null -eq $Return.Contact) {
		Write-Error -Message 'The mandatory Contact field was not found.'
		$Return.IsValid = $false
	}
	If ($null -eq $Return.Expires) {
		Write-Error -Message 'The mandatory Expires field was not found.'
		$Return.IsValid = $false
	}

	$GnuPGApp = (Get-Command -Name 'gpg' | Select-Object -First 1)
	If ($null -ne $GnuPGApp) {
		Try {
			$VerifyStdInFile  = New-TemporaryFile
			$VerifyStdoutFile = New-TemporaryFile
			$VerifyStderrFile = New-TemporaryFile
			Set-Content -Path $VerifyStdinFile -Value $SecurityTxt

			$SigningProcess = @{
				'FilePath' = $GnuPGApp.Source
				'ArgumentList' = @('--verify', '--status-fd=2') # note =2 will per default put the extra info into STDERR
				'LoadUserProfile' = $true	# to use the user's $env:GNUPGHOME
				'RedirectStandardInput'  = $VerifyStdinFile
				'RedirectStandardError'  = $VerifyStderrFile
				'RedirectStandardOutput' = $VerifyStdoutFile
				'Wait' = $true
			}
			Start-Process @SigningProcess

			# On my system, `gpg --verify` emits to stderr.  Not sure why.
			# Just in case it emits to stdout on your system, we'll pull from
			# the stdout file in case stderr is blank.
			$VerifyResults = Get-Content $VerifyStderrFile -Raw
			Write-Debug "Error stream from gpg:  $VerifyResults"
			If ($null -eq $VerifyResults) {
				$VerifyResults = Get-Content $VerifyStdoutFile -Raw
				Write-Debug "Error stream null.  Switching to output stream:  $VerifyResults"
			}

			$Return.IsSigned = $VerifyResults -Match '\[GNUPG\:\] (?:NEW|GOOD)SIG'
			If ($Return.IsSigned) {
				Try {
					# The pattern constructs itself as follows:
					# '\[GNUPG\:\] ' The GNUPG status-fd preamble
					# '(?:NEW|GOOD)SIG' Either gnupg has a matching key in the keyring then GOODSIG else NEWSIG
					# '(.*)' Signer
					$Pattern = '\[GNUPG\:\] (?:NEW|GOOD|BAD)SIG (.*)'
					$Return.IsSignedBy = (Select-String -InputObject $VerifyResults -Pattern $Pattern).Matches.Groups[1].Value
				}
				Catch {
					# This pattern is the same as above.  If nothing was captured
					# above, then ERRSIG will show us the cryptographically-correct
					# signature from an unknown signer.
					$Pattern = '\[GNUPG\:\] ERRSIG ([0-9A-F]{16})'
					$Return.IsSignedBy = "unknown key $((Select-String -InputObject $VerifyResults -Pattern $Pattern).Matches.Groups[1].Value)"
				}
			}
			$Return.HasGoodSignature = $VerifyResults -match '\[GNUPG\:\] (?:ERR|VALID)SIG'
		}
		Finally {
			Remove-Item -Path $VerifyStdinFile  -Force -ErrorAction Ignore
			Remove-Item -Path $VerifyStdoutFile -Force -ErrorAction Ignore
			Remove-Item -Path $VerifyStderrFile -Force -ErrorAction Ignore
		}

	}
	#endregion

	Return $Return
}

Function New-SecurityTxtFile {
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
	[Alias('nsectxt', 'Set-SecurityTxtFile', 'ssectxt')]
	[OutputType([String], ParameterSetName='ToPipeline')]
	[OutputType([void],   ParameterSetName='ToFile')]
	Param(
		[Parameter(Position=0, ParameterSetName='ToFile')]
		[IO.File] $OutFile,

		[Alias('Acknowledgements')]
		[Uri[]] $Acknowledgments,
		
		[Alias('Uri','Url')]
		[ValidateNotNullOrEmpty()]
		[Uri[]] $Canonical,
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[Uri[]] $Contact,
		
		[Uri[]] $Encryption,
		
		[ValidateNotNullOrEmpty()]
		[DateTime] $Expires,

		[Uri[]] $Hiring,
		
		[Uri[]] $Policy,
		
		[Alias('Languages', 'Preferred-Languages')]
		[String[]] $PreferredLanguages,

		[Switch] $DoNotSign
	)

	$Lines = @(
		'# This is a "security.txt" file that complies with RFC 9116:'
		'# <https://www.rfc-editor.org/rfc/rfc9116>'
		'#',
		'# This file was made with SecurityTxtToolkit:',
		'# <https://github.com/rhymeswithmogul/SecurityTxtToolkit>',
		''
	)

	ForEach ($value in $Acknowledgments) {
		$Lines += "Acknowledgments: $value"
	}

	ForEach ($value in $Canonical) {
		$Lines += "Canonical: $value"
	}

	ForEach ($value in $Contact) {
		$Lines += "Contact: $value"
	}

	ForEach ($value in $Encryption) {
		$Lines += "Encryption: $value"
	}

	If ($null -eq $Expires) {
		$Expires = (Get-Date).AddYears(1)
	}
	$Lines += "Expires: $(Get-Date $Expires -Format 'yyyy-MM-ddTHH:mm:ssK')"

	ForEach ($value in $Hiring) {
		$Lines += "Hiring: $value"
	}

	ForEach ($value in $Policy) {
		$Lines += "Policy: $value"
	}

	If ($PreferredLanguages) {
		$Lines += "Preferred-Languages: $($PreferredLanguages -Join ', ')"
	}

	$FileContent = $Lines -Join "`r`n"

	Try {
		If ($DoNotSign) {
			Throw
		}

		$UnsignedFile = New-TemporaryFile
		Set-Content -Path $UnsignedFile -Value "$FileContent`r`n" -Encoding utf8

		$SignedFile   = New-TemporaryFile
		$SigningProcess = @{
			'FilePath' = (Get-Command 'gpg').Source
			'ArgumentList' = '--clear-sign'
			'RedirectStandardInput' = $UnsignedFile
			'RedirectStandardOutput' = $SignedFile
			'Wait' = $true
		}
		Start-Process @SigningProcess

		If ($PSCmdlet.ParameterSetName -eq 'ToFile' -and $PSCmdlet.ShouldProcess($OutFile, 'Create clear-signed file')) {
			Move-Item -Path $SignedFile -Destination $OutFile
		}
		Else {
			Get-Content -Path $SignedFile
		}
	}
	Catch {
		If ($PSCmdlet.ParameterSetName -eq 'ToFile' -and $PSCmdlet.ShouldProcess($OutFile, 'Create unsigned file')) {
			Set-Content -Path $OutFile -Value $FileContent -Encoding utf8
		}
		Else {
			$FileContent
		}
	}
	Finally {
		# If the temporary files still exist, delete them.
		# We're using calls to Get-Variable due to strict mode being set.
		If (Get-Variable UnsignedFile -ErrorAction Ignore) {
			Remove-Item -Path $UnsignedFile -Force -ErrorAction Ignore
		}
		If (Get-Variable SignedFile -ErrorAction Ignore) {
			Remove-Item -Path $SignedFile   -Force -ErrorAction Ignore
		}
	}
}