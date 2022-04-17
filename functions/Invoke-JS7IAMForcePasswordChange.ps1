function Invoke-JS7IAMForcePasswordChange
{
<#
.SYNOPSIS
Forces one or more accounts in a JOC Cockpit Identity Service to change the password with the next login

.DESCRIPTION
This cmdlet forces one or more accounts in a JOC Cockpit Identity Service to change the password with the next login.

The following REST Web Service API resources are used:

* /iam/accounts/forcepasswordchange

.PARAMETER Service
Specifies the unique name of the Identity Service that accounts are managed with.

.PARAMETER Account
Specifies the unique name of an account for which change of the password is enforced.

More than one account can be specified by use of a comma.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Invoke-JS7IAMForcePasswordChange -Service 'JOC' -Account 'user1'

Enforces change of the account's password with the next login.

.EXAMPLE
Invoke-JS7IAMForcePasswordChange -Service 'JOC' -Account 'user1','user2'

Enforces change of the password for both indicated accounts with the next login.

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
    [string[]] $Account,
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
        Add-Member -Membertype NoteProperty -Name 'accountNames' -value $Account -InputObject $body

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

        if ( $PSCmdlet.ShouldProcess( 'account', '/iam/accounts/forcepasswordchange' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/iam/accounts/forcepasswordchange' -Body $requestBody

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

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): password change enforced"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
