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

function isPowerShellVersion( [int] $Major=-1, [int] $Minor=-1, [int] $Patch=-1 )
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
# MIIslwYJKoZIhvcNAQcCoIIsiDCCLIQCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCD3fQzyoHXaEgZn
# gDRzl6qKjucB1nJDpJuQxHSkIztxbaCCJawwggVvMIIEV6ADAgECAhBI/JO0YFWU
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
# VCsfgPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggbAMIIEqKADAgECAhAM
# TWlyS5T6PCpKPSkHgD1aMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcw
# FQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3Rl
# ZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwHhcNMjIwOTIxMDAw
# MDAwWhcNMzMxMTIxMjM1OTU5WjBGMQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGln
# aUNlcnQxJDAiBgNVBAMTG0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIyIC0gMjCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAM/spSY6xqnya7uNwQ2a26HoFIV0
# MxomrNAcVR4eNm28klUMYfSdCXc9FZYIL2tkpP0GgxbXkZI4HDEClvtysZc6Va8z
# 7GGK6aYo25BjXL2JU+A6LYyHQq4mpOS7eHi5ehbhVsbAumRTuyoW51BIu4hpDIjG
# 8b7gL307scpTjUCDHufLckkoHkyAHoVW54Xt8mG8qjoHffarbuVm3eJc9S/tjdRN
# lYRo44DLannR0hCRRinrPibytIzNTLlmyLuqUDgN5YyUXRlav/V7QG5vFqianJVH
# hoV5PgxeZowaCiS+nKrSnLb3T254xCg/oxwPUAY3ugjZNaa1Htp4WB056PhMkRCW
# fk3h3cKtpX74LRsf7CtGGKMZ9jn39cFPcS6JAxGiS7uYv/pP5Hs27wZE5FX/Nurl
# fDHn88JSxOYWe1p+pSVz28BqmSEtY+VZ9U0vkB8nt9KrFOU4ZodRCGv7U0M50GT6
# Vs/g9ArmFG1keLuY/ZTDcyHzL8IuINeBrNPxB9ThvdldS24xlCmL5kGkZZTAWOXl
# LimQprdhZPrZIGwYUWC6poEPCSVT8b876asHDmoHOWIZydaFfxPZjXnPYsXs4Xu5
# zGcTB5rBeO3GiMiwbjJ5xwtZg43G7vUsfHuOy2SJ8bHEuOdTXl9V0n0ZKVkDTvpd
# 6kVzHIR+187i1Dp3AgMBAAGjggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0T
# AQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeB
# DAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+e
# yG8wHQYDVR0OBBYEFGKK3tBh/I8xFO2XC809KpQU31KcMFoGA1UdHwRTMFEwT6BN
# oEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJT
# QTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGA
# MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUH
# MAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRH
# NFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQAD
# ggIBAFWqKhrzRvN4Vzcw/HXjT9aFI/H8+ZU5myXm93KKmMN31GT8Ffs2wklRLHiI
# Y1UJRjkA/GnUypsp+6M/wMkAmxMdsJiJ3HjyzXyFzVOdr2LiYWajFCpFh0qYQitQ
# /Bu1nggwCfrkLdcJiXn5CeaIzn0buGqim8FTYAnoo7id160fHLjsmEHw9g6A++T/
# 350Qp+sAul9Kjxo6UrTqvwlJFTU2WZoPVNKyG39+XgmtdlSKdG3K0gVnK3br/5iy
# JpU4GYhEFOUKWaJr5yI+RCHSPxzAm+18SLLYkgyRTzxmlK9dAlPrnuKe5NMfhgFk
# nADC6Vp0dQ094XmIvxwBl8kZI4DXNlpflhaxYwzGRkA7zl011Fk+Q5oYrsPJy8P7
# mxNfarXH4PMFw1nfJ2Ir3kHJU7n/NBBn9iYymHv+XEKUgZSCnawKi8ZLFUrTmJBF
# YDOA4CPe+AOk9kVH5c64A0JH6EE2cXet/aLol3ROLtoeHYxayB6a1cLwxiKoT5u9
# 2ByaUcQvmvZfpyeXupYuhVfAYOd4Vn9q78KVmksRAsiCnMkaBXy6cbVOepls9Oie
# 1FqYyJ+/jbsYXEP10Cro4mLueATbvdH7WwqocH7wl4R44wgDXUcsY6glOJcB0j86
# 2uXl9uab3H4szP8XTE0AotjWAQ64i+7m4HJViSwnGWH2dwGMMIIHDjCCBXagAwIB
# AgIQSw+NgvCzdrKXturaTqbU7DANBgkqhkiG9w0BAQsFADBXMQswCQYDVQQGEwJH
# QjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1
# YmxpYyBDb2RlIFNpZ25pbmcgQ0EgRVYgUjM2MB4XDTIzMDUzMDAwMDAwMFoXDTI2
# MDUyOTIzNTk1OVowgdQxEjAQBgNVBAUTCUhSQiAyMTAxNTETMBEGCysGAQQBgjc8
# AgEDEwJERTEdMBsGA1UEDxMUUHJpdmF0ZSBPcmdhbml6YXRpb24xCzAJBgNVBAYT
# AkRFMQ8wDQYDVQQIDAZCZXJsaW4xNTAzBgNVBAoMLFNPUyBTb2Z0d2FyZS0gdW5k
# IE9yZ2FuaXNhdGlvbnMtU2VydmljZSBHbWJIMTUwMwYDVQQDDCxTT1MgU29mdHdh
# cmUtIHVuZCBPcmdhbmlzYXRpb25zLVNlcnZpY2UgR21iSDCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBAL5t1usDS85Xcw3cIgVDvb43V9y9hiRn8cWnpnYr
# W8KcS58120n0rRCXPW8sFJvm4Uqf1xs1sXkmyBrdd0p/RBaKTkWtuScbsAPMUxDs
# SzPwhJYD/2jfv65ebB82qSURfO4ne8iF75WccYrgD2b6ZE3Px1ks/yH2zTw7VjSY
# ZgjpYhiUd215hTxwww35a32OS/f79sMi1ERC8qcVQYudwGm2brYgGuNC0qqL1Z3W
# 2EPKkH3VvUFUSQxdIQzEPMZrt9ZAepizAlyv/UZuxdmIr9DTL4OId6od5FfpCx8x
# HGiDHgULvlbQj7zBJ/GoUUcPNG5Ye1dn/Tl9xkcmJ9A0H4zGXRo6Zo+D9MZXavBn
# tj1ZvqwlCXiUkFGLDtay4TMgQKDJfs+qocFrsYeXCWiWqw0Ly1qYsa4rAPgCTSVJ
# 4j8l06/nWU0r57dvXRt9AuuikbJBSlg7gc462gK95FFkACeZEuhtSkrsnW8YFpPf
# TI7fomhyyg5bHiRKlyHq3Hgr7C88PjTmLAOQDhHQs/jgi3aMEDNHrTcFoHBlYmQb
# snU9zr0PMOUJXSRF1PsIe2vvvw9rpfvuLobUN21g1spNuEil+jrKgxYHKxcVqvlS
# Vn5SISqhQPYRGbLeZPIB2ZMl5w+z5Wwg6HqrdrD1MomSkPwWNxEjjSg3Ph2WizBt
# gEY3AgMBAAGjggHWMIIB0jAfBgNVHSMEGDAWgBSBMpJBKyjNRsjEosYqORLsSKk/
# FDAdBgNVHQ4EFgQURHB21fi7IRRpsoiNNppx0kxQ2YIwDgYDVR0PAQH/BAQDAgeA
# MAwGA1UdEwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwSQYDVR0gBEIwQDA1
# BgwrBgEEAbIxAQIBBgEwJTAjBggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0aWdvLmNv
# bS9DUFMwBwYFZ4EMAQMwSwYDVR0fBEQwQjBAoD6gPIY6aHR0cDovL2NybC5zZWN0
# aWdvLmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdDQUVWUjM2LmNybDB7Bggr
# BgEFBQcBAQRvMG0wRgYIKwYBBQUHMAKGOmh0dHA6Ly9jcnQuc2VjdGlnby5jb20v
# U2VjdGlnb1B1YmxpY0NvZGVTaWduaW5nQ0FFVlIzNi5jcnQwIwYIKwYBBQUHMAGG
# F2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMEgGA1UdEQRBMD+gHAYIKwYBBQUHCAOg
# EDAODAxERS1IUkIgMjEwMTWBH2FuZHJlYXMucHVlc2NoZWxAc29zLWJlcmxpbi5j
# b20wDQYJKoZIhvcNAQELBQADggGBAGQVsECtVc3Unom81ITXzXk3s9N6nMrsyxIX
# BTtFpa1Kq/oRZjhL3YuHZmA3kSpi8NjO0TvpI17KE/lEB8tm8qxLAOTCQ7l2CskA
# bcz5LIFKDbz+fm694GaeAp82KaxE45/V+esji36D8VKtywDABarTZADXxpIfQ5+9
# sLNy0dzpCwUcUrw0UArob6Nrom8F6nS9fcBoD8hLx/WIwZyhpKYGmKtEhpF7lsK7
# IxU2/t9N53NzfJ+vmSuMRKdZu1uoANx9PXkWolihmfR/J82HoYLM7okZGbhMzT3x
# 6DOn0tir+mCOIcgk8iMA1nxkucPiWBHYYn3LxP8afogSk11Hxk5m9ZHvdrqsHZU3
# 0lf7ERzm7zCjaExsdT/1GtUJlNytDrJQyK0JtiP3CxxuZrGh8bFONRTpDHkrff1a
# g/XGPZR+yLCWgqmO3JgoPLRAkPlIIJEka+4MDuRo36OzTrTkSKAYm4uGA9xacldG
# ojre4aXgSKndSSBFrQ9RqVAOwOqqgzGCBkEwggY9AgEBMGswVzELMAkGA1UEBhMC
# R0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEuMCwGA1UEAxMlU2VjdGlnbyBQ
# dWJsaWMgQ29kZSBTaWduaW5nIENBIEVWIFIzNgIQSw+NgvCzdrKXturaTqbU7DAN
# BglghkgBZQMEAgEFAKCBhDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqG
# SIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3
# AgEVMC8GCSqGSIb3DQEJBDEiBCCZUTLQg8tfzucUafScTRCm3AmbyXPAWcC9IF6D
# JIaOfDANBgkqhkiG9w0BAQEFAASCAgAotXSypX2z+4JQ3mWDktPSJEW6p+S2D/7z
# y5NKNmj4DgFzuj9qdCDPVoDorMnxk2zpfcAT3nBGhgbnvCh1McvochBw0Wb7NVvU
# 1GuQwQJ8pNffCPcgvSnzqsSA1LHZwIuhVOXCAQ1jMjv/tulDDit9XI07Vy9wL/kX
# UH94V1jbH5/WVwM+m4ko2hKdHC5T1q5d6d1nrWz9FEXaBwJyeRdsv+XeYM3uYk8+
# vy4AqUTv/jZxO9yl9/5WP/Z2lp9Q0wcuUxoVVAGl3QIYQ5P9lmpbe7iRqOTZwtfO
# 6EXe+RNhaUIQgDKLeot0S7fHRSRfei70pvuBuVHJ+ao/rEZbOkfolWsaRncjdPEY
# RrIEbfcECyCIdB2V6z6lp5v0n6Q/EcmUIjr8b6grZi6tPzbMX2mxlSTzVb92dMcS
# LZSFtDL9KqsjKzm0JA63oLQ4ESuxt7hABTRtIzwhHttgegliZZj2VMm14WMcMO8R
# nKdrJdtVOAzAzys1p9htKwEJevFPw0M0Hw3sQfAW3Wo/9H7tQApPt3xFTMLOt+5w
# Yd11wgZWPuq/H9YWTOW17g8kQoJbZDy9YDgzahp+ih4rY3cus5y0KZoWCOomOOFC
# Mpv6K3/3wujcQSU+xXD8uUFdO8Mh41xra329e6rdebObDjlxLa2CLm+PsMFzDaql
# iNW00C8SW6GCAyAwggMcBgkqhkiG9w0BCQYxggMNMIIDCQIBATB3MGMxCzAJBgNV
# BAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNl
# cnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAxN
# aXJLlPo8Kko9KQeAPVowDQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG9w0BCQMxCwYJ
# KoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMzA2MDYxNzM5MTFaMC8GCSqGSIb3
# DQEJBDEiBCCEcOnFYDf/N4p9B4YKEPIMPIW4tcylqr1QvXpmgSuQ6zANBgkqhkiG
# 9w0BAQEFAASCAgBOzwoSft5Q1ZBf3lJVhuXlGWsszLvDU1dJJ6dSoC/FTj3DPQLI
# 8do+GMBCLhZcvFcNVz0BfcxmK9S6Cu5PVoSJPd5gfhwmKITddEjVf49HpB7ZVbee
# 9hr9XZED79pzy8t8uhMhD6JF0TtVeG0aFvoEu49rqfwnujQxpOxJSMp+ySyh8eS/
# idrDQnr9BFfSoH4Vs+d/6sqpVv0zeJUEgShLVfF0vBvlRMj1XQ3lUOMHSWPdUkyZ
# b34i5Txi+qF5kjpRkOxVbZ5Rsn8vdMpfp6uxIO+DmSadj8JSX6GQ4hmMP+W2I86u
# BqEXCs0DDNDtExnXO8XKP0UsnV8tOr9loqHTxBuwlCBGkYeu5uGsMR8vkIx/p29W
# 4X2warYTmZM0qr2s8GA/elcxzYE+DgEd1VG2F0ByY+fCHB0xXXcHAdaXIuL1fSXf
# yxC9MVI3tR/ZBVSomXFJiIj3l+9QY0ozHtahQGejd0zm0ekcu+4OCPCzb02YOumo
# hfxkBGu5C6ceqddd+byPIb1ZPplNrQwvGl9De2tbJy7bJVkLDwBQhECyArnTgBJx
# 2p1NPe5sIXWgSLSamx3FNvhxRM0Ttk3m26wNQB1qLtjTRfXM1YBNabcn4W5icctZ
# 7w7MR5XlAllMdXc2YaF2d2qlo8qLRwdzUtQ4/iyrVlLF/4u9bS9AYtp7zQ==
# SIG # End signature block
