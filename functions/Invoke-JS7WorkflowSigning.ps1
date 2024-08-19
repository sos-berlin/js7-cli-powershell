function Invoke-JS7WorkflowSigning
{
<#
.SYNOPSIS
Digitally signs JS7 workflows and related files for secure deployment in a JS7 environment operated for security level "high"

.DESCRIPTION
JS7 can be operated in environments for security level "high". This includes to have workflows digitally signed outside of JOC Cockpit in order not to have the private key within reach of JOC Cockpit.

Digital signing includes

* to export scheduling objects with the option "for signing". This will create a .tar.gz/.zip archive file holding
related scheduling objects which is available with the user's computer that connected to JOC Cockpit
** to optionally transfer the export .tar.gz/.zip archive file to a secure machine
* to digitally sign exported workflow files and job resouce filess
** to extract the .tar.gz/.zip archive file
** to create signature files, for example *.workflow.json.sig for workflow files *.workflow.json
* to create or update a .tar.gz/.zip archive file that includes both the original workflow files and newly created signature files
* to import and to deploy the .tar.gz/.zip archive file that holds the original workflows and the signature files
** JOC Cockpit offers the operation to "Import and Deploy" .tar.gz/.zip archives from a single step

.PARAMETER File
Specifies the path to a *.workflow.json or *.jobresource.json file to be signed.

If this argument is omitted then the -Dir argument will be used to look up workflow files.

.PARAMETER Dir
Specifies the path to a directory holding *.workflow.json or *.jobresource.json files to be signed. Any sub-directories will be traversed recursively.

By default the current directory is used.

.PARAMETER Keystore
Specifies the path to a keystore file that holds the private key and certificate used for signing.

The argument can be populated from the JS7_SIGN_KEYSTORE environment variable.

Only one of the -Keystore and -Key arguments can be used. If both arguments are omitted then the Windows Certificate Store will be used.

.PARAMETER Key
Specifies the path to the key file that holds the private key used for signing.

The argument can be populated from the JS7_SIGN_KEY environment variable.

Only one of the -Key and -Keystore arguments can be used. If both arguments are omitted then the Windows Certificate Store will be used.

.PARAMETER Cert
Specifies the path to the certificate file used for signing.

The argument can be populated from the JS7_SIGN_CERT environment variable.

Only one of the -Cert and -Keystore arguments can be used. If both arguments are omitted then the Windows Certificate Store will be used.

.PARAMETER Credentials
Optionally specifies a PowerShell credentials object that holds the password used for access to the key file or keystore.

.PARAMETER AskForCredentials
Optionally prompts for user input of the password used to acess the key file or keystore. The alias argument -P is available.

.PARAMETER Thumbprint
Optionally specifies the thumbprint of the code signing certificate to be used. A thumbprint identifies a certificate.

It is required to specify the thumbprint if more than one code signing certificate is available from the indicated keystore or Windows Certificate Store.

.EXAMPLE
./Invoke-JS7WorkflowSigning -Keystore /mnt/releases/certificates/release-signing/release-signing.p12 -P

Signs all *.workflow.json and *.jobresource.json files in the current directory and sub-directories using the code signing certificate from the indicated keystore asking for its password

.EXAMPLE
./Invoke-JS7WorkflowSigning -Key ./js7.key -Cert ./js7.crt

Signs all *.workflow.json and *.jobresource.json files in the current directory and sub-directories using the code signing certificate from the indicated keystore

.EXAMPLE
./Invoke-JS7WorkflowSigning

Signs all *.workflow.json and *.jobresource.json files in the current directory and sub-directories using the code signing certificate available with the Windows Certificate Store

.EXAMPLE
./Invoke-JS7WorkflowSigning -Dir C:\some\folder

Signs the all *.workflow.json and *.jobresource.json files in the indicated directory and sub-directories using the code signing certificate available with the Windows Certificate Store

.EXAMPLE
./Invoke-JS7WorkflowSigning -File ./test.workflow.json

Signs the indicated file using the code signing certificate available with the Windows Certificate Store

.EXAMPLE
./Invoke-JS7WorkflowSigning -File ./test.workflow.json -Thumbprint 'EF64BFA6BC3EF6585F64E3DEC1CD67334DDBDF3F'

Signs the indicated workflow file using the code signing certificate available with the Windows Certificate Store that is identified by the thumbprint

.EXAMPLE
./Invoke-JS7WorkflowSigning -File ./test.workflow.json -Thumbprint '2B03EA68F103E80D83228ABCF88A3B448CC8B257'

Signs the indicated workflow file using the code signing certificate available with the Windows Certificate store that is identified by the thumbprint

.EXAMPLE
./Invoke-JS7WorkflowSigning -File ./test.workflow.json -Keystore P:\releases\certificates\release-signing\release-signing.p12 -AskForCredentials

Signs the indicated workflow file using the code signing certificate available from the indicated keystore

#>

[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $File,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Dir = '.',
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Keystore,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Key,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Cert,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [System.Management.Automation.PSCredential] $Credentials,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $AskForCredentials,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Thumbprint,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Hash = 'sha256'
)

    Begin
    {
		Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        if ( !$Dir -and !$File )
        {
            throw "$($MyInvocation.MyCommand.Name): Use -Dir for a directory holding files or use -File for a single file to be signed"
        }

        if ( $Dir -and $File )
        {
            if ( $Dir -eq '.' )
            {
                $script:Dir = $null
            } else {
                throw "$($MyInvocation.MyCommand.Name): Only one of -Dir for a directory holding files or -File for a single file to be signed can be used"
            }
        }

        if ( $Keystore -and !(Test-Path -Path $Keystore -PathType leaf) )
        {
            throw "$($MyInvocation.MyCommand.Name): Keystore not found: -Keystore $($Keystore)"
        }

        if ( $Key -and !(Test-Path -Path $Key -PathType leaf) )
        {
            throw "$($MyInvocation.MyCommand.Name): Key file not found: -Key $($Key)"
        }

        if ( $Cert -and !(Test-Path -Path $Cert -PathType leaf) )
        {
            throw "$($MyInvocation.MyCommand.Name): Certificate file not found: -Cert $($Cert)"
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        switch ([System.Environment]::OSVersion.Platform)
        {
            'Win32NT' {
                New-Variable -Option Constant -Name IsWindows -Value $True -ErrorAction SilentlyContinue
                New-Variable -Option Constant -Name IsLinux  -Value $False -ErrorAction SilentlyContinue
                New-Variable -Option Constant -Name IsMacOs  -Value $False -ErrorAction SilentlyContinue
            }
        }

        # default variables
        $script:tempKeystore = $null
        $script:tempCert = $null
        $script:Hash = $Hash
    }

    Process
    {
        function Cleanup()
        {
            if ( $File -and (Test-Path -Path "$($File).pub" -PathType leaf) )
            {
                Remove-Item -Path "$($File).pub"  -Force
            }

            if ( $File -and (Test-Path -Path "$($File).sig.bin" -PathType leaf) )
            {
                Remove-Item -Path "$($File).sig.bin"  -Force
            }
        }

        function Final()
        {
            if ( $TempKeystore -and (Test-Path -Path $TempKeystore -PathType leaf) )
            {
                Remove-Item -Path $TempKeystore -Force
            }

            if ( $TempCert -and (Test-Path -Path $TempCert -PathType leaf) )
            {
                Remove-Item -Path $TempCert -Force
            }
        }

        function Get-SigningCertificate( [string] $Thumbprint )
        {
            if ( $Thumbprint )
            {
                $cert = Get-ChildItem cert:\CurrentUser\my -CodeSigningCert | Where-Object { $_.Thumbprint -eq $Thumbprint }
            } else {
                $cert = Get-ChildItem cert:\CurrentUser\my -CodeSigningCert

                if ( $cert.count -gt 1 )
                {
                    throw "More than one code signing certificate found, use: -Thumbprint $($Thumbprint)"
                }
            }

            $cert
        }

        function Add-WorkflowSignature( [string] $File, [string] $KeyStore, [string] $Key, [string] $Cert, [System.Management.Automation.PSCredential] $Credentials )
        {
            Write-Verbose ".... signing file: $($File)"

            try
            {
                if ( ($Key -or $Keystore) -and $Credentials )
                {
                    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode( $Credentials.Password )
                    $result = [System.Runtime.InteropServices.Marshal]::PtrToStringUni( $ptr )
                }

                # step 1: create signature from file
                if ( $Key )
                {
                    Write-Verbose ".... running: openssl dgst -$Hash -sign `"$($Key)`" -passin pass:`"********`" -out `"$($File).sig.bin`" `"$($File)`""
                    if ( $isWindows )
                    {
                        cmd.exe /C "openssl dgst -$Hash -sign `"$($Key)`" -passin pass:`"$($result)`" -out `"$($File).sig.bin`" `"$($File)`""
                    } else {
                        sh -c "openssl dgst -$Hash -sign '$($Key)' -passin pass:'$($result)' -out '$($File).sig.bin' '$($File)'"
                    }
                } elseif ( $Keystore ) {
                    Write-Verbose ".... running: openssl dgst -$Hash -sign `"$($Keystore)`" -keyform P12 -passin pass:`"********`" -out `"$($File).sig.bin`" `"$($File)`""
                    if ( $isWindows )
                    {
                        cmd.exe /C "openssl dgst -$Hash -sign `"$($Keystore)`" -keyform P12 -passin pass:`"$($result)`" -out `"$($File).sig.bin`" `"$($File)`""
                    } else {
                        sh -c "openssl dgst -$Hash -sign '$($Keystore)' -keyform P12 -passin pass:'$($result)' -out '$($File).sig.bin' '$($File)'"
                    }
                } else {
                    # works for exportable private keys only
                    $script:tempKeystore = New-TemporaryFile
                    Export-PfxCertificate -Cert cert:\CurrentUser\my -Force -FilePath $tempKeystore -Password $Credentials.Password
                    Write-Verbose ".... running: openssl dgst -$Hash -sign `"$($tempKeystore)`" -keyform P12 -passin pass:`"********`" -out `"$($File).sig.bin`" `"$($File)`""
                    if ( $isWindows )
                    {
                        cmd.exe /C "openssl dgst -$Hash -sign `"$($tempKeystore)`" -keyform P12 -passin pass:`"$($result)`" -out `"$($File).sig.bin`" `"$($File)`""
                    } else {
                        sh -c "openssl dgst -$Hash -sign '$($tempKeystore)' -keyform P12 -passin pass:'$($result)' -out '$($File).sig.bin' '$($File)'"
                    }
                }

                if ( $LASTEXITCODE )
                {
                    throw "Error running openssl to create signature file"
                }

                # step 2: convert signature to base64
                Write-Verbose ".... running: openssl base64 -in `"$($File).sig.bin`" -out `"$($File).sig`""
                if ( $isWindows )
                {
                    cmd.exe /C "openssl base64 -in `"$($File).sig.bin`" -out `"$($File).sig`""
                } else {
                    sh -c "base64 '$($File).sig.bin' > '$($File).sig'"
                }

                # step 3: prepare certificate file
                if ( !$Cert )
                {
                    $tempCert = New-TemporaryFile

                    if ( $Keystore )
                    {
                        Write-Verbose ".... running: openssl pkcs12 -in `"$($Keystore)`" -passin pass:`"********`" -passout pass:`"********`" -nokeys -out `"$($tempCert)`""
                        if ( $isWindows )
                        {
                            cmd.exe /C "openssl pkcs12 -in `"$($Keystore)`" -passin pass:`"$($result)`" -passout pass:`"$($result)`" -nokeys -out `"$($tempCert)`"" | Out-Null
                        } else {
                            sh -c "openssl pkcs12 -in '$($Keystore)' -passin pass:'$($result)' -passout pass:'$($result)' -nokeys -out '$($tempCert)'" | Out-Null
                        }
                    } elseif ( $Key ) {
                        Write-Verbose ".... running: openssl pkcs12 -in `"$($Key)`" -passin pass:`"********`" -passout pass:`"********`" -nokeys -out `"$($tempCert)`""
                        if ( $isWindows )
                        {
                            cmd.exe /C "openssl pkcs12 -in `"$($Key)`" -passin pass:`"$($result)`" -passout pass:`"$($result)`" -nokeys -out `"$($tempCert)`"" | Out-Null
                        } else {
                            sh -c "openssl pkcs12 -in '$($Key)' -passin pass:'$($result)' -passout pass:'$($result)' -nokeys -out '$($tempCert)'" | Out-Null
                        }
                    }

                    if ( $LASTEXITCODE )
                    {
                        throw "Error running openssl to create certificate file"
                    }
                } else {
                    $tempCert = $Cert
                }

                # step 4: verify signature from public key
                Write-Verbose ".... running: openssl x509 -in `"$($tempCert)`" -pubkey -noout > `"$($File).pub`""
                if ( $isWindows )
                {
                    cmd.exe /C "openssl x509 -in `"$($tempCert)`" -pubkey -noout > `"$($File).pub`""
                } else {
                    sh -c "openssl x509 -in '$($tempCert)' -pubkey -noout > '$($File).pub'"
                }

                if ( $LASTEXITCODE )
                {
                    throw "Error running openssl to create public key file"
                }

                Write-Verbose ".... running openssl dgst -$Hash -verify `"$($File).pub`" -signature `"$($File).sig.bin`" `"$($File)`""
                if ( $isWindows )
                {
                    cmd.exe /C "openssl dgst -$Hash -verify `"$($File).pub`" -signature `"$($File).sig.bin`" `"$($File)`""
                } else {
                    sh -c "openssl dgst -$Hash -verify '$($File).pub' -signature '$($File).sig.bin' '$($File)'"
                }

                if ( $LASTEXITCODE )
                {
                    throw "Error running openssl to verify signatue file"
                }

                Cleanup
            } catch {
                Cleanup
                $message = $_.Exception | Format-List -Force | Out-String
                throw $message
            }
        }

        if ( $AskForCredentials )
        {
            Write-Output '* ***************************************************** *'
            Write-Output '* JS7 Workflow Signing                                  *'
            Write-Output '* enter password for access to key file / keystore      *'
            Write-Output '* ***************************************************** *'
            [SecureString] $password = Read-Host -Prompt 'Enter password ' -AsSecureString

            if ( $password )
            {
                $script:Credentials = ( New-Object -typename System.Management.Automation.PSCredential -ArgumentList 'password', $password )
                $password = $null
            }
        }

        try
        {
            # works for exportable private keys only
            if ( !$Key -and !$Keystore )
            {
                $script:tempKeystore = New-TemporaryFile
                $script:Keystore = $tempKeystore
                Get-SigningCertificate -Thumbprint $Thumbprint | Export-PfxCertificate -FilePath $tempKeystore -Password $Credentials.Password -ChainOption BuildChain
            }

            if ( $File )
            {
                Add-WorkflowSignature -File $File -Keystore $Keystore -Key $Key -Cert $Cert -Credentials $Credentials
            } else {
                Get-ChildItem -Path $Dir\ -File -Recurse -Include ('*.workflow.json','*.jobresource.json') | ForEach-Object {
                    Add-WorkflowSignature -File $_.FullName $Keystore -Key $Key -Cert $Cert -Credentials $Credentials
                }
            }

            Final
        } catch {
            Final
            $message = $_.Exception | Format-List -Force | Out-String
            throw $message
        }
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
    }
}
