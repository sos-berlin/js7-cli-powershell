function Restart-JS7ControllerInstance
{
<#
.SYNOPSIS
Restarts a JS7 Controller Instance and optionally performs cluster fail-over

.DESCRIPTION
A JS7 Controller instance is restarted. In a JS7 cluster a fail-over
to the standby cluster member is performed by default.

The following REST Web Service API resources are used:

* /inventory/releasable


.PARAMETER Url
Optionally the Url of the Controller to be restarted can be specified.
Without this parameter the active Controller instance will be restarted.
Note that restarting a standby Controller instance in a JS7 cluster does not perform
a fail-over operation.

.PARAMETER Action
Restarting a Controller instance includes the following actions:

* Action 'terminate' (Default)
** no new tasks are started.
** running tasks are continued to complete:
*** shell jobs will continue until their normal termination.
*** API jobs complete a current process step.
** JS7 Controller terminates normally.

* Action 'abort'
** no new tasks are started.
** any running tasks are killed.
** JS7 Controller terminates normally.

.PARAMETER NoFailover
This switch prevents a fail-over from happenning when restarting the active Controller instance
in a cluster. Instead, the restarted Controller instance will remain the active cluster member.

.PARAMETER Service
Retarts the JS7 Windows service.

When this parameter is not specified JS7 will be started in
the appropriate operating mode, i.e. service mode or dialog mode.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of the JOC Cockpit.
This parameter is not mandatory. However, the JOC Cockpit can be configured to require Audit Log comments for all interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is shown in the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JS7.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JS7.

This information is shown in the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JS7.

.EXAMPLE
Restart-JS7ControllerInstance

Terminates and restarts the JS7 Controller. In a cluster the active cluster member is restarted
and a fail-over takes place to the standby cluster member. Use -of the -NoFailover switch prevents
the switch-over.

.EXAMPLE
Restart-JS7ControllerInstance -Url (Get-JS7ControllerStatus).Active.Url

Restarts the JS7 Controller active cluster member or standalone instance.

.EXAMPLE
Restart-JS7ControllerInstance -Url (Get-JS7ControllerStatus).Passive.Url -NoFailover

Restarts the JS7 Controller standby cluster member. Consider use of the -NoFailover switch
as a standby cluster member cannot switch-over to an active cluster member.

.EXAMPLE
Restart-JS7ControllerInstance -Service

Restarts the JS7 Controller Windows service.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [Uri] $Url,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [ValidateSet('terminate','abort',IgnoreCase = $False)] [string] $Action = 'terminate',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $NoFailover,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
	[switch] $Service,
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

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }
	}

    Process
    {
        if ( $PSCmdlet.ShouldProcess( 'controller', 'Stop-JS7ControllerInstance' ) )
        {
            Stop-JS7ControllerInstance -Url $Url -Action $Action -Restart -NoFailover:$NoFailover -Service:$Service -AuditComment $AuditComment -AuditTimeSpent $AuditTimeSpent -AuditTicketLink $AuditTicketLink
        }
    }
}
