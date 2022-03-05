function Restart-JS7ControllerInstance
{
<#
.SYNOPSIS
Restarts a JS7 Controller Instance

.DESCRIPTION
A JS7 Controller instance is restarted. In a JS7 cluster by default a fail-over
to the passive cluster member is performed.

.PARAMETER Url
Optionally the Url of the Controller to be restarted can be specified.
Without this parameter the active Controller will be restarted.
Consider that restarting a passive Controller in a JS7 cluster cannot perform
a fail-over as the current cluster member is passive.

.PARAMETER Action
Restarting a Controller includes the following actions:

* Action 'terminate' (Default)
** no new tasks are started.
** running tasks are continued to complete:
*** shell jobs will continue until their normal termination.
*** API jobs complete a current spooler_process() call.
** JS7 Controller terminates normally.

* Action 'abort'
** no new tasks are started.
** any running tasks are killed.
** JS7 Controller terminates normally.

.PARAMETER NoFailover
This switch prevents a fail-over to happen when restarting the active Controller
in a cluster. Instead, the restarted Controller will remain the active cluster member.

.PARAMETER Service
Retarts the JS7 Windows service.

Without this parameter being specified JS7 will be started in
its respective operating mode, i.e. service mode or dialog mode.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of JOC Cockpit.
This parameter is not mandatory, however, JOC Cockpit can be configured to enforce Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is visible with the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JS7.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JS7.

This information is visible with the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JS7.

.EXAMPLE
Restart-JS7ControllerInstance

Terminates and restarts the JS7 Controller. In a cluster the active cluster member is restarted
and a fail-over takes place to the passive cluster member. Use -of the -NoFailover switch prevents
the switch-over.

.EXAMPLE
Restart-JS7ControllerInstance -Url (Get-JS7ControllerStatus).Active.Url

Retarts the JS7 Controller active cluster member or standalone instance.

.EXAMPLE
Restart-JS7ControllerInstance -Url (Get-JS7ControllerStatus).Passive.Url -NoFailover

Retarts the JS7 Controller passive cluster member. Consider use of the -NoFailover switch
as a passive cluster member cannot switch-over to an active cluster member.

.EXAMPLE
Restart-JS7ControllerInstance -Service

Retarts the JS7 Controller Windows service.

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
