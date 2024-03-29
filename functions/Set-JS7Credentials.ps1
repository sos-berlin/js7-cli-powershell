function Set-JS7Credentials
{
<#
.SYNOPSIS
Sets credentials that are used to authenticate with requests to the JS7 Web Services

.DESCRIPTION
Credentials are required to authenticate with the JS7 Web Service.
Such credentials can be specified on-the-fly with the Connect-JS7 cmdlet or
they can be specified with this cmdlet.

.PARAMETER UseDefaultCredentials
Specifies that the implicit Windows credentials of the current user are applied for authentication challenges.

Either the parameter -UseDefaultCredentials or -Credentials can be used.

.PARAMETER AskForCredentials
Specifies that the user is prompted for the account and password that are used for authentication with JS7.

.PARAMETER Credentials
Specifies a credentials object that is used for authentication with JS7.

A credentials object can be created e.g. with:

    $account = 'John'
    $password = ( 'Doe' | ConvertTo-SecureString -AsPlainText -Force)
    $credentials = New-Object -typename System.Management.Automation.PSCredential -Argumentlist $account, $password

An existing credentials object can be retrieved from the Windows Credential Manager e.g. with:

    $systemCredentials = Get-JS7SystemCredentials -TargetName 'localhost'
    $credentials = ( New-Object -typename System.Management.Automation.PSCredential -Argumentlist $systemCredentials.UserName, $systemCredentials.Password )

Either the parameter -UseDefaultCredentials or -Credentials can be used.

.PARAMETER ProxyUseDefaultCredentials
Specifies that the implicit Windows credentials of the current user are applied for proxy authentication.

Either the parameter -ProxyUseDefaultCredentials or -ProxyCredentials can be used.

.PARAMETER ProxyAskForCredentials
Specifies that the user is prompted for the account and password that are used for authentication with a proxy.

.PARAMETER ProxyCredentials
Specifies a credentials object that is used for authentication with a proxy. See parameter -Credentials how to create a credentials object.

Either the parameter -ProxyUseDefaultCredentials or -ProxyCredentials can be used.

.EXAMPLE
Set-JS7Credentials -UseDefaultCredentials

The implicit Windows credentials are used for authentication. No password is used or stored in memory.

.EXAMPLE
Set-JS7Credentials -AskForCredentials

Specifies that the user is prompted for account and password. The password is converted to a secure string
and a credentials object is created for authentication.

.EXAMPLE
$account = 'John'
$password = ('Doe' | ConvertTo-SecureString -AsPlainText -Force)
$credentials = New-Object -typename System.Management.Automation.PSCredential -ArgumentList $account, $password
Set-JS7Credentials -Credentials $credentials

An individual credentials object is created that is assigned the -Credentials parameter.
.EXAMPLE
$account = 'John'
$password = Read-Host 'Enter password for John: ' -AsSecureString
$credentials = New-Object -typename System.Management.Automation.PSCredential -ArgumentList $account, $password
Set-JS7Credentials -Credentials $credentials

An individual credentials object is created that is assigned the -Credentials parameter.
#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $UseDefaultCredentials,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $AskForCredentials,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [System.Management.Automation.PSCredential] $Credentials,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $ProxyUseDefaultCredentials,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $ProxyAskForCredentials,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [System.Management.Automation.PSCredential] $ProxyCredentials
)
    Process
    {
        if ( $UseDefaultCredentials -and $Credentials )
        {
            throw "$($MyInvocation.MyCommand.Name): Use just one of the parameters -UseDefaultCredentials or -Credentials"
        }

        if ( $ProxyUseDefaultCredentials -and $ProxyCredentials )
        {
            throw "$($MyInvocation.MyCommand.Name): Use just one of the parameters -ProxyUseDefaultCredentials or -ProxyCredentials"
        }

        if ( $UseDefaultCredentials )
        {
            if ( $PSCmdlet.ShouldProcess( 'credentials' ) )
            {
                $script:jsOptionWebRequestUseDefaultCredentials = $UseDefaultCredentials
                $script:jsWebServiceOptionWebRequestUseDefaultCredentials = $UseDefaultCredentials
            }
        } else {
            if ( $PSCmdlet.ShouldProcess( 'credentials' ) )
            {
                $script:jsOptionWebRequestUseDefaultCredentials = $false
                $script:jsWebServiceOptionWebRequestUseDefaultCredentials = $false
            }
        }

        if ( $Credentials )
        {
            if ( $PSCmdlet.ShouldProcess( 'credentials' ) )
            {
                $script:jsCredential = $Credentials
                $script:jsWebServiceCredential = $Credentials
            }
        }

        if ( $AskForCredentials )
        {
            Write-Output '* ***************************************************** *'
            Write-Output '* JS7 credentials for web access:                       *'
            Write-Output '* enter account and password for authentication         *'
            Write-Output '* ***************************************************** *'
            $account = Read-Host 'Enter user account for JS7 web access: '

            if ( $account )
            {
                $password = Read-Host 'Enter password for JS7 web access: ' -AsSecureString
                if ( $PSCmdlet.ShouldProcess( 'credentials' ) )
                {
                    $script:jsCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $account, $password
                    $script:jsWebServiceCredential = $script:jsCredential
                }
            }
        }

        if ( $ProxyUseDefaultCredentials )
        {
            if ( $PSCmdlet.ShouldProcess( 'credentials' ) )
            {
                $script:jsOptionWebRequestProxyUseDefaultCredentials = $ProxyUseDefaultCredentials
                $script:jsWebServiceOptionWebRequestProxyUseDefaultCredentials = $ProxyUseDefaultCredentials
            }
        } else {
            if ( $PSCmdlet.ShouldProcess( 'credentials' ) )
            {
                $script:jsOptionWebRequestProxyUseDefaultCredentials = $false
                $script:jsWebServiceOptionWebRequestProxyUseDefaultCredentials = $false
            }
        }

        if ( $ProxyCredentials )
        {
            if ( $PSCmdlet.ShouldProcess( 'credentials' ) )
            {
                $script:jsProxyCredential = $ProxyCredentials
                $script:jsWebServiceProxyCredential = $ProxyCredentials
            }
        }

        if ( $ProxyAskForCredentials )
        {
            Write-Output '* ***************************************************** *'
            Write-Output '* JS7 credentials for proxy access:                     *'
            Write-Output '* enter account and password for proxy authentication   *'
            Write-Output '* ***************************************************** *'
            $proxyAccount = Read-Host 'Enter user account for JS7 proxy access: '

            if ( $proxyAccount )
            {
                $proxyPassword = Read-Host 'Enter password for JS7 proxy access: ' -AsSecureString
                if ( $PSCmdlet.ShouldProcess( 'credentials' ) )
                {
                    $script:jsProxyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $proxyAccount, $proxyPassword
                    $script:jsWebServiceProxyCredential = $script:jsProxyCredentials
                }
            }
        }
    }
}
