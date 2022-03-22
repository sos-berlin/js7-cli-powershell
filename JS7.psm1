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

function Invoke-JS7WebRequest( [string] $Path, [object] $Body, [string] $Method='POST', [string] $ContentType='application/json; charset=utf-8', [hashtable] $Headers=@{'Accept' = 'application/json'}, [string] $InFile, [string] $OutFile, [boolean] $Verbose )
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

    if ( $script:jsWebService.Timeout )
    {
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
