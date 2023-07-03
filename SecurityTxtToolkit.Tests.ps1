#Requires -Modules @{ModuleName='Pester'; ModuleVersion='5.0.0'}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ModuleHelpFile',	Justification='Variable is used in another scope.')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'psm1File',			Justification='Variable is used in another scope.')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'TempFile',			Justification='Variable is used in another scope.')]
Param()

BeforeAll {
	Import-Module -Name (Join-Path -Path '.' -ChildPath 'SecurityTxtToolkit.psd1') -ErrorAction Stop
}

Context 'Validate the module files' {
	BeforeAll {
		$psm1File       = Join-Path -Path 'src'   -ChildPath 'SecurityTxtToolkit.psm1'
		$ModuleHelpFile = Join-Path -Path 'en-US' -ChildPath 'SecurityTxtToolkit-help.xml'
	}
	It 'has a module manifest' {
		'SecurityTxtToolkit.psd1' | Should -Exist
	}
	It 'has a root module' {
		$psm1File | Should -Exist
	}
	It 'has a valid root module' {
		$code = Get-Content -Path $psm1File -ErrorAction Stop
		$errors = $null
		$null = [Management.Automation.PSParser]::Tokenize($code, [ref]$errors)
		$errors.Count | Should -Be 0
	}
	It 'has a conceptual help file explaining this module' {
		Join-Path -Path 'en-US' -ChildPath 'about_SecurityTxtToolkit.help.txt' | Should -Exist
	}
	It 'has a conceptual help file explaining RFC 9116' {
		Join-Path -Path 'en-US' -ChildPath 'about_SecurityTxt.help.txt' | Should -Exist
	}
	It 'has a module help file' {
		$ModuleHelpFile | Should -Exist
	}
	It 'has a valid module help file' {
		$code = [Xml](Get-Content -Path $ModuleHelpFile -ErrorAction Stop)
		$code.Count | Should -Be 1
	}
}

Describe 'Find-SecurityTxtFile' {
	It 'Can find a "security.txt" file in the correct location' {
		Find-SecurityTxtFile -Domain 'securitytxt.org' | Should -Be 'https://securitytxt.org/.well-known/security.txt'
	}
	It 'Fails when a "security.txt" file does not exist' {
		Mock 'Find-SecurityTxtFile' {
			Return $null
		}
		Find-SecurityTxtFile -Domain 'ietf.org' -ErrorAction SilentlyContinue | Should -Be $null
	}
}

Describe 'Get-SecurityTxtFile' {
	It 'Can download a "security.txt" file' {
		Get-SecurityTxtFile -Domain 'securitytxt.org' | Should -Not -Be $null
	}
}

Describe 'Test-SecurityTxtFile' {
	BeforeEach {
		Mock Get-SecurityTxtFile {
			Return @'
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Contact: https://hackerone.com/ed
Expires: 2024-03-14T00:00:00.000Z
Acknowledgments: https://hackerone.com/ed/thanks
Preferred-Languages: en, fr, de
Canonical: https://securitytxt.org/.well-known/security.txt
Policy: https://hackerone.com/ed?type=team&view_policy=true
-----BEGIN PGP SIGNATURE-----

iHUEARYKAB0WIQSsP2kEdoKDVFpSg6u3rK+YCkjapwUCY9qRaQAKCRC3rK+YCkja
pwALAP9LEHSYMDW4h8QRHg4MwCzUdnbjBLIvpq4QTo3dIqCUPwEA31MsEf95OKCh
MTHYHajOzjwpwlQVrjkK419igx4imgk=
=KONn
-----END PGP SIGNATURE-----
'@
		}
	}

	It 'Can test files when passed an input object' {
		$result = Get-SecurityTxtFile -Domain 'securitytxt.org' | Test-SecurityTxtFile -ErrorAction Ignore
		$result.For | Should -Be 'stdin'
		$result.IsValid | Should -BeTrue
		$result.IsCanonical | Should -BeFalse
		$result.Acknowledgements | Should -Be 'https://hackerone.com/ed/thanks'
		$result.Canonical | Should -Be 'https://securitytxt.org/.well-known/security.txt'
		$result.Contact | Should -Be 'https://hackerone.com/ed'
		$result.Encryption | Should -Be $null
		$result.Expires | Should -Be (Get-Date -Date '2024-03-14T00:00:00Z')
		$result.Hiring | Should -Be $null
		$result.Policy | Should -Be 'https://hackerone.com/ed?type=team&view_policy=true'
		$result.PreferredLanguages | Should -Be @('en','fr','de')
		$result.IsSigned | Should -BeTrue
		$result.IsSignedBy | Should -BeLike '*B7ACAF980A48DAA7*'	# the output varies depending on your GPG keyring
		$result.HasGoodSignature | Should -BeTrue
	}

	It 'Can test files and canonical URLs when passed an input object' {
		$CanonicalUrl = 'https://securitytxt.org/.well-known/security.txt'
		$result = Get-SecurityTxtFile -Domain 'securitytxt.org' | Test-SecurityTxtFile -TestCanonicalUri $CanonicalUrl
		$result.Canonical   | Should -Be $CanonicalUrl
		$result.IsCanonical | Should -BeTrue
	}

	It 'Can test files and canonical URLs when fetched online' {
		# Their "security.txt" file may change over time, so we're only going
		# to test the properties that we know will be true.  Note that we'll
		# have to replace this test if this domain ever goes down.
		$result = Test-SecurityTxtFile -Domain 'securitytxt.org'
		$result.For | Should -Be 'securitytxt.org'
		$result.IsValid | Should -BeTrue
		$result.IsCanonical | Should -BeTrue
		$result.Canonical | Should -Be 'https://securitytxt.org/.well-known/security.txt'
	}
}

Describe 'Save-SecurityTxtFile' {
	BeforeAll {
		$TempFile = New-TemporaryFile
	}

	It 'Can download "security.txt" files' {
		Save-SecurityTxtFile -Domain 'securitytxt.org' -OutFile $TempFile -Confirm:$false -Force
		Get-Content $TempFile | Should -Not -Be $null
	}

	AfterAll {
		Remove-Item -Path $TempFile -Force -ErrorAction Ignore
	}
}

AfterAll {
	Remove-Module -Name 'SecurityTxtToolkit' -ErrorAction Ignore
}
