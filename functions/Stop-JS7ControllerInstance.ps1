function Stop-JS7ControllerInstance
{
<#
.SYNOPSIS
Stops a JS7 Controller instance.

.DESCRIPTION
The stop of a Controller instance is performed and optionally the instance fails over
to the passive cluster member in a JS7 Controller cluster.

.PARAMETER Url
Optionally the Url of the Controller instance to be stopped can be specified.
Without this parameter the active Controller will be stopped.
Consider that stopping a passive Controller in a JS7 cluster cannot perform
a fail-over as the current cluster member instance is passive.

.PARAMETER Action
Stopping includes the following actions:

* Action "terminate" (Default)
** no new tasks are started.
** running tasks are continued to complete:
*** shell jobs will continue until their normal termination.
*** API jobs complete a current spooler_process() call.
** Controller terminates normally.

* Action "abort"
** no new tasks are started.
** any running tasks are killed.
** Controller terminates normally.

.PARAMETER Restart
When used with the operations -Action 'terminate' and 'abort' then the
Controller instance will shut down and restart.

This switch provides the same capabilities as the Restart-JS7Controller cmdlet.

.PARAMETER NoFailover
This switch prevents a fail-over to happen when stopping the active Controller
in a cluster. Instead, the restarted Controller will remain the active cluster instance.

.PARAMETER Service
Stops the Controller Windows Service

Use of this parameter ignores any other parameters.
The Windows service is stopped as specified with -Action "terminate".
No timeout and no cluster operations are applied.

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

.EXAMPLE
Stop-JS7ControllerInstance

Stops a standalone JobScheduler Controller instance or active Cluster instance with normal termination.
In a JS7 cluster a fail-over takes place unless the -NoFailover switch is used.

.EXAMPLE
Stop-JS7ControllerInstance -Action 'abort'

Aborts a standalone JobScheduler Controller instance or active Cluster instance.
In a JS7 cluster a fail-over takes place unless the -NoFailover switch is used.

.EXAMPLE
Stop-JS7ControllerInstance -Url (Get-JS7Status.Passive.Url)

Stops a passive JS7 Controller instance with normal termination.

.EXAMPLE
Stop-JS7ControllerInstance -Url (Get-JS7Status).Passive.Url) -Restart

Restarts a JS7 Controller instance that is the passive member in a cluster.

.EXAMPLE
Stop-JS7ControllerInstance -Service

Stops the JS7 Controller Windows Service with normal termination,
i.e. with -Action 'terminate'.

.EXAMPLE
Stop-JS7ControllerInstance -Action 'abort' -Restart

Aborts a standalone JS7 Controller instance or the active member of a cluster.
A fail-over to the passive cluser instance takes place.
After shutdown the JS7 Controller instance is restarted.

.LINK
about_js7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [Uri] $Url,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('terminate','abort')] [string] $Action = 'terminate',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Restart,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $NoFailover,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
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
        $stopWatch = Start-JS7StopWatch

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }
    }

    Process
    {
        if ( !$Url -and !$Service )
        {
            $Url = (Get-JS7ControllerInstance).Active.Url
        }

        if ( $Service )
        {
            $serviceInstance = $null
            $serviceName = $js.Service.ServiceName

            # Check an existing service
            try
            {
                $serviceInstance = Get-Service $serviceName -ErrorAction SilentlyContinue
            } catch {
                throw "$($MyInvocation.MyCommand.Name): could not find service: $($_.Exception.Message)"
            }

            # stop an existing service
            try
            {
                if ( $serviceInstance -and $serviceInstance.Status -eq "running" )
                {
                    Write-Verbose ".. $($MyInvocation.MyCommand.Name): stop Controller service: $($serviceName)"
                    if ( $PSCmdlet.ShouldProcess( $serviceName, 'stop service' ) )
                    {
                        Stop-Service -Name $serviceName | Out-Null
                        Start-Sleep -Seconds 3
                    }
                }
            } catch {
                throw "$($MyInvocation.MyCommand.Name): could not stop service: $($_.Exception.Message)"
            }

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): Controller service stopped: $($serviceName)"
        } else {
            $resource = $null
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

            switch ( $Action )
            {
                'terminate'
                {
                    if ( $Restart )
                    {
                        $resource = '/controller/restart'
                    } else {
                        $resource = '/controller/terminate'
                    }
                }
                'abort'
                {
                    if ( $Restart )
                    {
                        $resource = '/controller/abort_and_restart'
                    } else {
                        $resource = '/controller/abort'
                    }
                }
            }

            if ( $resource )
            {
                if ( $Url )
                {
                    Add-Member -Membertype NoteProperty -Name 'url' -value $Url -InputObject $body
                }

                if ( $NoFailover )
                {
                    Add-Member -Membertype NoteProperty -Name 'withFailover' -value $false -InputObject $body
                } else {
                    Add-Member -Membertype NoteProperty -Name 'withFailover' -value $true -InputObject $body
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

                if ( $PSCmdlet.ShouldProcess( 'controller', $resource ) )
                {
                    [string] $requestBody = $body | ConvertTo-Json -Depth 100
                    $response = Invoke-JS7WebRequest -Path $resource -Body $requestBody

                    if ( $response.StatusCode -eq 200 )
                    {
                        $requestResult = ( $response.Content | ConvertFrom-JSON )

                        if ( !$requestResult.ok )
                        {
                            throw ( $response | Format-List -Force | Out-String )
                        }

                        Write-Verbose ".. $($MyInvocation.MyCommand.Name): command resource for Controller: $resource"
                    } else {
                        throw ( $response | Format-List -Force | Out-String )
                    }
                }
            }
        }
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
