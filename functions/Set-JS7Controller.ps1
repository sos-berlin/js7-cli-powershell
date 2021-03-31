function Set-JS7Controller
{
<#
.SYNOPSIS
Tests the connection to a JS7 Controller instance

.DESCRIPTION
The cmdlets tests the connection between JOC Cockpit and a Controller instance.
A standalone Controller instance or the active or passive member of a Controller cluster can be
tested to be accessible.

.PARAMETER Url
Specifies the Url of the Controller instance to be tested.

Without use of this parameter and the -Passive parameter
a standalone Controller instance or the active member of a Controller cluster is checked.

.PARAMETER Passive
Specifies that the passive member of Controller cluster should be be tested.

Without use of this parameter and the -Url parameter
a standalone Controller instance or the active member of a Controller cluster is checked.

.OUTPUTS
This cmdlet returns status information about a Controller.

.EXAMPLE
$result = Test-JS7ControllerInstance

Checks if a standalone Controller instance or the active member of a Controller cluster is accessible.

.EXAMPLE
$result = Test-JS7ControllerInstance -Passive

Checks if the passive member of a Controller cluster is accessible.

.EXAMPLE
$result = Test-JS7ControllerInstance -Url (Get-JS7ControllerInstance -Active).active.url

Checks if the Controller instance from the given URL is accessible.

.LINK
about_js7

#>
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
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value "" -InputObject $body
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
