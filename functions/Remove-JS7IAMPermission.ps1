function Remove-JS7IAMPermission
{
<#
.SYNOPSIS
Permanently removes permissions from a role in a JOC Cockpit Identity Service

.DESCRIPTION
This cmdlet permanently removes one or more permissions from a role from a JOC Cockpit Identity Service.

The following REST Web Service API resources are used:

* /iam/permissions/delete

.PARAMETER Service
Specifies the unique name of the Identity Service.

.PARAMETER Role
Specifies the unique name of the role from which permissions are removed.

.PARAMETER Permission
Specifies an array of permission objects as returned from the Get-JS7IAMPermission cmdlet.

.PARAMETER ControllerId
Optionally specifies the unique identifier of a Controller should permissions for this
Controller be removed.

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
Remove-JS7IAMPermission -Service 'JOC' -Role 'application_manager'

Deletes permissions from the specified role in the indicated JOC Cockpit Identity Service.

.EXAMPLE
Get-JS7IAMPermission -Service 'JOC' -Role 'application_manager' | Remove-JS7IAMPermission

Deletes permissions from the indicated role in the JOC Cockpit Identity Service by pipelining.

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
    [string] $Role,
    [Alias('Permissions')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [object[]] $Permission,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
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

        $permissions = @()
    }

    Process
    {
        if ( $Permission.count )
        {
            foreach( $permissionItem in $Permission )
            {
                foreach( $item in $permissionItem )
                {
                    if ( $item.permissionPath )
                    {
                        $permissions += $item.permissionPath
                    } else {
                        $permissions += $item
                    }
                }
            }
        } else {
            $permissions += $Permission
        }
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'identityServiceName' -value $Service -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'roleName' -value $Role -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'permissionPaths' -value $permissions -InputObject $body

        if ( $ControllerId )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
        }

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

        if ( $PSCmdlet.ShouldProcess( 'permission', '/iam/permissions/delete' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/iam/permissions/delete' -Body $requestBody

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

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($permissions.count) permissions removed"

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
