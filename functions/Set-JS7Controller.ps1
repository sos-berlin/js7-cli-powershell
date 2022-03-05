function Set-JS7Controller
{
<#
.SYNOPSIS
Registers a Controller and Agents

.DESCRIPTION
The cmdlet registers a Controller either for a Standalone Controller instance or for
a primary and a secondary Controller Cluster instance.
A Controller Cluster requires an Agent to be added that acts as a cluster watcher.

The following REST Web Service API resources are used:

* /controller/register

.PARAMETER Controller
Specifies an array of Controller instances that will be added:

* For a Standalone Controller a single instance is specified
* For a Controller Cluster a primary instance and a secondary instance are specified

Controller instance objects can be created from the New-JS7ControllerInstance cmdlet.

.PARAMETER AgentId
A JS7 Controller cluster requires a one Agent to be assigned the role of a cluster watcher.
Such an Agent will be considered if the JS7 Controller cluster decides about a fail-over situation with
no network connection being available between primary and secondary JS7 Controller instances.

Therefore this setting is not considered when adding a Standalone Controller.

The parameter specifies a unique identifier for an Agent. This identifier cannot be modified during the lifetime of an Agent.
In order to modify the Agent identifier the Agent has to be terminated and
journals have to be cleaned up.

.PARAMETER AgentName
The name of an Agent is used e.g. in job assignments of a workflow. During deployment the Agent Name
is replaced by the respective Agent ID for the Controller to which the workflow is deployed.

Should deployments of the same workflows be performed to a number of Controllers then for each Controller
the same Agent Name has to be configured (pointing to a different Agent ID from Agents' alias names).

.PARAMETER AgentUrl
Specifies the URL for which the Agent is available. A URL includes the protocol (http, https), hostname and port
for which an Agent is operated.

.PARAMETER ControllerId
Specifies the Controller ID that should be used if an existing Controller is re-registered.
When adding Controllers the ControllerID should be empty, when updating Controllers the Controller ID has to be specified.

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

.OUTPUTS
This cmdlet does not return any output.

.EXAMPLE
Set-JS7Controller -Controller ( New-JS7ControllerInstance -Url https://controller-standalone.sos:4443 -Title 'STANDALONE CONTROLLER' )

Adds a Standalone Controller to JOC Cockpit that is identified by its Url.

.EXAMPLE
Set-JS7Controller -Controller ( New-JS7ControllerInstance -Url https://controller-standalone.sos:4443 -Title 'SOLO CONTROLLER' ) -ControllerId jobscheduler

Updates an existing Standalone Controller that is identified by its Url to a different URL or title.

.EXAMPLE
$primary = New-JS7ControllerInstance -Url https://controller-primary.sos:4443 -Title 'PRIMARY CONTROLLER'
$secondary = New-JS7ControllerInstance -Url https://controller-secondary.sos:4443 -Title 'SECONDARY CONTROLLER'
Set-JS7Controller -Controller $primary,$secondary -AgentId 'agent_001' -AgentName 'primaryAgent' -AgentUrl https://agent-primary.sos:4443

Creates two cluster members and adds the Controller Cluster to JOC Cockpit.
In addition, an Agent is added that acts as cluster watch.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [PSObject[]] $Controller,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $AgentId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $AgentName,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [Uri] $AgentUrl,
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
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'controllers' -value $Controller -InputObject $body

        if ( $AgentId )
        {
            $objAgent = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'agentId' -value $AgentId -InputObject $objAgent
            Add-Member -Membertype NoteProperty -Name 'agentName' -value $AgentName -InputObject $objAgent
            Add-Member -Membertype NoteProperty -Name 'url' -value $AgentUrl -InputObject $objAgent

            Add-Member -Membertype NoteProperty -Name 'clusterWatcher' -value $objAgent -InputObject $body
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


        if ( $PSCmdlet.ShouldProcess( 'controller', '/controller/register' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/controller/register' -Body $requestBody

            if ( !$response.StatusCode -eq 200 )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        }
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
