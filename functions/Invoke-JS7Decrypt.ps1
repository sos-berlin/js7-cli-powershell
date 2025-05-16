function Invoke-JS7Decrypt
{
<#
.SYNOPSIS
Decrypts a value or file using an X.509 Private Key

.DESCRIPTION
The cmdlet decrypts results of a previous, asymmetric encryption,
for details see https://kb.sos-berlin.com/display/JS7/JS7+-+Encryption+and+Decryption

.PARAMETER Value
Specifies the result that was returned by previous encryption. The result includes the following elements separated by spaces:

* encrypted symmetric key
* initialization vector
* encrypted secret or path to encrypted file

.PARAMETER File
Specifies the location of the encrypted file that should be decrypted.

.PARAMETER OutFile
Specifies the location of the decrypted output file that should be created if the -File parameter is used.

If the output file exists, then it will be overwritten.

.PARAMETER Key
Specifies the X.509 Certificate object holding the Private Key that should be used to decrypt an encrypted value or file.

Certificate objects can be retrieved from a Windows certificate store using the Certificate's thumbprint like this:
$cert = Get-ChildItem cert:\CurrentUser\my | Where { $_.Thumbprint -eq '2B03EA68F103E80D83228ABCF88A3B448CC8B257' }

Only one of the parameters -Key or -KeyPath can be used.

Decryption requires use of the -JavaLib parameter that points to the location of JS7 encryption libraries.

.PARAMETER KeyPath
Specifies the location of the Private Key file that is required to decrypt an encrypted value or file.

Only one of the parameters -Key or -KeyPath can be used.

Decryption requires use of the -JavaLib parameter that points to the location of JS7 encryption libraries.

.PARAMETER KeyCredential
Specifies a credential object holding the password that is optionally used to protect the Private Key.
The password can be specified from a credential object in a number of ways, for example

$credential = (New-Object -typename System.Management.Automation.PSCredential -ArgumentList 'key', ( 'jobscheduler' | ConvertTo-SecureString -AsPlainText -Force))

The 'key' credential name can be chosen arbitrarily, the 'jobscheduler' password as added to the credential object from a Secure String.

.PARAMETER JavaHome
Specifies the location to which Java is installed. Java is required to decrypt values or files.
If the parameter is not specified then Java will be used from the value of the JAVA_HOME or PATH environment variables.

.PARAMETER JavaOptions
Specifies the Java options used when invoking Java for decryption using the -Key or -KeyPath parameters.
Java options can be used for example to limit memory usage as with -JavaOptions "-Xmx32m".

.PARAMETER JavaLib
Specifies the location of the JS7 encryption libraries.

The libraries ship with Agents and are available from the Agent's <agent-home>/lib directory. For decryption outside of JS7 products the JS7 encryption libraries are available for download.

.OUTPUTS
This cmdlet returns the decrypted secret. If the -File parameter is used then no output is returned and instead the decrypted file specified with the -OutFile parameter will created.

.EXAMPLE
Invoke-JS7Decrypt -Value $result -KeyPath C:\js7\js7.encryption\agent.key -KeyCredential (New-Object -typename System.Management.Automation.PSCredential -ArgumentList 'key', ( 'jobscheduler' | ConvertTo-SecureString -AsPlainText -Force)) -JavaLib C:\js7\js7.encryption\lib

Returns the decrypted secret of a previous encryption operation. The -KeyPath argument specifies the location of the Private Key file. The -JavaLib argument specifies the location of the JS7 encryption libraries.

.EXAMPLE
Invoke-JS7Decrypt -Value $result -File /tmp/secret.txt.enc -OutFile /tmp/secret.txt.dec -KeyPath C:\js7\js7.encryption\agent.key -KeyCredential (New-Object -typename System.Management.Automation.PSCredential -ArgumentList 'key', ( 'jobscheduler' | ConvertTo-SecureString -AsPlainText -Force)) -JavaLib C:\js7\js7.encryption\lib

Creates the decrypted file from a previous encryption operation. The -KeyPath argument specifies the location of the Private Key file. The -JavaLib argument specifies the location of the JS7 encryption libraries.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Value,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $File,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $OutFile,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [System.Security.Cryptography.X509Certificates.X509Certificate2] $Key,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $KeyPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [System.Management.Automation.PSCredential] $KeyCredential,
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

        if ( $File -and !$OutFile )
        {
            throw "$($MyInvocation.MyCommand.Name): Use of the -File parameter requires to specify the -OutFile parameter."
        }

        if ( !$Key -and !$KeyPath )
        {
            throw "$($MyInvocation.MyCommand.Name): One of the parameters -Key and -KeyPath must be used."
        }

        if ( $Key -and $KeyPath )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of the parameters -Key or -KeyPath can be used."
        }
    }

    Process
    {
        try
        {
            if ( $Value.split(' ').count -ne 3 )
            {
               throw "$($MyInvocation.MyCommand.Name): value does not include symmetric key, initialization vector and encrypted secret separated by space: -Value $Value"
            }

            if ( $File -and !(Test-Path -Path $File -PathType leaf) )
            {
                throw "$($MyInvocation.MyCommand.Name): file not found: -File $File"
            }

            if ( $Key )
            {
                $tempPrivateKeyFile = New-TemporaryFile
                "-----BEGIN PRIVATE KEY-----" | Out-File $tempPrivateKeyFile
                [System.Convert]::ToBase64String($EncryptCertificate.RawData, [System.Base64FormattingOptions]::InsertLineBreaks) | Out-File $tempPrivateKeyFile -Append
                "-----END PRIVATE KEY-----" | Out-File $tempPrivateKeyFile -Append

                $KeyPath = $tempPrivateKeyFile
            }

            if ( $KeyPath -and !(Test-Path -Path $KeyPath -PathType leaf) )
            {
                throw "$($MyInvocation.MyCommand.Name): file not found: -PrivateKeyPath $KeyPath"
            }

            if ( $JavaHome -and !(Test-Path -Path $JavaHome -PathType container) )
            {
                throw "$($MyInvocation.MyCommand.Name): directory not found: -JavaHome $JavaHome"
            }

            if ( $JavaHome -and !(Get-Command "$($JavaHome)/bin/java" -ErrorAction silentlycontinue) )
            {
                throw "$($MyInvocation.MyCommand.Name): Java binary ./bin/java not found from Java Home directory: -JavaHome $JavaHome"
            }

            if  ( $KeyPath -and !$JavaHome )
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

            if ( $KeyPath -and $JavaOptions )
            {
                [Environment]::SetEnvironmentVariable('JAVA_OPTIONS', $JavaOptions)
            }

            if ( $KeyPath -and !$JavaLib )
            {
                throw "$($MyInvocation.MyCommand.Name): parameter is required when using -PrivateKeyPath argument: -JavaLib"
            }

            if ( $JavaLib -and !(Test-Path -Path $JavaLib -PathType container) )
            {
                throw "$($MyInvocation.MyCommand.Name): directory not found: -JavaLib $JavaLib"
            }
        } catch {
            if ( $tempPrivateKeyFile -and (Test-Path -Path $tempPrivateKeyFile -PathType leaf) )
            {
                Remove-Item -Path $tempPrivateKeyFile -Force
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

            $cmdArgList += @(
                '-classpath', "$($JavaLib)/patches/*$($separator)$($JavaLib)/sos/*$($separator)$($JavaLib)/3rd-party/*$($separator)$($JavaLib)/stdout",
                "com.sos.commons.encryption.executable.Decrypt",
                "--key=$($KeyPath)",
                "--in=$($Value)")

            if ( $KeyCredential )
            {
                $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($KeyCredential.password)
                $password = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($ptr)
                $cmdArgList += @( "--key-password=$($password)")
            }

            if ( $File ) {
                $cmdArgList += @(
                    "--infile=$($File)",
                    "--outfile=$($OutFile)" )
            }
            
            $cmdPath = "$($env:JAVA_HOME)/bin/java"
            $result=(& $cmdPath $cmdArgList) | Out-String

            # remove trailing \n\r added from Out-String
            $result=(($result -replace "`r`$", '') -replace "`n`$", '')
            $result

            if ( $tempPrivateKeyFile -and (Test-Path -Path $tempPrivateKeyFile -PathType leaf) )
            {
                Remove-Item -Path $tempPrivateKeyFile -Force
            }
        } catch {
            if ( $tempPrivateKeyFile -and (Test-Path -Path $tempPrivateKeyFile -PathType leaf) )
            {
                Remove-Item -Path $tempPrivateKeyFile -Force
            }

            $message = $_.Exception | Format-List -Force | Out-String
            throw "Exception occurred in line number $($_.InvocationInfo.ScriptLineNumber)`n$($message)"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
