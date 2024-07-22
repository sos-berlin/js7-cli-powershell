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

# ----------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------

$script:jsWebService = New-JS7WebServiceObject

# SIG # Begin signature block
# MIIsmQYJKoZIhvcNAQcCoIIsijCCLIYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCB6TxH02X+djrvc
# Mgc+1QU/SIrnKbjsUAC/5g7HphK3D6CCJa4wggVvMIIEV6ADAgECAhBI/JO0YFWU
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
# Bq4wggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcNAQELBQAwYjEL
# MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3
# LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0
# MB4XDTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkGA1UEBhMCVVMx
# FzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVz
# dGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCAiIwDQYJKoZI
# hvcNAQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8TykTepl1Gh1tKD
# 0Z5Mom2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsmc5Zt+FeoAn39
# Q7SE2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r07G1decf
# BmWNlCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2R/dhgxndX7RU
# CyFobjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0QKfAcsW6Th+x
# tVhNef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/oBpHIEPjQ2OA
# e3VuJyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1pslPJSlRErWHRA
# KKtzQ87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0z9JMq++b
# Pf4OuGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y99xh3pP+
# OcD5sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkUEBIDfV8ju2Tj
# Y+Cm4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1GnrXTdrnSDmuZ
# DNIztM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQW
# BBS6FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/
# 57qYrhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgwdwYI
# KwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5j
# b20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9j
# cmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAGA1Ud
# IAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEA
# fVmOwJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7cIoNqilp/GnB
# zx0H6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2pVs8Vc40BIiXO
# lWk/R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxkJodskr2dfNBw
# CnzvqLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpknG6skHibBt94q
# 6/aesXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2n82HhyS7T6NJ
# uXdmkfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HNT7ZAmyEh
# QNC3EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvtCl8zOYdBeHo4
# 6Zzh3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU5vIXmVnKcPA3
# v5gA3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8KvYHZE/6/pNHz
# V9m8BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/GqSFD/yYlvZV
# VCsfgPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggbCMIIEqqADAgECAhAF
# RK/zlJ0IOaa/2z9f5WEWMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcw
# FQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3Rl
# ZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwHhcNMjMwNzE0MDAw
# MDAwWhcNMzQxMDEzMjM1OTU5WjBIMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGln
# aUNlcnQsIEluYy4xIDAeBgNVBAMTF0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIzMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAo1NFhx2DjlusPlSzI+DPn9fl
# 0uddoQ4J3C9Io5d6OyqcZ9xiFVjBqZMRp82qsmrdECmKHmJjadNYnDVxvzqX65RQ
# jxwg6seaOy+WZuNp52n+W8PWKyAcwZeUtKVQgfLPywemMGjKg0La/H8JJJSkghra
# arrYO8pd3hkYhftF6g1hbJ3+cV7EBpo88MUueQ8bZlLjyNY+X9pD04T10Mf2SC1e
# RXWWdf7dEKEbg8G45lKVtUfXeCk5a+B4WZfjRCtK1ZXO7wgX6oJkTf8j48qG7rSk
# IWRw69XloNpjsy7pBe6q9iT1HbybHLK3X9/w7nZ9MZllR1WdSiQvrCuXvp/k/Xtz
# PjLuUjT71Lvr1KAsNJvj3m5kGQc3AZEPHLVRzapMZoOIaGK7vEEbeBlt5NkP4FhB
# +9ixLOFRr7StFQYU6mIIE9NpHnxkTZ0P387RXoyqq1AVybPKvNfEO2hEo6U7Qv1z
# fe7dCv95NBB+plwKWEwAPoVpdceDZNZ1zY8SdlalJPrXxGshuugfNJgvOuprAbD3
# +yqG7HtSOKmYCaFxsmxxrz64b5bV4RAT/mFHCoz+8LbH1cfebCTwv0KCyqBxPZyS
# kwS0aXAnDU+3tTbRyV8IpHCj7ArxES5k4MsiK8rxKBMhSVF+BmbTO77665E42FEH
# ypS34lCh8zrTioPLQHsCAwEAAaOCAYswggGHMA4GA1UdDwEB/wQEAwIHgDAMBgNV
# HRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcwCAYG
# Z4EMAQQCMAsGCWCGSAGG/WwHATAfBgNVHSMEGDAWgBS6FtltTYUvcyl2mi91jGog
# j57IbzAdBgNVHQ4EFgQUpbbvE+fvzdBkodVWqWUxo97V40kwWgYDVR0fBFMwUTBP
# oE2gS4ZJaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0
# UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNybDCBkAYIKwYBBQUHAQEEgYMw
# gYAwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggrBgEF
# BQcwAoZMaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3Rl
# ZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsF
# AAOCAgEAgRrW3qCptZgXvHCNT4o8aJzYJf/LLOTN6l0ikuyMIgKpuM+AqNnn48Xt
# JoKKcS8Y3U623mzX4WCcK+3tPUiOuGu6fF29wmE3aEl3o+uQqhLXJ4Xzjh6S2sJA
# OJ9dyKAuJXglnSoFeoQpmLZXeY/bJlYrsPOnvTcM2Jh2T1a5UsK2nTipgedtQVyM
# adG5K8TGe8+c+njikxp2oml101DkRBK+IA2eqUTQ+OVJdwhaIcW0z5iVGlS6ubzB
# aRm6zxbygzc0brBBJt3eWpdPM43UjXd9dUWhpVgmagNF3tlQtVCMr1a9TMXhRsUo
# 063nQwBw3syYnhmJA+rUkTfvTVLzyWAhxFZH7doRS4wyw4jmWOK22z75X7BC1o/j
# F5HRqsBV44a/rCcsQdCaM0qoNtS5cpZ+l3k4SF/Kwtw9Mt911jZnWon49qfH5U81
# PAC9vpwqbHkB3NpE5jreODsHXjlY9HxzMVWggBHLFAx+rrz+pOt5Zapo1iLKO+ua
# gjVXKBbLafIymrLS2Dq4sUaGa7oX/cR3bBVsrquvczroSUa31X/MtjjA2Owc9bah
# uEMs305MfR5ocMB3CtQC4Fxguyj/OOVSWtasFyIjTvTs0xf7UGv/B3cfcZdEQcm4
# RtNsMnxYL2dHZeUbc7aZ+WssBkbvQR7w8F/g29mtkIBEr4AQQYowggcOMIIFdqAD
# AgECAhBLD42C8LN2spe26tpOptTsMA0GCSqGSIb3DQEBCwUAMFcxCzAJBgNVBAYT
# AkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNlY3RpZ28g
# UHVibGljIENvZGUgU2lnbmluZyBDQSBFViBSMzYwHhcNMjMwNTMwMDAwMDAwWhcN
# MjYwNTI5MjM1OTU5WjCB1DESMBAGA1UEBRMJSFJCIDIxMDE1MRMwEQYLKwYBBAGC
# NzwCAQMTAkRFMR0wGwYDVQQPExRQcml2YXRlIE9yZ2FuaXphdGlvbjELMAkGA1UE
# BhMCREUxDzANBgNVBAgMBkJlcmxpbjE1MDMGA1UECgwsU09TIFNvZnR3YXJlLSB1
# bmQgT3JnYW5pc2F0aW9ucy1TZXJ2aWNlIEdtYkgxNTAzBgNVBAMMLFNPUyBTb2Z0
# d2FyZS0gdW5kIE9yZ2FuaXNhdGlvbnMtU2VydmljZSBHbWJIMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAvm3W6wNLzldzDdwiBUO9vjdX3L2GJGfxxaem
# ditbwpxLnzXbSfStEJc9bywUm+bhSp/XGzWxeSbIGt13Sn9EFopORa25JxuwA8xT
# EOxLM/CElgP/aN+/rl5sHzapJRF87id7yIXvlZxxiuAPZvpkTc/HWSz/IfbNPDtW
# NJhmCOliGJR3bXmFPHDDDflrfY5L9/v2wyLURELypxVBi53AabZutiAa40LSqovV
# ndbYQ8qQfdW9QVRJDF0hDMQ8xmu31kB6mLMCXK/9Rm7F2Yiv0NMvg4h3qh3kV+kL
# HzEcaIMeBQu+VtCPvMEn8ahRRw80blh7V2f9OX3GRyYn0DQfjMZdGjpmj4P0xldq
# 8Ge2PVm+rCUJeJSQUYsO1rLhMyBAoMl+z6qhwWuxh5cJaJarDQvLWpixrisA+AJN
# JUniPyXTr+dZTSvnt29dG30C66KRskFKWDuBzjraAr3kUWQAJ5kS6G1KSuydbxgW
# k99Mjt+iaHLKDlseJEqXIerceCvsLzw+NOYsA5AOEdCz+OCLdowQM0etNwWgcGVi
# ZBuydT3OvQ8w5QldJEXU+wh7a++/D2ul++4uhtQ3bWDWyk24SKX6OsqDFgcrFxWq
# +VJWflIhKqFA9hEZst5k8gHZkyXnD7PlbCDoeqt2sPUyiZKQ/BY3ESONKDc+HZaL
# MG2ARjcCAwEAAaOCAdYwggHSMB8GA1UdIwQYMBaAFIEykkErKM1GyMSixio5EuxI
# qT8UMB0GA1UdDgQWBBREcHbV+LshFGmyiI02mnHSTFDZgjAOBgNVHQ8BAf8EBAMC
# B4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzBJBgNVHSAEQjBA
# MDUGDCsGAQQBsjEBAgEGATAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28u
# Y29tL0NQUzAHBgVngQwBAzBLBgNVHR8ERDBCMECgPqA8hjpodHRwOi8vY3JsLnNl
# Y3RpZ28uY29tL1NlY3RpZ29QdWJsaWNDb2RlU2lnbmluZ0NBRVZSMzYuY3JsMHsG
# CCsGAQUFBwEBBG8wbTBGBggrBgEFBQcwAoY6aHR0cDovL2NydC5zZWN0aWdvLmNv
# bS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdDQUVWUjM2LmNydDAjBggrBgEFBQcw
# AYYXaHR0cDovL29jc3Auc2VjdGlnby5jb20wSAYDVR0RBEEwP6AcBggrBgEFBQcI
# A6AQMA4MDERFLUhSQiAyMTAxNYEfYW5kcmVhcy5wdWVzY2hlbEBzb3MtYmVybGlu
# LmNvbTANBgkqhkiG9w0BAQsFAAOCAYEAZBWwQK1VzdSeibzUhNfNeTez03qcyuzL
# EhcFO0WlrUqr+hFmOEvdi4dmYDeRKmLw2M7RO+kjXsoT+UQHy2byrEsA5MJDuXYK
# yQBtzPksgUoNvP5+br3gZp4CnzYprETjn9X56yOLfoPxUq3LAMAFqtNkANfGkh9D
# n72ws3LR3OkLBRxSvDRQCuhvo2uibwXqdL19wGgPyEvH9YjBnKGkpgaYq0SGkXuW
# wrsjFTb+303nc3N8n6+ZK4xEp1m7W6gA3H09eRaiWKGZ9H8nzYehgszuiRkZuEzN
# PfHoM6fS2Kv6YI4hyCTyIwDWfGS5w+JYEdhifcvE/xp+iBKTXUfGTmb1ke92uqwd
# lTfSV/sRHObvMKNoTGx1P/Ua1QmU3K0OslDIrQm2I/cLHG5msaHxsU41FOkMeSt9
# /VqD9cY9lH7IsJaCqY7cmCg8tECQ+UggkSRr7gwO5Gjfo7NOtORIoBibi4YD3Fpy
# V0aiOt7hpeBIqd1JIEWtD1GpUA7A6qqDMYIGQTCCBj0CAQEwazBXMQswCQYDVQQG
# EwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdv
# IFB1YmxpYyBDb2RlIFNpZ25pbmcgQ0EgRVYgUjM2AhBLD42C8LN2spe26tpOptTs
# MA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJ
# KoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQB
# gjcCARUwLwYJKoZIhvcNAQkEMSIEIDIS93Xhi1fZ+6G8jiVQXOVLOBUZv0L1h1os
# 58ONopnMMA0GCSqGSIb3DQEBAQUABIICAAk2T9st2EP5BPqtFVbX/z+UOelZFBux
# vWM4HSCk8QNvehXRng7MCq1QpW1ZQ+qD8eEa9rf0T/UQ+JzUFT3sOUAr/yJmaOy/
# iLln1gJAhu0VSfKCJJzRmbuavsS+JLkkxcTxhvrobVScjik269zJmZCbbOFGT37d
# /vy1DRGb+G3WUAM9ydUp/yZW+xGzHMvppFrToFpccCEcqSWEEAWSyYO1MXd0iZ9K
# 0Dvnpl6AGFMhkEGWL/HPDHykYBJsynv+aT3/x5pIcDNJVS75r/J77NNxP6n9JoLl
# mHnGx0vAj39ZnL+g3Cq4tb+FMFUwoxa362cCFEpJ66cp9DQkGgfFGyqcT5LcdCqx
# drxuCP/nBrCACYe3CGay9J43TEUn2RbIq+FDfqIO8AqFofn+i0EovTqZ+HdUfwoC
# Fhjg6dGF3irTBTE5sL+r2E4P2S9BB4GQ2zCjDttZMOi2q00f0F4F+D1cKaBmJVEf
# uf2rOc9XCWifruGECQHLAKF9ObvmYGZU+0OhPEPhGhNNg95dg86TznV+yYU+vQiG
# stSJ8tdgXKxhx5GY+uSv9gXeYxa8uMkMTqaCZkwQzjnVLOu0NfrXQspybw/ClEBk
# g1Ove68891un15cBAKt3S5HqBh22V0es0uTS7ee9lbT7PziPL5N4Fi0FMN+XwOyg
# 8NTPVsS4lzInoYIDIDCCAxwGCSqGSIb3DQEJBjGCAw0wggMJAgEBMHcwYzELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdp
# Q2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQ
# BUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzEL
# BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTI0MDcyMjIyMjgwMVowLwYJKoZI
# hvcNAQkEMSIEIHYYkBWQhFY7118mJvBMvzZQ+vhGiTvnFiLKl3IOsvYlMA0GCSqG
# SIb3DQEBAQUABIICAFgcX3HjB0tp7TaRJ0b5cDohqp+/sSj+hzJHFBAgNu+Z/Sj8
# 27En9bfSq1CQViQTXJSsvOqZk23S/XucYjwvofNS9QWgHmxU0Ck+fwPXGoNRykA5
# lfiKp5DKfmIpuylwyUYoAfVahj0QmlVbGQJnAVLqPEI5UGmekl4Aq7SRrdzHNTGM
# 0wqIy4vC4gY6on9Jq8ShVqI0x21GNH2pT4s7EEeyjK7jQfJ8LaYahoplpRJ0TdKl
# gJ3a/9IJK1pkPo9GI7LI5VkYtPrWi/YR/Ug22p3UI1I2usDp5FDXBVBV87G5Ac/G
# /DPAzwPbLF58M1r0/u2ep38P3yv7MixiOGMjiI17eFMxHJPd5Z4h5DdsTtgKv8j5
# Ictv0kxKz23e8oyzBgkbuaK/8ycIS/LXsHrriYVwier9B54UyUgY3/Q0uK21FHN5
# GVxiB1fimy20kik0aX8WY8vM2mZMSkjvqMRjednLuTfdpbSf0bcqz9VxONEK8jp5
# fYmGW+cGvYA9OJsGZysMZ+ZxtNGs5vz9xZQ6RWl/GPfQ6t7wHLIbnIEXHDBlVVmN
# DjSYIE7dN/7/Pndtf998lQjvpYPNpihBh7SBcgRAE9yctT1PJr068lMh77eF9SxK
# k6cz76lZ2r9CNqouyWorUpYXXwNfpbVYBRrStxRVEeKjsPl5XZJ8uqKboSDk
# SIG # End signature block
