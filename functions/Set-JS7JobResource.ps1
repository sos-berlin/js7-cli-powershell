function Set-JS7JobResource
{
<#
.SYNOPSIS
Stores a variable to a Job Resource in the JOC Cockpit inventory.

.DESCRIPTION
A variable is created/updated in a Job Resource. If the Job Resource does not exist, then it will be created.
Values of variables can hold strings, numbers and files. Optionally the values can be encrypted,
for details see https://kb.sos-berlin.com/display/JS7/JS7+-+Encryption+and+Decryption

The following REST Web Service API resources are used:

* /inventory/store

.PARAMETER Path
Specifies the folder, sub-folder and name of the Job Resource, this is the path to which the Job Resource will be stored in the inventory.

.PARAMETER Key
Specifies the name of the variable in the Job Resource that should be stored. Considder that names of variables are case-sensitive.

.PARAMETER Value
Specifies the value that should be stored for the given variable in the Job Resource.

Only one of the parameters -Value or -File can be used.

.PARAMETER File
Specifies that the contents of a file should be added as the value of a variable to the Job Resource.

Only one of the parameters -Value or -File can be used.

.PARAMETER EnvVar
Specifies the name of the environment variable in the Job Resource that holds a reference to the variable.

* Shell jobs access Job Resource variables from environment variables.
* JVM jobs access Job Resource variables directly.

.PARAMETER AsString
The value specified for the -Value parameter is considered a string. This similarly applies to numeric values that will be quoted to preserve leading zeroas.

If none of the -AsString, -AsNumber or -AsBoolean parameters is specified then the cmdlet will guess the matching data type from the value specified with the -Value parameter.

.PARAMETER AsNumber
The value specified for the -Value parameter is considered a number. This includes that leading zeros are removed.

If none of the -AsString, -AsNumber or -AsBoolean parameters is specified then the cmdlet will guess the matching data type from the value specified with the -Value parameter.

.PARAMETER AsBoolean
The value specified for the -Value parameter is considered a Boolean. The string values 'true' and 'false' can be specified and the $True and $False built-in PowerShell constants can be used.

If none of the -AsString, -AsNumber or -AsBoolean parameters is specified then the cmdlet will guess the matching data type from the value specified with the -Value parameter.

.PARAMETER EncryptCertificate
Specifies that the value of the Job Resource variable should be encrypted using a Certificate object.
Consider that the job that will decrypt the value requires access to the Private Key matching the Certificate.

Certificate objects can be retrieved from a Windows certificate store using the Certificate's thumbprint like this:
$cert = Get-ChildItem cert:\CurrentUser\my | Where { $_.Thumbprint -eq '2B03EA68F103E80D83228ABCF88A3B448CC8B257' }

Only one of the parameters -EncryptCertificate or -EncryptCertificatePath can be used.

Encryption requires use of the -JavaLib parameter that points to the location of JS7 encryption libraries.

.PARAMETER EncryptCertificatePath
Specifies that the value of the Job Resource variable should be encrypted using a Certificate or Public Key in PEM format from the indicated location.
Consider that the job that will decrypt the value requires access to the Private Key matching the Certificate/Public Key.

Encryption can be applied to values specified with the -Value parameter and to files specified with the -File parameter.
For file encryption the variable specified by the -Key parameter holds the to_file() function and the encrypted contents of the file.
The encrypted key to decrypt the file is made avaiable from a second variable with the same name as specified by the -Key parameter
and the extension _key.

Only one of the parameters -EncryptCertificate or -EncryptCertificatePath can be used.

Encryption requires use of the -JavaLib parameter that points to the location of JS7 encryption libraries.

.PARAMETER JavaHome
Specifies the location to which Java is installed. Java will be required if values should be encrypted using the -EncryptCertificate or -EncrypCertificatePath parameters.
If the parameter is not specified then Java will be used from the value of the JAVA_HOME or PATH environment variables.

.PARAMETER JavaOptions
Specifies the Java options used when invoking Java for encryption using the -EncryptCertificate or -EncrypCertificatePath parameter.
Java options can be used for example to limit memory usage as with -JavaOptions "-Xmx32m".

.PARAMETER JavaLib
Specifies the location of the JS7 encryption libraries. The parameter is required if values should be encrypted using the -EncryptCertificate or -EncrypCertificatePath parameter.

The libraries ship with Agents and are available from the Agent's <agent-home>/lib directory. For encryption outside of JS7 products the JS7 encryption libraries are available for download.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of the JOC Cockpit.
This parameter is not mandatory. However, the JOC Cockpit can be configured to require Audit Log comments for all interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is shown in the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JS7.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JS7.

This information is shown in the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JS7.

.OUTPUTS
This cmdlet does not return any output.

.EXAMPLE
Set-JS7JobResource -Path /ProductDemo/Variables/pdBusinessDate -Key 'BusinessDate' -Value (Get-Date (Get-Date).ToUniversalTime() -Format 'yyyy-MM-dd') -EnvVar 'BUSINESS_DATE'

Stores a key/value pair to the inventory object of a Job Resource.

.EXAMPLE
Set-JS7JobResource -Path /ProductDemo/Variables/pdConfigurationData -Key 'configurationData' -File '/tmp/configuration.conf' -EnvVar 'CONFIGURATION_DATA'

Stores the key and contents of a file to the inventory object of a Job Resource.

.EXAMPLE
Set-JS7JobResource -Path /ProductDemo/Variables/pdBusinessSecret -Key 'BusinessSecret' -Value '12345678' -EnvVar 'BUSINESS_SECRET' -EncryptCertificatePath C:\js7\js7.encryption\agent.crt -JavaLib C:\js7\js7.encryption\lib

Stores a key and encrypted value to the inventory object of a Job Resource. The -EnryptCertificatePath argument specifies the location of the Certificate or Public Key file. The -JavaLib argument specifies the location of the JS7 encryption libraries.

.EXAMPLE
Set-JS7JobResource -Path /ProductDemo/Variables/pdConfigurationDataSecret -Key 'configurationDataSecret' -File /tmp/configuration.conf -EnvVar 'CONFIGURATION_DATA_SECRET' -EncryptCertificatePath C:\js7\js7.encryption\agent.crt -JavaLib C:\js7\js7.encryption\lib

Stores the key and contents of a file to the inventory object of a Job Resource. The -EncryptCertificatePath argument specifies the location of the Certificate or Public Key file. The -JavaLib argument specifies the location of the JS7 encryption libraries.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Key,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Value,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $File,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $EnvVar,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [switch] $AsString,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [switch] $AsNumber,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [switch] $AsBoolean,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [System.Security.Cryptography.X509Certificates.X509Certificate2] $EncryptCertificate,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $EncryptCertificatePath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $JavaHome,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $JavaLib,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $JavaOptions,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $AuditComment,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $AuditTimeSpent,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [Uri] $AuditTicketLink
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

        if ( $AsString -and $AsNumber )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of the parameters -AsString or -AsNumber can be used."
        }

        if ( $AsString -and $AsBoolean )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of the parameters -AsString or -AsBoolean can be used."
        }

        if ( $AsBoolean -and $AsNumber )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of the parameters -AsBoolean or -AsNumber can be used."
        }

        if ( $AsNumber -and !(isNumeric( $Value ) ) )
        {
            throw "$($MyInvocation.MyCommand.Name): When using the -AsNumber parameter then numeric values must be specified for -Value."
        }

        if ( $AsBoolean -and !($Value -eq "true" -or $Value -eq "false") )
        {
            throw "$($MyInvocation.MyCommand.Name): When using the -AsBoolean parameter then one of the values true/false must be specified for -Value."
        }

        if ( $EncryptCertificate -and $EncryptCertificatePath )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of the parameters -EncryptCertificate or -EncryptCertificatePath can be used."
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }
    }

    Process
    {
        try
        {
            # guess target data type
            if ( !$AsString -and !$AsBoolean -and !$AsNumber )
            {
                if ( $Value -eq "true" -or $Value -eq "false" )
                {
                    $AsBoolean = $True
                } elseif ( isNumeric( $Value ) )
                {
                    $AsNumber = $True
                } else {
                    $AsString = $True
                }
            }

            if ( $Path.endsWith('/') )
            {
                throw "$($MyInvocation.MyCommand.Name): path has to include folder, sub-folder and object name"
            }

            if ( $File -and !(Test-Path -Path $File -PathType leaf) )
            {
                throw "$($MyInvocation.MyCommand.Name): file not found: -File $File"
            }

            if ( $EncryptCertificate )
            {
                $tempCertificateFile = New-TemporaryFile
                "-----BEGIN CERTIFICATE-----" | Out-File $tempCertificateFile
                [System.Convert]::ToBase64String($EncryptCertificate.RawData, [System.Base64FormattingOptions]::InsertLineBreaks) | Out-File $tempCertificateFile -Append
                "-----END CERTIFICATE-----" | Out-File $tempCertificateFile -Append

                $certificatePath = $tempCertificateFile
            } else {
                $certificatePath = $EncryptCertificatePath
            }

            if ( $certificatePath -and !(Test-Path -Path $certificatePath -PathType leaf) )
            {
                throw "$($MyInvocation.MyCommand.Name): file not found: -EncryptCertificatePath $certificatePath"
            }

            if ( $JavaHome -and !(Test-Path -Path $JavaHome -PathType container) )
            {
                throw "$($MyInvocation.MyCommand.Name): directory not found: -JavaHome $JavaHome"
            }

            if ( $JavaHome -and !(Get-Command "$($JavaHome)/bin/java" -ErrorAction silentlycontinue) )
            {
                throw "$($MyInvocation.MyCommand.Name): Java binary ./bin/java not found from Java Home directory: -JavaHome $JavaHome"
            }

            if  ( $certificatePath -and !$JavaHome )
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

            if ( $certificatePath -and $JavaOptions )
            {
                [Environment]::SetEnvironmentVariable('JAVA_OPTIONS', $JavaOptions)
            }

            if ( $certificatePath -and !$JavaLib )
            {
                throw "$($MyInvocation.MyCommand.Name): parameter is required when using -EncryptCertificate or -EncryptCertificatePath arguments: -JavaLib"
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
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'objectType' -value 'JOBRESOURCE' -InputObject $body

            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/inventory/read/configuration' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $configuration = ( $response | ConvertFrom-Json ).configuration
            } else {
                $configuration = New-Object PSObject
            }

            if ( !$configuration.arguments )
            {
                Add-Member -Membertype NoteProperty -Name 'arguments' -value (New-Object PSObject) -InputObject $configuration
            }

            if ( !$configuration.env )
            {
                Add-Member -Membertype NoteProperty -Name 'env' -value (New-Object PSObject) -InputObject $configuration
            }

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
                if ( $certificatePath )
                {
                    $cmdPath = "$($env:JAVA_HOME)/bin/java"
                    $cmdArgList += @(
                        '-classpath', "$($JavaLib)/patches/*$($separator)$($JavaLib)/sos/*$($separator)$($JavaLib)/3rd-party/*$($separator)$($JavaLib)/stdout",
                        "com.sos.commons.encryption.executable.Encrypt",
                        "--cert=$($certificatePath)",
                        "--in=$($Value)" )
                    $result=(& $cmdPath $cmdArgList) | Out-String
                    # remove trailing \n\r added from Out-String, double \ do to JS7 JOC Cockpit quoting
                    $result=((($result -replace "`r`$", '') -replace "`n`$", '') -replace '\\', '\\')
                    Add-Member -Membertype NoteProperty -Name $Key -value "`"$($result)`"" -InputObject $configuration.arguments -Force
                } else {
                    if ( $AsBoolean )
                    {
                        Add-Member -Membertype NoteProperty -Name $Key -value ($Value -eq "true") -InputObject $configuration.arguments -Force
                    } elseif ( $AsNumber ) {
                        Add-Member -Membertype NoteProperty -Name $Key -value $Value -InputObject $configuration.arguments -Force
                    } else {
                        if ( isNumeric( $Value ) )
                        {
                            Add-Member -Membertype NoteProperty -Name $Key -value "`'$($Value)`'" -InputObject $configuration.arguments -Force
                        } else {
                            Add-Member -Membertype NoteProperty -Name $Key -value "`"$($Value)`"" -InputObject $configuration.arguments -Force
                        }
                    }
                }
            } elseif ( $File ) {
                if ( $certificatePath )
                {
                    $tempOutfile = New-TemporaryFile
                    $cmdPath = "$($env:JAVA_HOME)/bin/java"
                    $cmdArgList += @(
                        '-classpath', "$($JavaLib)/patches/*$($separator)$($JavaLib)/sos/*$($separator)$($JavaLib)/3rd-party/*$($separator)$($JavaLib)/stdout",
                        "com.sos.commons.encryption.executable.Encrypt",
                        "--cert=$($certificatePath)",
                        "--infile=$($File)",
                        "--outfile=$($tempOutfile)" )
                    $result=(& $cmdPath $cmdArgList) | Out-String
                    # remove trailing \n\r added from Out-String, double \ do to JS7 JOC Cockpit quoting
                    $result=((($result -replace "`r`$", '') -replace "`n`$", '') -replace '\\', '\\')
                    Add-Member -Membertype NoteProperty -Name "$($Key)_key" -value "`"$($result)`"" -InputObject $configuration.arguments -Force
                    Add-Member -Membertype NoteProperty -Name $Key -value "`"toFile( '$(Get-Content $tempOutfile -Raw)', '*.fil')`"" -InputObject $configuration.arguments -Force
                } else {
                    Add-Member -Membertype NoteProperty -Name $Key -value "`"toFile( '$(Get-Content $File -Raw)', '*.fil')`"" -InputObject $configuration.arguments -Force
                }
            }

            if ( $EnvVar )
            {
                Add-Member -Membertype NoteProperty -Name $EnvVar -value "`$$($Key)" -InputObject $configuration.env -Force

                if ( $File )
                {
                    Add-Member -Membertype NoteProperty -Name "$($EnvVar)_KEY" -value "`$$($Key)_key" -InputObject $configuration.env -Force
                }
            }

            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'objectType' -value 'JOBRESOURCE' -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'valid' -value $True -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'configuration' -value $configuration -InputObject $body

            if ( $AuditComment -or $AuditTimeSpent -or $AuditTicketLink )
            {
                $objAuditLog = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'comment' -value $AuditComment -InputObject $objAuditLog

                if ( $AuditTimeSpent )
                {
                    Add-Member -Membertype NoteProperty -Name 'timeSpent' -value $AuditTimeSpent -InputObject $objAuditLog
                }

                if ( $AuditTicketLink )
                {
                    Add-Member -Membertype NoteProperty -Name 'ticketLink' -value $AuditTicketLink -InputObject $objAuditLog
                }

                Add-Member -Membertype NoteProperty -Name 'auditLog' -value $objAuditLog -InputObject $body
            }

            if ( $PSCmdlet.ShouldProcess( 'job resource', '/inventory/store' ) )
            {
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/inventory/store' -Body $requestBody

                if ( !$response.StatusCode -eq 200 )
                {
                    throw ( $response | Format-List -Force | Out-String )
                }
            }

            if ( $tempCertificateFile -and (Test-Path -Path $tempCertificateFile -PathType leaf) )
            {
                Remove-Item -Path $tempCertificateFile -Force
            }

            if ( $tempOutfile -and (Test-Path -Path $tempOutfile -PathType leaf) )
            {
                Remove-Item -Path $tempOutfile -Force
            }
        } catch {
            if ( $tempCertificateFile -and (Test-Path -Path $tempCertificateFile -PathType leaf) )
            {
                Remove-Item -Path $tempCertificateFile -Force
            }

            if ( $tempOutfile -and (Test-Path -Path $tempOutfile -PathType leaf) )
            {
                Remove-Item -Path $tempOutfile -Force
            }

            $message = $_.Exception | Format-List -Force | Out-String
            throw "Exception occurred in line number $($_.InvocationInfo.ScriptLineNumber)`n$($message)"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
