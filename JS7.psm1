<#
.SYNOPSIS
JS7 command line interface

For further information see

    PS > about_JS7

If the documentation is not available for your language then consider to use

    PS > [System.Threading.Thread]::CurrentThread.CurrentUICulture = 'en-US'

#>

# --------------------------------
# Globals with JS7 Controller
# --------------------------------

# JS7 Controller Object
[PSObject] $js = $null

# Commands that require a local Controller instance (Management of Windows Service)
[string[]] $jsLocalCommands = @( 'Install-JS7Service', 'Remove-JS7Service', 'Start-JS7Controller' )

# -------------------------------
# Globals with JS7 Agent
# -------------------------------

# JS7 Agent Object
[PSObject] $jsAgent = $null

# Commands that require a local Agent instance (Management of Windows Service)
[string[]] $jsAgentLocalCommands = @( 'Install-JS7AgentService', 'Remove-JS7AgentService', 'Start-JS7Agent' )

# -------------------------------------
# Globals with JS7 Web Service
# -------------------------------------

# JS7 Web Service Object
[PSObject] $script:jsWebService = $null

# JS7 Web Service Request
#     Credentials
[System.Management.Automation.PSCredential] $script:jsWebServiceCredential = $null
#    Use default credentials of the current user?
[bool] $script:jsWebServiceOptionWebRequestUseDefaultCredentials = $false
#     Proxy Credentials
[System.Management.Automation.PSCredential] $script:jsWebServiceProxyCredential = $null
#    Use default credentials of the current user?
[bool] $script:jsWebServiceOptionWebRequestProxyUseDefaultCredentials = $true

# --------------------
# Globals with Options
# --------------------

# Options
#     Debug Message: responses exceeding the max. output size are stored in temporary files
[int] $script:jsOptionDebugMaxOutputSize = 1000
#    Controller Web Request: timeout for establishing the connection in ms
[int] $script:jsOptionWebRequestTimeout = 30

# ----------------------------------------------------------------------
# Public Functions
# ----------------------------------------------------------------------

$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path
"$moduleRoot\functions\*.ps1" | Resolve-Path | ForEach-Object { . $_.ProviderPath }
Export-ModuleMember -Function "*"

# ----------------------------------------------------------------------
# Public Function Alias Management
# ----------------------------------------------------------------------

function Use-JS7Alias
{
<#
.SYNOPSIS
This cmdlet creates alias names for JS7 cmdlets.

.DESCRIPTION
To create alias names this cmdlet has to be dot sourced, i.e. use

* . Use-JS7Alias -Prefix JS: works as expected
* Use-JS7Alias-Prefix JS: has no effect

When using a number of modules from different vendors then naming conflicts might occur
for cmdlets with the same name from different modules.

The JS7 CLI makes use of the following policy:

* All cmdlets use a unique qualifier for the module as e.g. Connect-JS7Controller, Get-JS7Inventory etc.
* Users can use this cmdlet to create a shorthand notation for cmdlet alias names. Two flavors are offered:
** use a shorthand notation as e.g. Use-JSController instead of Use-JS7Controller. This notation is recommended as is suggests fairly unique names.
** use a shorthand notation as e.g. Use-Controller instead of Use-JS7Controller. This notation can conflict with cmdlets of the PowerShell Core, e.g. for Start-Job, Stop-Job
* Users can exclude shorthand notation for specific cmdlets by use of an exclusion list.

You can find the resulting aliases by use of the command Get-Command -Module JS7.

.PARAMETER Prefix
Specifies the prefix that is used for a shorthand notation, e.g.

* with the parameter -Prefix "JS" used this cmdlet creates an alias Use-JSController for Use-JS7Controller
* with the parameter -Prefix being omitted this cmdlet creates an alias Use-Controller for Use-JS7Controller

By default aliases are created for both the prefix "JS" and with an empty prefix being assigned which results in the following possible notation:

* Add-JS7Order
* Add-JSOrder
* Add-Order

Default: . UseJS7Alias -Prefix JS
Default: . UseJS7Alias -NoDuplicates -ExcludesPrefix JS

.PARAMETER Excludes
Specifies a list of resulting alias names that are excluded from alias creation.

When omitting the -Prefix parameter then
- at the time of writing - the following alias names would conflict with cmdlet names from the PowerShell Core:

* Get-Event
* Get-Job
* Start-Job
* Stop-Job

.PARAMETER ExcludesPrefix
Specifies a prefix that is used should a resulting alias be a member of the list of
excluded aliases that is specified with the -Excludes parameter.

When used with the -NoDuplicates parameter then this parameter specifies the prefix that is used
for aliases that would conflict with any exsting cmdlets, functions or aliases.

.PARAMETER NoDuplicates
This parameters specifies that no alias names should be created that conflict with existing cmdlets, functions or aliases.

.EXAMPLE
 . Use-JS7Alias -Prefix JS

Creates aliases for all JS7 CLI cmdlets that allow to use, e.g. Add-JSOrder for Add-JS7Order

.EXAMPLE
 . Use-JS7Alias -Exclude Get-Job,Start-Job,Stop-Job -ExcludePrefix JS

Creates aliases for all JS7 CLI cmdlets that allow to use, e.g. Add-Order for Add-JS7Order.
This is specified by omitting the -Prefix parameter.

For the resulting alias names Get-Job, Start-Job and Stop-Job the alias names
Get-JSJob, Start-JSJob and Stop-JSJob are created by use of the -ExcludePrefix "JS" parameter.

.EXAMPLE
 . Use-JS7Alias -NoDuplicates -ExcludesPrefix JS

Creates aliases for all JS7 CLI cmdlets that allow to use e.g. Add-Order for Add-JS7Order.
Should any alias name conflict with an existing cmdlet, function or alias then the alias will be created with the
prefix specified by the -ExcludesPrefix parameter.

The JS7 CLI module uses this alias setting by defalt.
.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Prefix,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Excludes,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ExcludesPrefix,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NoDuplicates
)
    Process
    {
        if ( $NoDuplicates )
        {
            $allCommands = Get-Command | Select-Object -Property Name | ForEach-Object { $_.Name }
        }

        $commands = Get-Command -Module JS7 -CommandType 'Function'
        foreach( $command in $commands )
        {
            $aliasName = $command.name.Replace( '-JS7', "-$($Prefix)" )

            if ( $Excludes -contains $aliasName )
            {
                continue
            }

            if ( $Excludes -contains $aliasName )
            {
                if ( $ExcludesPrefix )
                {
                    $aliasName = $command.name.Replace( '-JS7', "-$($ExcludesPrefix)" )
                } else {
                    continue
                }
            }

            if ( $NoDuplicates )
            {
                if ( $allCommands -contains $aliasName )
                {
                    if ( $ExcludesPrefix )
                    {
                        $aliasName = $command.name.Replace( '-JS7', "-$($ExcludesPrefix)" )
                    } else {
                        continue
                    }
                }
            }

            Set-Alias -Name $aliasName -Value $command.Name
        }

        Export-ModuleMember -Alias "*"
    }
}

# create alias names to shorten 'JS7' to 'JS'
. Use-JS7Alias -Prefix JS -Excludes 'Connect-','Disconnect-','Use-JSAlias','Use-Alias'
# create alias names that drop 'JS7' in the name but avoid conflicts with existing alias names
. Use-JS7Alias -NoDuplicates -ExcludesPrefix JS -Excludes 'Connect-','Disconnect-','Use-JSAlias','Use-Alias'

# ----------------------------------------------------------------------
# Private Functions
# ----------------------------------------------------------------------

function Approve-JS7Command( [System.Management.Automation.CommandInfo] $Command )
{
    if ( !$script:jsWebServiceCredential )
    {
        throw "$($Command.Name): no valid session, login to the JS7 Web Service with the Connect-JS7 cmdlet"
    }

    if ( !$script:js.Local )
    {
        if ( $script:jsLocalCommands -contains $Command.Name )
        {
            throw "$($Command.Name): cmdlet is available exclusively for local JS7 Controller. Switch instance with the Connect-JS7 cmdlet and specify the -Id or -InstallPath parameter for a local JS7 Controller"
        }
    }

    if ( !$script:js.Url -and !$script:jsOperations -and !$script:jsWebService.ControllerId )
    {
        if ( $script:jsLocalCommands -notcontains $Command.Name )
        {
            throw "$($Command.Name): cmdlet requires a JS7 Controller ID. Switch instance with the Connect-JS7 cmdlet and specify the -Url parameter"
        }
    }
}

function Approve-JS7AgentCommand( [System.Management.Automation.CommandInfo] $Command )
{
    if ( !$script:jsAgent.Local )
    {
        if ( $script:jsAgentLocalCommands -contains $Command.Name )
        {
            throw "$($command.Name): cmdlet is available exclusively for local JS7 Agent. Switch instance with the Use-JS7Agent cmdlet and specify the -InstallPath parameter for a local JS7 Agent"
        }
    }

    if ( !$script:jsAgent.Url -and !$script:jsOperations )
    {
        if ( $script:jsAgentLocalCommands -notcontains $Command.Name )
        {
            throw "$($command.Name): cmdlet requires a JS7 Agent URL. Switch instance with the Use-JS7Agent cmdlet and specify the -Url parameter"
        }
    }
}

function Start-JS7StopWatch
{
[cmdletbinding(SupportsShouldProcess)]
[OutputType([System.Diagnostics.Stopwatch])]
param
()

    if ( $PSCmdlet.ShouldProcess( 'Stopwatch' ) )
    {
        [System.Diagnostics.Stopwatch]::StartNew()
    }
}

function Trace-JS7StopWatch( [string] $CommandName, [System.Diagnostics.Stopwatch] $StopWatch )
{
    if ( $StopWatch )
    {
        Write-Verbose ".. $($CommandName): time elapsed: $($StopWatch.Elapsed.TotalMilliseconds) ms"
    }
}

function New-JS7WebServiceObject
{
[cmdletbinding(SupportsShouldProcess)]
param
()

    if ( $PSCmdlet.ShouldProcess( 'jsWebService' ) )
    {
        $jsWebService = New-Object PSObject

        $jsWebService | Add-Member -Membertype NoteProperty -Name JOCVersion -Value ''
        $jsWebService | Add-Member -Membertype NoteProperty -Name ControllerVersion -Value ''
        $jsWebService | Add-Member -Membertype NoteProperty -Name Url -Value ''
        $jsWebService | Add-Member -Membertype NoteProperty -Name ProxyUrl -Value ''
        $jsWebService | Add-Member -Membertype NoteProperty -Name Base -Value ''
        $jsWebService | Add-Member -Membertype NoteProperty -Name Timeout -Value $script:jsOptionWebRequestTimeout
        $jsWebService | Add-Member -Membertype NoteProperty -Name SkipCertificateCheck -Value $false

        if ( isPowerShellVersion 7 )
        {
            $jsWebService | Add-Member -Membertype NoteProperty -Name SSLProtocol -Value 'Tls12'
        } else {
            $jsWebService | Add-Member -Membertype NoteProperty -Name SSLProtocol -Value ''
        }

        $jsWebService | Add-Member -Membertype NoteProperty -Name Certificate -Value ''
        $jsWebService | Add-Member -Membertype NoteProperty -Name ControllerId -Value ''
        $jsWebService | Add-Member -Membertype NoteProperty -Name AccessToken -Value ''
        $jsWebService | Add-Member -Membertype NoteProperty -Name ControllerInstances -Value @()

        $jsWebService
    }
}

function Get-JS7JOCVersion()
{
    $jsWebService.JOCVersion
}

function IsJOCVersion( [int] $Major=-1, [int] $Minor=-1, [int] $Patch=-1 )
{
    $rc = $false
    $versionParts = $jsWebService.JOCVersion.Split('.')
    if ( $versionParts.count -eq 3 )
    {
        $versionParts[2] = $versionParts[2].Split('-')
    }

    if ( $Major -gt -1 )
    {
        if ( $versionParts[0] -eq $Major )
        {
            if ( $Minor -gt -1 )
            {
                if ( $versionParts[1] -eq $Minor )
                {
                    if ( $Patch -gt - 1 )
                    {
                        if ( $versionParts[2] -ge $Patch )
                        {
                            $rc = $true
                        }
                    } else {
                        $rc = $true
                    }
                } elseif ( $versionParts[1] -gt $Minor ) {
                    $rc = $true
                } else {
                    $rc = $true
                }
            } else {
                $rc = $true
            }
        } elseif ( $versionParts[0] -gt $Major ) {
            $rc = $true
        }
    }

    $rc
}

function IsPowerShellVersion( [int] $Major=-1, [int] $Minor=-1, [int] $Patch=-1 )
{
    $rc = $false

    if ( $Major -gt -1 )
    {
        if ( $PSVersionTable.PSVersion.Major -eq $Major )
        {
            if ( $Minor -gt -1 )
            {
                if ( $PSVersionTable.PSVersion.Minor -eq $Minor )
                {
                    if ( $Patch -gt - 1 )
                    {
                        if ( $PSVersionTable.PSVersion.Patch -ge $Patch )
                        {
                            $rc = $true
                        }
                    } else {
                        $rc = $true
                    }
                } elseif ( $PSVersionTable.PSVersion.Minor -gt $Minor ) {
                    $rc = $true
                } else {
                    $rc = $true
                }
            } else {
                $rc = $true
            }
        } elseif ( $PSVersionTable.PSVersion.Major -gt $Major ) {
            $rc = $true
        }
    }

    $rc
}

function IsNumeric( $arg )
{
    try {
        [int]$arg
        return $True
    } catch {
        return $False
    }
}

function Update-JS7Session
{
[cmdletbinding(SupportsShouldProcess)]
param
()

    if ( $script:jsWebService.ControllerId )
    {
        if ( $PSCmdlet.ShouldProcess( 'session' ) )
        {
            Invoke-JS7WebRequest -Path '/touch' | Out-Null
        }
    }
}

function Invoke-JS7WebRequest( [string] $Path, [object] $Body, [string] $Method='POST', [string] $ContentType='application/json; charset=utf-8', [hashtable] $Headers=@{'Accept' = 'application/json'}, [string] $InFile, [string] $OutFile, [int] $Timeout, [boolean] $Verbose )
{
    if ( $script:jsWebService.Url.UserInfo )
    {
        $requestUrl = $script:jsWebService.Url.scheme + '://' + $script:jsWebService.Url.UserInfo + '@' + $script:jsWebService.Url.Authority + $script:jsWebService.Base + $Path
    } else {
        $requestUrl = $script:jsWebService.Url.scheme + '://' + $script:jsWebService.Url.Authority + $script:jsWebService.Base + $Path
    }

    $requestParams = @{}
    $requestParams.Add( 'Verbose', $Verbose )
    $requestParams.Add( 'Uri', $requestUrl )
    $requestParams.Add( 'Method', $Method )

    if ( $ContentType )
    {
        $requestParams.Add( 'ContentType', $ContentType )
    }

    if ( $ContentType -and !$Headers.Item( 'Content-Type' ) )
    {
        $Headers.Add( 'Content-Type', $ContentType )
    }

    $Headers.Add( 'X-Access-Token', $script:jsWebService.AccessToken )
    $requestParams.Add( 'Headers', $Headers )

    if ( isPowerShellVersion 5 )
    {
        $requestParams.Add( 'UseBasicParsing', $true )
    }

    if ( isPowerShellVersion 6 )
    {
        $requestParams.Add( 'AllowUnencryptedAuthentication', $true )
    }

    if ( isPowerShellVersion 7 )
    {
        $requestParams.Add( 'SkipHttpErrorCheck', $true )
    }

    if ( $Timeout )
    {
        $requestParams.Add( 'TimeoutSec', $Timeout )
    } elseif ( $script:jsWebService.Timeout ) {
        $requestParams.Add( 'TimeoutSec', $script:jsWebService.Timeout )
    }

    if ( $script:jsWebService.SkipCertificateCheck )
    {
        $requestParams.Add( 'SkipCertificateCheck', $true )
    }

    if ( $script:jsWebService.SSLProtocol )
    {
        $requestParams.Add( 'SSLProtocol', $script:jsWebService.SSLProtocol )
    }

   if ( $script:jsWebService.Certificate )
   {
       $requestParams.Add( 'Certificate', $script:jsWebService.Certificate )
   }

    if ( $Body )
    {
        $requestParams.Add( 'Body', $Body )
    }

    if ( $InFile )
    {
        $requestParams.Add( 'InFile', $InFile )
    }

    if ( $OutFile )
    {
        $requestParams.Add( 'OutFile', $OutFile )
    }

    try
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): sending request to JS7 Web Service $($requestUrl)"
        Write-Debug ".... Invoke-WebRequest:"

        $requestParams.Keys | ForEach-Object {
            if ( $_ -eq 'Headers' )
            {
                $item = $_
                $requestParams.Item($_).Keys | ForEach-Object {
                    Write-Debug "...... Header: $_ : $($requestParams.Item($item).Item($_))"
                }
            } else {
                if ( $_ -ne 'Certificate' )
                {
                    Write-Debug "...... Argument: $_  $($requestParams.Item($_))"
                }
            }
        }

        if ( isPowerShellVersion 7 )
        {
            $response = Invoke-WebRequest @requestParams
        } else {
            try
            {
                $response = Invoke-WebRequest @requestParams
            } catch {
                $response = $_.Exception.Response
            }
        }

        if ( $OutFile )
        {
            $response
        } else {
            if ( $response -and $response.StatusCode -and $response.Content  )
            {
                $response
            } elseif ( $response -and !(isPowerShellVersion 7) ) {
                $response
            } else {
                $message = $response | Format-List -Force | Out-String
                throw $message
            }
        }
    } catch {
        $message = $_.Exception | Format-List -Force | Out-String
        throw $message
    }
}

# return the basename of an object
function Get-JS7Object-Basename( [string] $objectPath )
{
    if ( $objectPath.LastIndexOf('/') -ge 0 )
    {
        $objectPath = $objectPath.Substring( $objectPath.LastIndexOf('/')+1 )
    }

    $objectPath
}

# return the parent folder of an object
function Get-JS7Object-Parent( [string] $objectPath )
{
    if ( $objectPath.LastIndexOf('/') -ge 0 )
    {
        $objectPath.Substring( 0, $objectPath.LastIndexOf('/') )
    }
}

# return the canonical path of an object, i.e. the full path
function Get-JS7Object-CanonicalPath( [string] $objectPath )
{
    if ( $objectPath.LastIndexOf('/') -ge 0 )
    {
        $objectPath = $objectPath.Substring( 0, $objectPath.LastIndexOf('/') )
    }

    $objectPath
}

function Get-JS7ConfigurationMerge( [PSCustomObject] $changeItems, [PSCustomObject] $dependencies )
{
    $configurations = @()

    foreach( $changeItem in $changeItems )
    {
        foreach( $changeConfiguration in $changeItem.configurations )
        {
            $configuration = New-Object PSObject
            $configurationItem = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $changeConfiguration.path -InputObject $configurationItem
            Add-Member -Membertype NoteProperty -Name 'objectType' -value $changeConfiguration.ObjectType -InputObject $configurationItem
            Add-Member -Membertype NoteProperty -Name 'configuration' -value $configurationItem -InputObject $configuration

            $configurations += $configuration
        }
    }

    foreach( $dependency in $dependencies )
    {
        $configuration = New-Object PSObject
        $configurationItem = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'path' -value $dependency.path -InputObject $configurationItem
        Add-Member -Membertype NoteProperty -Name 'objectType' -value $dependency.objectType -InputObject $configurationItem
        Add-Member -Membertype NoteProperty -Name 'configuration' -value $configurationItem -InputObject $configuration

        if ( $configuration.configuration.path -notin $configurations.configuration.path -or $configuration.configuration.objectType -notin $configurations.configuration.objectType )
        {
            $configurations += $configuration
        }
    }

    $configurations
}

# ----------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------

$script:jsWebService = New-JS7WebServiceObject

# SIG # Begin signature block
# MIIs0AYJKoZIhvcNAQcCoIIswTCCLL0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCyENf8zk3jUHnq
# ozxIsVD6kIQLmB8Q7iscObIOCYd9SqCCJd8wggVvMIIEV6ADAgECAhBI/JO0YFWU
# jTanyYqJ1pQWMA0GCSqGSIb3DQEBDAUAMHsxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# DBJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcMB1NhbGZvcmQxGjAYBgNVBAoM
# EUNvbW9kbyBDQSBMaW1pdGVkMSEwHwYDVQQDDBhBQUEgQ2VydGlmaWNhdGUgU2Vy
# dmljZXMwHhcNMjEwNTI1MDAwMDAwWhcNMjgxMjMxMjM1OTU5WjBWMQswCQYDVQQG
# EwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS0wKwYDVQQDEyRTZWN0aWdv
# IFB1YmxpYyBDb2RlIFNpZ25pbmcgUm9vdCBSNDYwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCN55QSIgQkdC7/FiMCkoq2rjaFrEfUI5ErPtx94jGgUW+s
# hJHjUoq14pbe0IdjJImK/+8Skzt9u7aKvb0Ffyeba2XTpQxpsbxJOZrxbW6q5KCD
# J9qaDStQ6Utbs7hkNqR+Sj2pcaths3OzPAsM79szV+W+NDfjlxtd/R8SPYIDdub7
# P2bSlDFp+m2zNKzBenjcklDyZMeqLQSrw2rq4C+np9xu1+j/2iGrQL+57g2extme
# me/G3h+pDHazJyCh1rr9gOcB0u/rgimVcI3/uxXP/tEPNqIuTzKQdEZrRzUTdwUz
# T2MuuC3hv2WnBGsY2HH6zAjybYmZELGt2z4s5KoYsMYHAXVn3m3pY2MeNn9pib6q
# RT5uWl+PoVvLnTCGMOgDs0DGDQ84zWeoU4j6uDBl+m/H5x2xg3RpPqzEaDux5mcz
# mrYI4IAFSEDu9oJkRqj1c7AGlfJsZZ+/VVscnFcax3hGfHCqlBuCF6yH6bbJDoEc
# QNYWFyn8XJwYK+pF9e+91WdPKF4F7pBMeufG9ND8+s0+MkYTIDaKBOq3qgdGnA2T
# OglmmVhcKaO5DKYwODzQRjY1fJy67sPV+Qp2+n4FG0DKkjXp1XrRtX8ArqmQqsV/
# AZwQsRb8zG4Y3G9i/qZQp7h7uJ0VP/4gDHXIIloTlRmQAOka1cKG8eOO7F/05QID
# AQABo4IBEjCCAQ4wHwYDVR0jBBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYD
# VR0OBBYEFDLrkpr/NZZILyhAQnAgNpFcF4XmMA4GA1UdDwEB/wQEAwIBhjAPBgNV
# HRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsGA1UdIAQUMBIwBgYE
# VR0gADAIBgZngQwBBAEwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC5jb21v
# ZG9jYS5jb20vQUFBQ2VydGlmaWNhdGVTZXJ2aWNlcy5jcmwwNAYIKwYBBQUHAQEE
# KDAmMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9jYS5jb20wDQYJKoZI
# hvcNAQEMBQADggEBABK/oe+LdJqYRLhpRrWrJAoMpIpnuDqBv0WKfVIHqI0fTiGF
# OaNrXi0ghr8QuK55O1PNtPvYRL4G2VxjZ9RAFodEhnIq1jIV9RKDwvnhXRFAZ/ZC
# J3LFI+ICOBpMIOLbAffNRk8monxmwFE2tokCVMf8WPtsAO7+mKYulaEMUykfb9gZ
# pk+e96wJ6l2CxouvgKe9gUhShDHaMuwV5KZMPWw5c9QLhTkg4IUaaOGnSDip0TYl
# d8GNGRbFiExmfS9jzpjoad+sPKhdnckcW67Y8y90z7h+9teDnRGWYpquRRPaf9xH
# +9/DUp/mBlXpnYzyOmJRvOwkDynUWICE5EV7WtgwggWNMIIEdaADAgECAhAOmxiO
# +dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAi
# BgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAw
# MDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERp
# Z2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCC
# AgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsb
# hA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iT
# cMKyunWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGb
# NOsFxl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclP
# XuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCr
# VYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFP
# ObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTv
# kpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWM
# cCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls
# 5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBR
# a2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6
# MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qY
# rhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8E
# BAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDig
# NoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCg
# v0NcVec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQT
# SnovLbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh
# 65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSw
# uKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAO
# QGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjD
# TZ9ztwGpn1eqXijiuZQwggYcMIIEBKADAgECAhAz1wiokUBTGeKlu9M5ua1uMA0G
# CSqGSIb3DQEBDAUAMFYxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExp
# bWl0ZWQxLTArBgNVBAMTJFNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBSb290
# IFI0NjAeFw0yMTAzMjIwMDAwMDBaFw0zNjAzMjEyMzU5NTlaMFcxCzAJBgNVBAYT
# AkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNlY3RpZ28g
# UHVibGljIENvZGUgU2lnbmluZyBDQSBFViBSMzYwggGiMA0GCSqGSIb3DQEBAQUA
# A4IBjwAwggGKAoIBgQC70f4et0JbePWQp64sg/GNIdMwhoV739PN2RZLrIXFuwHP
# 4owoEXIEdiyBxasSekBKxRDogRQ5G19PB/YwMDB/NSXlwHM9QAmU6Kj46zkLVdW2
# DIseJ/jePiLBv+9l7nPuZd0o3bsffZsyf7eZVReqskmoPBBqOsMhspmoQ9c7gqgZ
# YbU+alpduLyeE9AKnvVbj2k4aOqlH1vKI+4L7bzQHkNDbrBTjMJzKkQxbr6PuMYC
# 9ruCBBV5DFIg6JgncWHvL+T4AvszWbX0w1Xn3/YIIq620QlZ7AGfc4m3Q0/V8tm9
# VlkJ3bcX9sR0gLqHRqwG29sEDdVOuu6MCTQZlRvmcBMEJd+PuNeEM4xspgzraLqV
# T3xE6NRpjSV5wyHxNXf4T7YSVZXQVugYAtXueciGoWnxG06UE2oHYvDQa5mll1Ce
# HDOhHu5hiwVoHI717iaQg9b+cYWnmvINFD42tRKtd3V6zOdGNmqQU8vGlHHeBzoh
# +dYyZ+CcblSGoGSgg8sCAwEAAaOCAWMwggFfMB8GA1UdIwQYMBaAFDLrkpr/NZZI
# LyhAQnAgNpFcF4XmMB0GA1UdDgQWBBSBMpJBKyjNRsjEosYqORLsSKk/FDAOBgNV
# HQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADATBgNVHSUEDDAKBggrBgEF
# BQcDAzAaBgNVHSAEEzARMAYGBFUdIAAwBwYFZ4EMAQMwSwYDVR0fBEQwQjBAoD6g
# PIY6aHR0cDovL2NybC5zZWN0aWdvLmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25p
# bmdSb290UjQ2LmNybDB7BggrBgEFBQcBAQRvMG0wRgYIKwYBBQUHMAKGOmh0dHA6
# Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1YmxpY0NvZGVTaWduaW5nUm9vdFI0
# Ni5wN2MwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqG
# SIb3DQEBDAUAA4ICAQBfNqz7+fZyWhS38Asd3tj9lwHS/QHumS2G6Pa38Dn/1oFK
# WqdCSgotFZ3mlP3FaUqy10vxFhJM9r6QZmWLLXTUqwj3ahEDCHd8vmnhsNufJIkD
# 1t5cpOCy1rTP4zjVuW3MJ9bOZBHoEHJ20/ng6SyJ6UnTs5eWBgrh9grIQZqRXYHY
# NneYyoBBl6j4kT9jn6rNVFRLgOr1F2bTlHH9nv1HMePpGoYd074g0j+xUl+yk72M
# lQmYco+VAfSYQ6VK+xQmqp02v3Kw/Ny9hA3s7TSoXpUrOBZjBXXZ9jEuFWvilLIq
# 0nQ1tZiao/74Ky+2F0snbFrmuXZe2obdq2TWauqDGIgbMYL1iLOUJcAhLwhpAuNM
# u0wqETDrgXkG4UGVKtQg9guT5Hx2DJ0dJmtfhAH2KpnNr97H8OQYok6bLyoMZqaS
# dSa+2UA1E2+upjcaeuitHFFjBypWBmztfhj24+xkc6ZtCDaLrw+ZrnVrFyvCTWrD
# UUZBVumPwo3/E3Gb2u2e05+r5UWmEsUUWlJBl6MGAAjF5hzqJ4I8O9vmRsTvLQA1
# E802fZ3lqicIBczOwDYOSxlP0GOabb/FKVMxItt1UHeG0PL4au5rBhs+hSMrl8h+
# eplBDN1Yfw6owxI9OjWb4J0sjBeBVESoeh2YnZZ/WVimVGX/UUIL+Efrz/jlvzCC
# BrQwggScoAMCAQICEA3HrFcF/yGZLkBDIgw6SYYwDQYJKoZIhvcNAQELBQAwYjEL
# MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3
# LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0
# MB4XDTI1MDUwNzAwMDAwMFoXDTM4MDExNDIzNTk1OVowaTELMAkGA1UEBhMCVVMx
# FzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMUEwPwYDVQQDEzhEaWdpQ2VydCBUcnVz
# dGVkIEc0IFRpbWVTdGFtcGluZyBSU0E0MDk2IFNIQTI1NiAyMDI1IENBMTCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALR4MdMKmEFyvjxGwBysddujRmh0
# tFEXnU2tjQ2UtZmWgyxU7UNqEY81FzJsQqr5G7A6c+Gh/qm8Xi4aPCOo2N8S9SLr
# C6Kbltqn7SWCWgzbNfiR+2fkHUiljNOqnIVD/gG3SYDEAd4dg2dDGpeZGKe+42DF
# UF0mR/vtLa4+gKPsYfwEu7EEbkC9+0F2w4QJLVSTEG8yAR2CQWIM1iI5PHg62IVw
# xKSpO0XaF9DPfNBKS7Zazch8NF5vp7eaZ2CVNxpqumzTCNSOxm+SAWSuIr21Qomb
# +zzQWKhxKTVVgtmUPAW35xUUFREmDrMxSNlr/NsJyUXzdtFUUt4aS4CEeIY8y9Ia
# aGBpPNXKFifinT7zL2gdFpBP9qh8SdLnEut/GcalNeJQ55IuwnKCgs+nrpuQNfVm
# UB5KlCX3ZA4x5HHKS+rqBvKWxdCyQEEGcbLe1b8Aw4wJkhU1JrPsFfxW1gaou30y
# Z46t4Y9F20HHfIY4/6vHespYMQmUiote8ladjS/nJ0+k6MvqzfpzPDOy5y6gqzti
# T96Fv/9bH7mQyogxG9QEPHrPV6/7umw052AkyiLA6tQbZl1KhBtTasySkuJDpsZG
# Kdlsjg4u70EwgWbVRSX1Wd4+zoFpp4Ra+MlKM2baoD6x0VR4RjSpWM8o5a6D8bpf
# m4CLKczsG7ZrIGNTAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0G
# A1UdDgQWBBTvb1NK6eQGfHrK4pBW9i/USezLTjAfBgNVHSMEGDAWgBTs1+OC0nFd
# ZEzfLmc/57qYrhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUH
# AwgwdwYIKwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0
# dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3Js
# MCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsF
# AAOCAgEAF877FoAc/gc9EXZxML2+C8i1NKZ/zdCHxYgaMH9Pw5tcBnPw6O6FTGNp
# oV2V4wzSUGvI9NAzaoQk97frPBtIj+ZLzdp+yXdhOP4hCFATuNT+ReOPK0mCefSG
# +tXqGpYZ3essBS3q8nL2UwM+NMvEuBd/2vmdYxDCvwzJv2sRUoKEfJ+nN57mQfQX
# wcAEGCvRR2qKtntujB71WPYAgwPyWLKu6RnaID/B0ba2H3LUiwDRAXx1Neq9ydOa
# l95CHfmTnM4I+ZI2rVQfjXQA1WSjjf4J2a7jLzWGNqNX+DF0SQzHU0pTi4dBwp9n
# EC8EAqoxW6q17r0z0noDjs6+BFo+z7bKSBwZXTRNivYuve3L2oiKNqetRHdqfMTC
# W/NmKLJ9M+MtucVGyOxiDf06VXxyKkOirv6o02OoXN4bFzK0vlNMsvhlqgF2puE6
# FndlENSmE+9JGYxOGLS/D284NHNboDGcmWXfwXRy4kbu4QFhOm0xJuF2EZAOk5eC
# khSxZON3rGlHqhpB/8MluDezooIs8CVnrpHMiD2wL40mm53+/j7tFaxYKIqL0Q4s
# sd8xHZnIn/7GELH3IdvG2XlM9q7WP/UwgOkw/HQtyRN62JK4S1C8uw3PdBunvAZa
# psiI5YKdvlarEvf8EA+8hcpSM9LHJmyrxaFtoza2zNaQ9k+5t1wwggbtMIIE1aAD
# AgECAhAKgO8YS43xBYLRxHanlXRoMA0GCSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYT
# AlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQg
# VHJ1c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNBNDA5NiBTSEEyNTYgMjAyNSBDQTEw
# HhcNMjUwNjA0MDAwMDAwWhcNMzYwOTAzMjM1OTU5WjBjMQswCQYDVQQGEwJVUzEX
# MBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFNIQTI1
# NiBSU0E0MDk2IFRpbWVzdGFtcCBSZXNwb25kZXIgMjAyNSAxMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEA0EasLRLGntDqrmBWsytXum9R/4ZwCgHfyjfM
# GUIwYzKomd8U1nH7C8Dr0cVMF3BsfAFI54um8+dnxk36+jx0Tb+k+87H9WPxNyFP
# JIDZHhAqlUPt281mHrBbZHqRK71Em3/hCGC5KyyneqiZ7syvFXJ9A72wzHpkBaMU
# Ng7MOLxI6E9RaUueHTQKWXymOtRwJXcrcTTPPT2V1D/+cFllESviH8YjoPFvZSjK
# s3SKO1QNUdFd2adw44wDcKgH+JRJE5Qg0NP3yiSyi5MxgU6cehGHr7zou1znOM8o
# dbkqoK+lJ25LCHBSai25CFyD23DZgPfDrJJJK77epTwMP6eKA0kWa3osAe8fcpK4
# 0uhktzUd/Yk0xUvhDU6lvJukx7jphx40DQt82yepyekl4i0r8OEps/FNO4ahfvAk
# 12hE5FVs9HVVWcO5J4dVmVzix4A77p3awLbr89A90/nWGjXMGn7FQhmSlIUDy9Z2
# hSgctaepZTd0ILIUbWuhKuAeNIeWrzHKYueMJtItnj2Q+aTyLLKLM0MheP/9w6Ct
# juuVHJOVoIJ/DtpJRE7Ce7vMRHoRon4CWIvuiNN1Lk9Y+xZ66lazs2kKFSTnnkrT
# 3pXWETTJkhd76CIDBbTRofOsNyEhzZtCGmnQigpFHti58CSmvEyJcAlDVcKacJ+A
# 9/z7eacCAwEAAaOCAZUwggGRMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFOQ7/PIx
# 7f391/ORcWMZUEPPYYzoMB8GA1UdIwQYMBaAFO9vU0rp5AZ8esrikFb2L9RJ7MtO
# MA4GA1UdDwEB/wQEAwIHgDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDCBlQYIKwYB
# BQUHAQEEgYgwgYUwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNv
# bTBdBggrBgEFBQcwAoZRaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0VHJ1c3RlZEc0VGltZVN0YW1waW5nUlNBNDA5NlNIQTI1NjIwMjVDQTEuY3J0
# MF8GA1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydFRydXN0ZWRHNFRpbWVTdGFtcGluZ1JTQTQwOTZTSEEyNTYyMDI1Q0ExLmNy
# bDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcNAQEL
# BQADggIBAGUqrfEcJwS5rmBB7NEIRJ5jQHIh+OT2Ik/bNYulCrVvhREafBYF0RkP
# 2AGr181o2YWPoSHz9iZEN/FPsLSTwVQWo2H62yGBvg7ouCODwrx6ULj6hYKqdT8w
# v2UV+Kbz/3ImZlJ7YXwBD9R0oU62PtgxOao872bOySCILdBghQ/ZLcdC8cbUUO75
# ZSpbh1oipOhcUT8lD8QAGB9lctZTTOJM3pHfKBAEcxQFoHlt2s9sXoxFizTeHihs
# QyfFg5fxUFEp7W42fNBVN4ueLaceRf9Cq9ec1v5iQMWTFQa0xNqItH3CPFTG7aEQ
# JmmrJTV3Qhtfparz+BW60OiMEgV5GWoBy4RVPRwqxv7Mk0Sy4QHs7v9y69NBqycz
# 0BZwhB9WOfOu/CIJnzkQTwtSSpGGhLdjnQ4eBpjtP+XB3pQCtv4E5UCSDag6+iX8
# MmB10nfldPF9SVD7weCC3yXZi/uuhqdwkgVxuiMFzGVFwYbQsiGnoa9F5AaAyBjF
# BtXVLcKtapnMG3VH3EmAp/jsJ3FVF3+d1SVDTmjFjLbNFZUWMXuZyvgLfgyPehwJ
# VxwC+UpX2MSey2ueIu9THFVkT+um1vshETaWyQo8gmBto/m3acaP9QsuLj3FNwFl
# Txq25+T4QwX9xa6ILs84ZPvmpovq90K8eWyG2N01c4IhSOxqt81nMIIHDjCCBXag
# AwIBAgIQSw+NgvCzdrKXturaTqbU7DANBgkqhkiG9w0BAQsFADBXMQswCQYDVQQG
# EwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdv
# IFB1YmxpYyBDb2RlIFNpZ25pbmcgQ0EgRVYgUjM2MB4XDTIzMDUzMDAwMDAwMFoX
# DTI2MDUyOTIzNTk1OVowgdQxEjAQBgNVBAUTCUhSQiAyMTAxNTETMBEGCysGAQQB
# gjc8AgEDEwJERTEdMBsGA1UEDxMUUHJpdmF0ZSBPcmdhbml6YXRpb24xCzAJBgNV
# BAYTAkRFMQ8wDQYDVQQIDAZCZXJsaW4xNTAzBgNVBAoMLFNPUyBTb2Z0d2FyZS0g
# dW5kIE9yZ2FuaXNhdGlvbnMtU2VydmljZSBHbWJIMTUwMwYDVQQDDCxTT1MgU29m
# dHdhcmUtIHVuZCBPcmdhbmlzYXRpb25zLVNlcnZpY2UgR21iSDCCAiIwDQYJKoZI
# hvcNAQEBBQADggIPADCCAgoCggIBAL5t1usDS85Xcw3cIgVDvb43V9y9hiRn8cWn
# pnYrW8KcS58120n0rRCXPW8sFJvm4Uqf1xs1sXkmyBrdd0p/RBaKTkWtuScbsAPM
# UxDsSzPwhJYD/2jfv65ebB82qSURfO4ne8iF75WccYrgD2b6ZE3Px1ks/yH2zTw7
# VjSYZgjpYhiUd215hTxwww35a32OS/f79sMi1ERC8qcVQYudwGm2brYgGuNC0qqL
# 1Z3W2EPKkH3VvUFUSQxdIQzEPMZrt9ZAepizAlyv/UZuxdmIr9DTL4OId6od5Ffp
# Cx8xHGiDHgULvlbQj7zBJ/GoUUcPNG5Ye1dn/Tl9xkcmJ9A0H4zGXRo6Zo+D9MZX
# avBntj1ZvqwlCXiUkFGLDtay4TMgQKDJfs+qocFrsYeXCWiWqw0Ly1qYsa4rAPgC
# TSVJ4j8l06/nWU0r57dvXRt9AuuikbJBSlg7gc462gK95FFkACeZEuhtSkrsnW8Y
# FpPfTI7fomhyyg5bHiRKlyHq3Hgr7C88PjTmLAOQDhHQs/jgi3aMEDNHrTcFoHBl
# YmQbsnU9zr0PMOUJXSRF1PsIe2vvvw9rpfvuLobUN21g1spNuEil+jrKgxYHKxcV
# qvlSVn5SISqhQPYRGbLeZPIB2ZMl5w+z5Wwg6HqrdrD1MomSkPwWNxEjjSg3Ph2W
# izBtgEY3AgMBAAGjggHWMIIB0jAfBgNVHSMEGDAWgBSBMpJBKyjNRsjEosYqORLs
# SKk/FDAdBgNVHQ4EFgQURHB21fi7IRRpsoiNNppx0kxQ2YIwDgYDVR0PAQH/BAQD
# AgeAMAwGA1UdEwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwSQYDVR0gBEIw
# QDA1BgwrBgEEAbIxAQIBBgEwJTAjBggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0aWdv
# LmNvbS9DUFMwBwYFZ4EMAQMwSwYDVR0fBEQwQjBAoD6gPIY6aHR0cDovL2NybC5z
# ZWN0aWdvLmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdDQUVWUjM2LmNybDB7
# BggrBgEFBQcBAQRvMG0wRgYIKwYBBQUHMAKGOmh0dHA6Ly9jcnQuc2VjdGlnby5j
# b20vU2VjdGlnb1B1YmxpY0NvZGVTaWduaW5nQ0FFVlIzNi5jcnQwIwYIKwYBBQUH
# MAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMEgGA1UdEQRBMD+gHAYIKwYBBQUH
# CAOgEDAODAxERS1IUkIgMjEwMTWBH2FuZHJlYXMucHVlc2NoZWxAc29zLWJlcmxp
# bi5jb20wDQYJKoZIhvcNAQELBQADggGBAGQVsECtVc3Unom81ITXzXk3s9N6nMrs
# yxIXBTtFpa1Kq/oRZjhL3YuHZmA3kSpi8NjO0TvpI17KE/lEB8tm8qxLAOTCQ7l2
# CskAbcz5LIFKDbz+fm694GaeAp82KaxE45/V+esji36D8VKtywDABarTZADXxpIf
# Q5+9sLNy0dzpCwUcUrw0UArob6Nrom8F6nS9fcBoD8hLx/WIwZyhpKYGmKtEhpF7
# lsK7IxU2/t9N53NzfJ+vmSuMRKdZu1uoANx9PXkWolihmfR/J82HoYLM7okZGbhM
# zT3x6DOn0tir+mCOIcgk8iMA1nxkucPiWBHYYn3LxP8afogSk11Hxk5m9ZHvdrqs
# HZU30lf7ERzm7zCjaExsdT/1GtUJlNytDrJQyK0JtiP3CxxuZrGh8bFONRTpDHkr
# ff1ag/XGPZR+yLCWgqmO3JgoPLRAkPlIIJEka+4MDuRo36OzTrTkSKAYm4uGA9xa
# cldGojre4aXgSKndSSBFrQ9RqVAOwOqqgzGCBkcwggZDAgEBMGswVzELMAkGA1UE
# BhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEuMCwGA1UEAxMlU2VjdGln
# byBQdWJsaWMgQ29kZSBTaWduaW5nIENBIEVWIFIzNgIQSw+NgvCzdrKXturaTqbU
# 7DANBglghkgBZQMEAgEFAKCBhDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkG
# CSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEE
# AYI3AgEVMC8GCSqGSIb3DQEJBDEiBCArZjUW5doDb382kThp5Os6KDgOF+6eUZuJ
# EfKWBuQPqzANBgkqhkiG9w0BAQEFAASCAgALlrwKdzduUY+UwJB+wxYMIQZb9DMW
# 2AqIqp7iwWQdwbRuXZEWwUluiuL0YzVvSx3/J05MUbxQ2+UocRf24fxPCK643UPD
# 6uZ4twar1ZyrNNTJbjS5sW8SJuNZJEZEVo2R7GRk8/2ZaaB5ZUKyIMB+rIixDw5C
# WB/p2YIT8FiYMYev8wlJcVrzDFsZZDQNyJVDu9smz3cORENENxsUNxbfgSbt7SlZ
# BNFKBm+sXdw8TK84HgI4fbiYzCE5QUnb6TFKSEASAvDJWj4O7x2ZBSv5mHtFZKJj
# gIyjfi5/Gh6imFw4uLJsqv2XQBYsITqPDQKc+dDz2kGt4BkNNxTgNRDR4pSJNXa5
# NfBDHnfTS+fAOS1lVy97YlckGBFd1bmkVxsn8AIWk9HBkWPuJGSgoNz3iTMYW8tM
# pGWdZqWpE/DnlZIiLm+NLuWUTrcz42DRMKbSe8oJlTfOJMsOiWAnC5h1jkioyWDR
# QlIWkA115Fr7glNnDM3aL0rTOg2ATl/0wAbJmMlThyjTpqUCJTh3oKWs44RV0VZX
# AWbOOfS4yxs3hGFM+1u0dYDgdH9Lsk1hbTrtqGrsTfQvLPAN8emQQyaHpTUGtuLa
# mgvO8TdS4nHL4R6IzMcWf2hj0Rmqs2BPPzFH3hJNsWLytrymY5d2PPqPVsvyYa3A
# N0VpeMvid8/QSKGCAyYwggMiBgkqhkiG9w0BCQYxggMTMIIDDwIBATB9MGkxCzAJ
# BgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGln
# aUNlcnQgVHJ1c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNBNDA5NiBTSEEyNTYgMjAy
# NSBDQTECEAqA7xhLjfEFgtHEdqeVdGgwDQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG
# 9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yNjAxMDYwNDEzMjFa
# MC8GCSqGSIb3DQEJBDEiBCCFm8K1FALoMmigB6oK3B/m8o0bCG5MOw9D0/hWasR0
# LDANBgkqhkiG9w0BAQEFAASCAgDCxbA4eU0decek/o7BzYL3UyWCKiZx/6ne618T
# qq99y4pFM18BsF1NCOpwpY6TVtdL4N6wCZLXvNJ5idvTvu+KfOICus5WwVxfSh0z
# fhwZng31/Yiimez/Mk6gsTu7Et/xU/YUFR3xdIUGycNcFeN3e9bWSdiXxhQ+94fT
# A10K3JI14o5OSXVFMYJfElcF0LW9iADtazKLPA/cMaFc7p+J+mzS1tJJl5luFwOV
# unMopo1R2IXNpXZ8JV69L7EqC3NG3c83zcmLsjxhp17jEv8PnBcB3kxx9HnYUBmV
# Roqy9UVwY9leoZxVGcOzmuEpK2KDwWzm7HoB679jNXZL6a9dC95rQYNTQF9g0k8c
# iYb47xxYvZZkJvwDe7LilI2WCF8xccHdrANmgU7u1XKQpxnGeKOw2yWBdgZjuEmm
# DBkksxlfKMwE9+afxtDCPqpsb2ZAypTkl9nNjdCqe4HoPyPm6EGYPnjad92L0fSa
# PiqgRPhGsx4/SWlyI2RMORkxLCIHkJkVuFAZAKQOzw2cLMqbQ56/Vwpgp9VGZCBn
# QLaAyQuco3QS+pyq74nEHlkgzioQSB4TzihF58jg329cNaCXRlXsK+c7oyXHZTFW
# LP5o3pAe2HyeEBaA21FAt+FlKdVI3USRhVKQmqmL7FcOJhw1S5EHMfX0VyDOV038
# bzTNHQ==
# SIG # End signature block
