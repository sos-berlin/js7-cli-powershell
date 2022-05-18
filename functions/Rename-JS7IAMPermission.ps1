function Rename-JS7IAMPermission
{
<#
.SYNOPSIS
Renames an existing permission assigned a role in a JOC Cockpit Identity Service

.DESCRIPTION
This cmdlet renames an existing permission assigned a role in a JOC Cockpit Identity Service.

The following REST Web Service API resources are used:

* /iam/permission/rename

.PARAMETER Service
Specifies the unique name of the Identity Service.

.PARAMETER Role
Specifies the unique name of a role that is available with the Identity Service.

.PARAMETER Permission
Specifies the path of the existing permission in the JOC Cockpit inventory and role that should be renamed.

.PARAMETER NewPermission
Specifies the new permission path.

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
Rename-JS7IAMPermission -Service 'JOC' -Role 'application_manager' -ControllerId 'testsuite' -Permission 'sos:products:controller:deployment:deploy' -NewPermission 'sos:products:controller:deployment:view'

Renames an existing permission assigned a role.

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
    [Alias('PermissionPath')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Permission,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $NewPermission,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Excluded,
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
        Add-Member -Membertype NoteProperty -Name 'roleName' -value $Role -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'oldPermissionPath' -value $Permission -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body

            $objPermission = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'permissionPath' -value $NewPermission -InputObject $objPermission
            Add-Member -Membertype NoteProperty -Name 'excluded' -value ($Excluded -eq $True) -InputObject $objPermission

        Add-Member -Membertype NoteProperty -Name 'newPermission' -value $objPermission -InputObject $body

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

        if ( $PSCmdlet.ShouldProcess( 'folder', '/iam/permission/rename' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/iam/permission/rename' -Body $requestBody

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

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): permission $Permission renamed to: $NewPermission"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
