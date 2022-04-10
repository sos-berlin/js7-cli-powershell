function Set-JS7IAMAccount
{
<#
.SYNOPSIS
Stores an account to a JOC Cockpit Identity Service

.DESCRIPTION
This cmdlet stores an account to a JOC Cockpit Identity Service.

The following REST Web Service API resources are used:

* /iam/account/store

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Set-JS7IAMAccount -Service JOC -Account 'user1' -Role 'application_manager'

Adds an account to JOC Cockpit that is assigned the indicated role. The account is assigned
the initial password that is configured with the global Identity Service settings.
On first login the account has to change the password.

.EXAMPLE
$securePassword = ConvertTo-SecureString 'secret' -AsPlainText -Force
Set-JS7IAMAccount -Service JOC -Account 'user1' -Password $secureString -Role 'application_manager','incident_manager'

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
