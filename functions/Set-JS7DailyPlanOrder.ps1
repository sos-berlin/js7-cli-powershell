function Set-JS7DailyPlanOrder
{
<#
.SYNOPSIS
Updates daily plan orders

.DESCRIPTION
The daily plan orders are updated for absolute or relative start times

The following REST Web Service API resources are used:

* /daily_plan/orders/modify

.PARAMETER OrderId
Specifies the Order ID of an existing daily plan order that should be updated.

.PARAMETER ControllerId
Specifies the identification of the Controller to which orders will be submitted.

.PARAMETER ScheduledFor
Optionally specifies the date and time that the order should start. The date can be specified in any time zone.

One of the -ScheduledFor or -RelativeScheduledFor arguments has to be used.

.PARAMETER RelativeScheduledFor
Specifies a relative period for which the daily plan order should be started, e.g.

* now: start immediately
* now+HH:MM[:SS]: start with the given delay of hours, minutes, seconds
* now+SECONDS: start with the given delay in seconds
* cur+HH:MM[:SS]: start the number of hours, minutes, seconds after the current start time
* cur+SECONDS: start the number of seconds after the current start time
* cur-HH:MM[:SS]: start the number of hours, minutes, seconds before the current start time
* cur-SECONDS: start the number of seconds before the current start time

The argument is used alternatively to the -ScheduledFor argument.

.PARAMETER Period
Specifies the period if a cyclic order should be updated. In addition to the order's start time, such orders hold a period definition.

The value for the -Period argument is returned when invoking the Get-JS7DailyPlanOrder cmdlet.
When used with the -RelativeScheduledFor argument, the period will be moved forward/backward accordingly:

Get-JS7Order -Folder /ProductDemo -Recursive -Scheduled | Get-JS7DailyPlanOrder -Cyclic | Set-JS7DailyPlanOrder -RelativeScheduledFor 'cur+03:00:00'



The value for the -Period argument can be created individually like this:

$Period = New-Object PSCustomObject
Add-Member -Membertype NoteProperty -Name 'begin' -value (Get-Date '2025-02-25 15:30:00') -InputObject $Period
Add-Member -Membertype NoteProperty -Name 'end' -value (Get-Date '2025-02-25 18:45:00') -InputObject $Period
Add-Member -Membertype NoteProperty -Name 'repeat' -value '00:30:00' -InputObject $Period

.PARAMETER Variables
Optionally specifies a hashtable of Variables

A hashtable object holds pairs of names and values. It can be created like this:
$variables = @{ 'var_1'='some string'; 'var_2' = 23; 'var_3' = true}

.PARAMETER RemoveVariables
Optionally specifies a list of variables that should be removed from the order.

.PARAMETER StartPosition
Optionally specifies the label of the first instruction in the workflow that the order should execute.

.PARAMETER EndPositions
Optionally specifies the list of labels corresponding to instructions in the workflow that the order should terminate with.

.PARAMETER BlockPosition
Optionally specifies the label of a block instruction in the workflow that the order should be started for.
The order will terminate with the end of the block instruction.

If the -StartPosition argument is used then the order will start from the indicated position in the block instruction.
If end positions are specified then the order will terminate with one of the end positions inside the block instruction.

.PARAMETER ForceJobSubmission
Specifies that admission times of jobs in the workflow will not be considered.

.PARAMETER KeepDailyPlanAssignment
Specifies that orders will remain assigned the original daily plan date in case that their start time is modified for
a date and time different from the original daily plan date.

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

.OUTPUTS
This cmdlet does not return any output.

.EXAMPLE
$orders = Get-JS7DailyPlanOrder -WorkflowFolder /ProductDemo -Recursive -NoCyclic -DateFrom 2025-02-25
$orders | Set-JS7DailyPlanOrder -RelativeScheduledFor 'cur+03:00:00' -KeepDailyPlanAssignment

Moves the start time of non-cyclic orders of the indicated daily plan date 3 hours ahead.

.EXAMPLE
$orders = Get-JS7DailyPlanOrder -WorkflowFolder /ProductDemo -Recursive -Cyclic -DateFrom 2025-02-25 | Get-JS7Order -Scheduled | Get-JS7DailyPlanOrder
$orders | Set-JS7DailyPlanOrder -RelativeScheduledFor 'cur+03:00:00'

Moves the start time of scheduled, cylic orders of today's daily plan date 3 hours ahead.

.EXAMPLE
Get-JS7DailyPlanOrder -DateFrom 2025-02-25 | Set-JS7DailyPlanOrder -RelativeScheduledFor 'cur-03:00:00'

Moves the start time of all orders of the indicated daily plan date 3 hours earlier.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $ScheduledFor,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [String] $RelativeScheduledFor,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [PSCustomObject] $Period,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [hashtable] $Variables,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $RemoveVariables,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $StartPosition,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $EndPositions,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $BlockPosition,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $ForceJobAdmission,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $KeepDailyPlanAssignment,
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

        if ( $ScheduledFor -and $RelativeScheduledFor )
        {
            throw 'only one of the -ScheduledFor and -RelativeScheduledFor arguments can be provided'
        }

        if ( $RelativeScheduledFor -and !$RelativeScheduledFor.startsWith('now') -and !$RelativeScheduledFor.startsWith('cur') )
        {
            throw "-RelativeScheduledFor argument syntactically must start with 'now', 'now+HH:MM[:SS]', 'cur+HH:MM[:SS]' or 'cur-HH:MM[:SS]'"
        }

        if ( $Period -and (!$Period.begin -or !$Period.end -or !$Period.repeat) )
        {
            throw "-Period argument requires to provide an object holding the 'begin', 'end' and 'repeat' properties"
        }
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter OrderID=$OrderID, ScheduledFor=$ScheduledFor, RelativeScheduledFor=$RelativeScheduledFor"

        if ( $RelativeScheduledFor )
        {
            $RelativeScheduledFor = $RelativeScheduledFor -replace "[ ]*"
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): updating daily plan for ScheduledFor=$ScheduledFor, RelativeScheduledFor=$RelativeScheduledFor"

        $body = New-Object PSObject

        if ( $ControllerId )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        }

        if ( $OrderId )
        {
            Add-Member -Membertype NoteProperty -Name 'orderIds' -value @($OrderId) -InputObject $body
        }

        if ( $RelativeScheduledFor -and $Period -and $Period.begin -and $Period.end )
        {
            $scheduledCycle = New-Object PSObject

            if ( $RelativeScheduledFor -eq 'now' )
            {
                Add-Member -Membertype NoteProperty -Name 'begin' -value ( Get-Date (Get-Date).ToUniversalTime() -Format 'HH:mm:ss' ) -InputObject $scheduledCycle
            } elseif ( $RelativeScheduledFor.startsWith('now+') ) {
                Add-Member -Membertype NoteProperty -Name 'begin' -value ( Get-Date ((Get-Date).ToUniversalTime() + ([TimeSpan]::Parse($RelativeScheduledFor.Substring(4))).toString("hh\:mm\:ss") ) -Format 'HH:mm:ss' ) -InputObject $scheduledCycle
            } elseif ( $RelativeScheduledFor.startsWith('cur+') ) {
                Add-Member -Membertype NoteProperty -Name 'begin' -value ( Get-Date ($Period.begin + ([TimeSpan]::Parse($RelativeScheduledFor.Substring(4))).toString("hh\:mm\:ss") ) -Format 'HH:mm:ss' ) -InputObject $scheduledCycle
            } elseif ( $RelativeScheduledFor.startsWith('cur-') ) {
                Add-Member -Membertype NoteProperty -Name 'begin' -value ( Get-Date ($Period.begin - ([TimeSpan]::Parse($RelativeScheduledFor.Substring(4))).toString("hh\:mm\:ss") ) -Format 'HH:mm:ss' ) -InputObject $scheduledCycle
            }

            if ( $RelativeScheduledFor -eq 'now' )
            {
                Add-Member -Membertype NoteProperty -Name 'end' -value ( Get-Date ((Get-Date).ToUniversalTime() + (New-TimeSpan -Start $Period.begin -End $Period.end).toString("hh\:mm\:ss") ) -Format 'HH:mm:ss' ) -InputObject $scheduledCycle
            } elseif ( $RelativeScheduledFor.startsWith( 'now+' ) ) {
                Add-Member -Membertype NoteProperty -Name 'end' -value ( Get-Date ((Get-Date).ToUniversalTime() + ([TimeSpan]::Parse($RelativeScheduledFor.Substring(4))).toString("hh\:mm\:ss") + (New-TimeSpan -Start $Period.begin -End $Period.end) ) -Format 'HH:mm:ss' ) -InputObject $scheduledCycle
            } elseif ( $RelativeScheduledFor.startsWith( 'cur+' ) ) {
                $ts = ([TimeSpan]::Parse((Get-Date $Period.end -Format 'HH:mm:ss')))
                $ts += ([TimeSpan]::Parse($RelativeScheduledFor.Substring(4)))
                Add-Member -Membertype NoteProperty -Name 'end' -value $ts.toString("hh\:mm\:ss") -InputObject $scheduledCycle
            } elseif ( $RelativeScheduledFor.startsWith( 'cur-' ) ) {
                $ts = ([TimeSpan]::Parse((Get-Date $Period.end -Format 'HH:mm:ss')))
                $ts -= ([TimeSpan]::Parse($RelativeScheduledFor.Substring(4)))
                Add-Member -Membertype NoteProperty -Name 'end' -value $ts.toString("hh\:mm\:ss") -InputObject $scheduledCycle
            }

            Add-Member -Membertype NoteProperty -Name 'repeat' -value ( "{0:hh\:mm\:ss}" -f $Period.repeat ) -InputObject $scheduledCycle
            Add-Member -Membertype NoteProperty -Name 'cycle' -value $scheduledCycle -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'scheduledFor' -value ( $OrderId | Select-String -Pattern "^#(\d{4}-\d{2}-\d{2})#" ).matches.groups[1].value -InputObject $body
        } else {
            if ( $RelativeScheduledFor )
            {
                Add-Member -Membertype NoteProperty -Name 'scheduledFor' -value $RelativeScheduledFor -InputObject $body
            } elseif ( $ScheduledFor ) {
                Add-Member -Membertype NoteProperty -Name 'scheduledFor' -value (Get-Date $ScheduledFor.ToUniversalTime() -Format 'yyyy-MM-dd HH:mm:ss') -InputObject $body
            }
        }

        if ( $Variables )
        {
            Add-Member -Membertype NoteProperty -Name 'variables' -value $Variables -InputObject $body
        }

        if ( $RemoveVariables )
        {
            Add-Member -Membertype NoteProperty -Name 'removeVariables' -value $RemoveVariables -InputObject $body
        }

        if ( $StartPosition )
        {
            Add-Member -Membertype NoteProperty -Name 'startPosition' -value $StartPosition -InputObject $body
        }

        if ( $EndPositions )
        {
            Add-Member -Membertype NoteProperty -Name 'endPositions' -value $EndPositions -InputObject $body
        }

        if ( $BlockPosition )
        {
            Add-Member -Membertype NoteProperty -Name 'blockPosition' -value $BlockPosition -InputObject $body
        }

        if ( $ForceJobAdmission )
        {
            Add-Member -Membertype NoteProperty -Name 'forceJobAdmission' -value ( $ForceJobAdmission -eq $True ) -InputObject $body
        }

        if ( $KeepDailyPlanAssignment )
        {
            Add-Member -Membertype NoteProperty -Name 'stickDailyPlanDate' -value ( $KeepDailyPlanAssignment -eq $True ) -InputObject $body
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

        if ( $PSCmdlet.ShouldProcess( 'orders', '/daily_plan/orders/modify' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/daily_plan/orders/modify' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $dailyPlanItems = ( $response.Content | ConvertFrom-Json ).orderIds
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }

            if ( $dailyPlanItems.count )
            {
                Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($dailyPlanItems.count) Daily Plan orders updated"
            } else {
                Write-Verbose ".. $($MyInvocation.MyCommand.Name): no Daily Plan orders updated"
            }
        }
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
