function Add-JS7GitCredentials
{
<#
.SYNOPSIS
Adds Git credentials to the profile of the current user account

.DESCRIPTION
This cmdlet adds Git credentials to the profile of the current user account. The functionality considers the security level:

* LOW: credentials are added to the default account, typically the root account
* MEDIUM: credentials are added per user account
* HIGH: no credentials are added

Credentials are added for one of the following authentication methods:

* Password: A larger number of Git servers is configured to deny password authentication.
* Access Token: Such tokens are created and stored with the Git Server.
* Private Key: Makes use of SSH authentication with a private key file

The following REST Web Service API resources are used:

* /inventory/repository/git/credentials/add

.PARAMETER Server
Specifies the hostname and optionally the port of the Git Server for which credentials are added.

.PARAMETER Account
Specifies the Git account.

.PARAMETER UserName
Specifies the Git user name.

.PARAMETER UserMail
Specifies the Git user e-mail address.

.PARAMETER Password
Specifies the password for Git authentication. Use of passwords is considered insecure and
a larger number of Git Servers will deny password authentication.

The password has to be specified from a SecureString data type, for example like this:

* $securePassword = ConvertTo-SecureString 'secret' -AsPlainText -Force

.PARAMETER AccessToken
Specifies an access token for authentication that is configured with the Git Server.
Access tokens are a replacement for passwords and do not tend to increase security.

.PARAMETER KeyFile
Specifies the path to a file that holds the private key. The corresponding public key has to be configured with the Git Server.
Use of private keys includes the following options:

* Empty path to private key file: The private key file is looked up from its default location
** Unix: ~/.ssh/id_rsa
** Windows: %USERPROFILE%/.ssh/id_rsa
* file name of private key file: The private key file is looked up from the directory JETTY_BASE/resources/joc/repositories/private
* path to private key file: The absolute path to the location of the private key file.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of JOC Cockpit.
This parameter is not mandatory, however, JOC Cockpit can be configured to enforce Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is visible with the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JobScheduler.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JobScheduler.

This information is visible with the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JobScheduler.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
$securePassword = ConvertTo-SecureString 'secret' -AsPlainText -Force
Add-JS7GitCredentials -Server github.com -Account someone -Password $secureString

Adds credentials for access to a Git Server by password authentication.

.EXAMPLE
Add-JS7GitCredentials -Server github.com -Account someone -KeyFile /home/sos/git_rsa

Adds credentials for access to a Git Server using a private key file specified by its absolute path.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Server,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Account,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $UserName,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $UserMail,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [SecureString] $Password,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $AccessToken,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $KeyFile,
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

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        if ( !$Password -and !$AccessToken -and !$KeyFile )
        {
            throw "$($MyInvocation.MyCommand.Name): Authentication mechanism required, use one of -Password, -AccessToken, -KeyFile as required by the Git server"
        }

        if ( ($Password -and $AccessToken) -or ($AccessToken -and $KeyFile) -or ($KeyFile -and $Password) )
        {
           throw "$($MyInvocation.MyCommand.Name): A single authentication mechanism is required, use one of -Password, -AccessToken, -KeyFile as required by the Git server"
        }
    }

    Process
    {

        $body = New-Object PSObject
        $credentials = New-Object PSObject

        Add-Member -Membertype NoteProperty -Name 'gitServer' -value $Server -InputObject $credentials
        Add-Member -Membertype NoteProperty -Name 'gitAccount' -value $Account -InputObject $credentials
        Add-Member -Membertype NoteProperty -Name 'username' -value $UserName -InputObject $credentials
        Add-Member -Membertype NoteProperty -Name 'email' -value $UserMail -InputObject $credentials

        if ( $Password )
        {
            $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode( $Password )
            Add-Member -Membertype NoteProperty -Name 'password' -value ( [System.Runtime.InteropServices.Marshal]::PtrToStringUni( $ptr ) )-InputObject $credentials
            [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode( $ptr )
        }

        if ( $AccessToken )
        {
            Add-Member -Membertype NoteProperty -Name 'personalAccessToken' -value $AccessToken -InputObject $credentials
        }

        if ( $KeyFile )
        {
            Add-Member -Membertype NoteProperty -Name 'keyfilePath' -value $KeyFile -InputObject $credentials
        }

        Add-Member -Membertype NoteProperty -Name 'credentials' -value @( $credentials ) -InputObject $body

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

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/inventory/repository/git/credentials/add' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-Json )

            if ( !$requestResult )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): credentials added for server: $Server"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
