function Remove-JS7IAMRole
{
<#
.SYNOPSIS
Removes roles from a JOC Cockpit Identity Service

.DESCRIPTION
This cmdlet removes one or more roles from a JOC Cockpit Identity Service.

The following REST Web Service API resources are used:

* /iam/roles/delete

.PARAMETER Service
Specifies the unique name of the Identity Service.

.PARAMETER Role
Specifies one or more roles to be removed from the Identity Service.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention,
e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of JOC Cockpit.
This argument is not mandatory, however, JOC Cockpit can be configured
to enforce Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is visible with the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JS7.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JobScheduler.

This information is visible with the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JobScheduler.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Remove-JS7IAMRole -Service JOC -Role 'application_manager'

Removes a role from the indicated JOC Cockpit Identity Service.

.EXAMPLE
Get-JS7IAMRole -Service JOC -Role 'application_manager' | Remove-JS7IAMRole

Removes the indicated role from the JOC Cockpit Identity Service by pipelining.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Alias('IdentityServiceName')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Service,
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

        $roles = @()
    }

    Process
    {
        $roles += $Role
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'identityServiceName' -value $Service -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'roleNames' -value $roles -InputObject $body

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

        if ( $PSCmdlet.ShouldProcess( 'role names', '/iam/roles/delete' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/iam/roles/delete' -Body $requestBody

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

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($roles.count) roles removed"

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
