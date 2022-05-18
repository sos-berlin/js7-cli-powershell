function Set-JS7IAMAccount
{
<#
.SYNOPSIS
Stores an account to a JOC Cockpit Identity Service

.DESCRIPTION
This cmdlet stores an account to a JOC Cockpit Identity Service.

The following REST Web Service API resources are used:

* /iam/account/store

.PARAMETER Service
Specifies the unique name of the Identity Service that accounts are managed with.

.PARAMETER Account
Specifies the unique name of the account that should be managed.

.PARAMETER Password
Optionally specifies the account's password. If this parameter is not used then the initial password
managed with the JOC Cockpit Identity Service settings is used.

The password has to be specified as a secure string, for example:

$securePassword = ConvertTo-SecureString 'secret' -AsPlainText -Force
Set-JS7IAMAccount -Service 'JOC' -Account 'user1' -Password $secureString -Role 'application_manager'

.PARAMETER Disabled
Specifies that the account cannot be used to login.

.PARAMETER ForcePasswordChange
Specifies that the account has to change the password with the next login.

.PARAMETER Role
Specifies the unique name of a role that is assigned the account.

More than one role can be specified by a comma.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention,
e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of the JOC Cockpit.
This argument is not mandatory, however, JOC Cockpit can be configured
to enforce Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is shown in the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JS7.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JS7.

This information is shown in the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JS7.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Set-JS7IAMAccount -Service 'JOC' -Account 'user1' -Role 'application_manager'

Adds an account to JOC Cockpit that is assigned the indicated role. The account is assigned
the initial password that is configured with the global Identity Service settings.
On first login the account has to change the password.

.EXAMPLE
$securePassword = ConvertTo-SecureString 'secret' -AsPlainText -Force;
Set-JS7IAMAccount -Service 'JOC' -Account 'user1' -Password $secureString -Role 'application_manager','incident_manager'

Adds an account to JOC Cockpit that is assigned a password and the indicated roles.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Alias('IdentityServiceName')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Service,
    [Alias('AccountName')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Account,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [SecureString] $Password,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Disabled,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $ForcePasswordChange,
    [Alias('RoleName')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Role,
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
    }

    Process
    {
        $body = New-Object PSObject

        Add-Member -Membertype NoteProperty -Name 'identityServiceName' -value $Service -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'accountName' -value $Account -InputObject $body

        if ( $Password )
        {
            $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode( $Password )
            Add-Member -Membertype NoteProperty -Name 'password' -value ( [System.Runtime.InteropServices.Marshal]::PtrToStringUni( $ptr ) ) -InputObject $body
            [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode( $ptr )
        }

        Add-Member -Membertype NoteProperty -Name 'disabled' -value ($Disabled -eq $True) -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'forcePasswordChange' -value ($ForcePasswordChange -eq $True) -InputObject $body

        Add-Member -Membertype NoteProperty -Name 'roles' -value $Role -InputObject $body

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

        if ( $PSCmdlet.ShouldProcess( 'account', '/iam/account/store' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/iam/account/store' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $requestResult = ( $response.Content | ConvertFrom-Json ).ok

                if ( !$requestResult )
                {
                    throw ( $response | Format-List -Force | Out-String )
                }
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): account stored"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
