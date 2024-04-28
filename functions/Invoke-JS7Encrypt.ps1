function Invoke-JS7Encrypt
{
<#
.SYNOPSIS
Encrypts a value or file using an X.509 Certificate or Public Key

.DESCRIPTION
The cmdlet encrypts strings, numbers and files using asymmetric encryption,
for details see https://kb.sos-berlin.com/display/JS7/JS7+-+Encryption+and+Decryption

.PARAMETER Value
Specifies the value that should be encrypted.

Only one of the parameters -Value or -File can be used.

.PARAMETER File
Specifies the location of an input file that should be encrypted.

Only one of the parameters -Value or -File can be used.

.PARAMETER OutFile
Specifies the location of the encrypted output file that should be created if the -File parameter is used.

If the output file exists, then it will be overwritten.

.PARAMETER Certificate
Specifies that a value or file should be encrypted using a Certificate object.
Consider that the component that will decrypt the value or file will require access to the Private Key matching the Certificate.

Certificate objects can be retrieved from a Windows certificate store using the Certificate's thumbprint like this:
$cert = Get-ChildItem cert:\CurrentUser\my | Where { $_.Thumbprint -eq '2B03EA68F103E80D83228ABCF88A3B448CC8B257' }

Only one of the parameters -Certificate or -CertificatePath can be used.

Encryption requires use of the -JavaLib parameter that points to the location of JS7 encryption libraries.

.PARAMETER CertificatePath
Specifies that a value or file should be encrypted using a Certificate or Public Key in PEM format from the indicated location.
Consider that the component that will decrypt the value or file will require access to the Private Key matching the Certificate/Public Key.

Encryption can be applied to values specified with the -Value parameter and to files specified with the -File parameter.

Only one of the parameters -Certificate or -CertificatePath can be used.

Encryption requires use of the -JavaLib parameter that points to the location of JS7 encryption libraries.

.PARAMETER JavaHome
Specifies the location to which Java is installed. Java is required to encrypt values or files.
If the parameter is not specified then Java will be used from the value of the JAVA_HOME or PATH environment variables.

.PARAMETER JavaOptions
Specifies the Java options used when invoking Java for encryption using the -CertificatePath or -Certificate parameters.
Java options can be used for example to limit memory usage as with -JavaOptions "-Xmx32m".

.PARAMETER JavaLib
Specifies the location of the JS7 encryption libraries.

The libraries ship with Agents and are available from the Agent's <agent-home>/lib directory. For encryption outside of JS7 products the JS7 encryption libraries are available for download.

.OUTPUTS
This cmdlet return the encryption result that holds the following elements separated by spaces:

* encrypted symmetric key
* initialization vector
* encrypted secret if the -Value parameter is used or path to the encrypted file if the -File and -OutFile parameters are used

.EXAMPLE
$result = Invoke-JS7Encrypt -Value '12345678' -CertificatePath C:\js7\js7.encryption\agent.crt -JavaLib C:\js7\js7.encryption\lib

Returns the encryption result. The -CertificatePath argument specifies the location of the Certificate or Public Key file. The -JavaLib argument specifies the location of the JS7 encryption libraries.

.EXAMPLE
$result = Invoke-JS7Encrypt -File /tmp/secret.txt -OutFile /tmp/secret.txt.enc -CertificatePath C:\js7\js7.encryption\agent.crt -JavaLib C:\js7\js7.encryption\lib

Returns the encryption result. The -EnctypeCertificatePath argument specifies the location of the Certificate or Public Key file. The -JavaLib argument specifies the location of the JS7 encryption libraries.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Value,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $File,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $OutFile,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [System.Security.Cryptography.X509Certificates.X509Certificate2] $Certificate,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $CertificatePath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $JavaHome,
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $JavaLib,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $JavaOptions
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        if ( !$Value -and !$File )
        {
            throw "$($MyInvocation.MyCommand.Name): One of the parameters -Value or -File must be used."
        }

        if ( $Value -and $File )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of the parameters -Value or -File can be used."
        }

        if ( $File -and !$OutFile )
        {
            throw "$($MyInvocation.MyCommand.Name): Use of the -File parameter requires to specify the -OutFile parameter."
        }

        if ( !$Certificate -and !$CertificatePath )
        {
            throw "$($MyInvocation.MyCommand.Name): One of the parameters -Certificate or -CertificatePath must be used."
        }

        if ( $Certificate -and $CertificatePath )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of the parameters -Certificate or -CertificatePath can be used."
        }
    }

    Process
    {
        try
        {
            if ( $File -and !(Test-Path -Path $File -PathType leaf) )
            {
                throw "$($MyInvocation.MyCommand.Name): file not found: -File $File"
            }

            if ( $Certificate )
            {
                $tempCertificateFile = New-TemporaryFile
                "-----BEGIN CERTIFICATE-----" | Out-File $tempCertificateFile
                [System.Convert]::ToBase64String($Certificate.RawData, [System.Base64FormattingOptions]::InsertLineBreaks) | Out-File $tempCertificateFile -Append
                "-----END CERTIFICATE-----" | Out-File $tempCertificateFile -Append

                $CertificatePath = $tempCertificateFile
            }

            if ( $CertificatePath -and !(Test-Path -Path $CertificatePath -PathType leaf) )
            {
                throw "$($MyInvocation.MyCommand.Name): file not found: -CertificatePath $CertificatePath"
            }

            if ( $JavaHome -and !(Test-Path -Path $JavaHome -PathType container) )
            {
                throw "$($MyInvocation.MyCommand.Name): directory not found: -JavaHome $JavaHome"
            }

            if ( $JavaHome -and !(Get-Command "$($JavaHome)/bin/java" -ErrorAction silentlycontinue) )
            {
                throw "$($MyInvocation.MyCommand.Name): Java binary ./bin/java not found from Java Home directory: -JavaHome $JavaHome"
            }

            if  ( $CertificatePath -and !$JavaHome )
            {
                if ( $env:JAVA_HOME )
                {
                    $java = (Get-Command "$($env:JAVA_HOME)/bin/java" -ErrorAction silentlycontinue)
                } else {
                    $java = (Get-Command "java" -ErrorAction silentlycontinue)
                    if ( $java )
                    {
                        $javaHomeDir = (Get-Item -Path $java.Source).Directory.Parent.Name
                        [Environment]::SetEnvironmentVariable('JAVA_HOME', $javaHomeDir)
                    }
                }

                if ( !$java )
                {
                    throw "$($MyInvocation.MyCommand.Name): Java home not specified and no JAVA_HOME environment variable in place: -JavaHome"
                }
            }

            if ( $CertificatePath -and $JavaOptions )
            {
                [Environment]::SetEnvironmentVariable('JAVA_OPTIONS', $JavaOptions)
            }

            if ( $CertificatePath -and !$JavaLib )
            {
                throw "$($MyInvocation.MyCommand.Name): parameter is required when using -CertificatePath argument: -JavaLib"
            }

            if ( $JavaLib -and !(Test-Path -Path $JavaLib -PathType container) )
            {
                throw "$($MyInvocation.MyCommand.Name): directory not found: -JavaLib $JavaLib"
            }
        } catch {
            if ( $tempCertificateFile -and (Test-Path -Path $tempCertificateFile -PathType leaf) )
            {
                Remove-Item -Path $tempCertificateFile -Force
            }

            throw $_.Exception | Format-List -Force | Out-String
        }

        Write-Debug ".. $($MyInvocation.MyCommand.Name):"
    }

    End
    {
        try
        {
            if ( [System.Environment]::OSVersion.Platform -match 'Win32NT' )
            {
                $separator = ';'
            } else {
                $separator = ':'
            }

            $cmdArgList = @()
            $javaOptionsArgument = ( " $($env:JAVA_OPTIONS)" -split ' -')
            for( $i=0; $i -lt $javaOptionsArgument.length; $i++ )
            {
                if ( $javaOptionsArgument[$i].Trim() )
                {
                    $cmdArgList += "-$($javaOptionsArgument[$i])"
                }
            }

            if ( $Value )
            {
                $cmdPath = "$($env:JAVA_HOME)/bin/java"
                $cmdArgList += @(
                    '-classpath', "$($JavaLib)/patches/*$($separator)$($JavaLib)/sos/*$($separator)$($JavaLib)/3rd-party/*$($separator)$($JavaLib)/stdout",
                    "com.sos.commons.encryption.executable.Encrypt",
                    "--cert=$($CertificatePath)",
                    "--in=$($Value)" )
                $result=(& $cmdPath $cmdArgList) | Out-String
            } elseif ( $File ) {
                $cmdPath = "$($env:JAVA_HOME)/bin/java"
                $cmdArgList += @(
                    '-classpath', "$($JavaLib)/patches/*$($separator)$($JavaLib)/sos/*$($separator)$($JavaLib)/3rd-party/*$($separator)$($JavaLib)/stdout",
                    "com.sos.commons.encryption.executable.Encrypt",
                    "--cert=$($CertificatePath)",
                    "--infile=$($File)",
                    "--outfile=$($OutFile)" )
                $result=(& $cmdPath $cmdArgList) | Out-String
            }

            # remove trailing \n\r added from Out-String
            $result=(($result -replace "`r`$", '') -replace "`n`$", '')
            $result

            if ( $tempCertificateFile -and (Test-Path -Path $tempCertificateFile -PathType leaf) )
            {
                Remove-Item -Path $tempCertificateFile -Force
            }
        } catch {
            if ( $tempCertificateFile -and (Test-Path -Path $tempCertificateFile -PathType leaf) )
            {
                Remove-Item -Path $tempCertificateFile -Force
            }

            $message = $_.Exception | Format-List -Force | Out-String
            throw "Exception occurred in line number $($_.InvocationInfo.ScriptLineNumber)`n$($message)"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
