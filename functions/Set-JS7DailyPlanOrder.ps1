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
Optionally specifies the date and time that the order should start.

One of the arguments -ScheduledFor or -RelativeScheduledFor has to be used.

.PARAMETER RelativeScheduledFor
Specifies a relative date for which the daily plan order should be started, e.g.

* +1d, +2d: one day later, two days later
* +1w, +2w: one week later, two weeks later
* +1M, +2M: one month later, two months later
* +1y, +2y: one year later, two years later

Optionally a time offset can be specified, e.g. +1d+02:00, as otherwise midnight UTC is assumed.

This argument is used alternatively to the -ScheduledFor argument.

.PARAMETER ScheduledDate
Optionally specifies a time for which the order will be started on the given day.
The order will use the date specified by the -ScheduledFor or -RelativeScheduledFor arguments, and it will use the time specified by this argument.

The time is specified from a string in the hh:mm:ss format like this:

* 23:12:59

Only one of the arguments -ScheduledTime and -RelativeScheduledTime can be used.

.PARAMETER RelativeScheduledTime
Optionally specifies an offset to the existing time for which the order will be started on the given day.
The order will use the existing date to which the offset specified by this argument will be added or from which it will be substracted.

The time offset is specified from a string in the hh:mm:ss format like this:

* Adding 2 hours and 45 minutes to the start time: +02:45:00
* Subtracting 9 hours and 30 minutes from the start time: -09:30:00

.PARAMETER Cycle
Specifies the cycle if a cyclic order is updated.

In addition to the order's start time specified by the -ScheduledFor argument such orders hold a cycle definition.

The value for the -Cycle argument can be created like this:

$cycle = New-Object PSCustomObject
Add-Member -Membertype NoteProperty -Name 'begin' -value '15:30:00' -InputObject $cycle
Add-Member -Membertype NoteProperty -Name 'end' -value '18:45:00' -InputObject $cycle
Add-Member -Membertype NoteProperty -Name 'repeat' -value '00:30:00' -InputObject $cycle

.PARAMETER Variables
Optionally specifies a hashtable of Variables

A hashtable object holds pairs of names and values. It can be created like this:
$variables = @{ 'var_1'='some string'; 'var_2' = 23; 'var_3' = true}

.PARAMETER RemoveVariables
Optionally specifies a list of variables that should be removed from the order.

.PARAMETER startPosition
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
This cmdlet returns an array of daily plan orders.

.EXAMPLE
$orders = Get-JS7DailyPlanOrder
Set-JS7DailyPlanOrder -OrderId $orders[0].orderId -ScheduledFor $orders[0].plannedStartTime -RelativeScheduledTime '+03:00:00'

Moves the start time of a non-cyclic order of the current daily plan date 3 hours forward.

.EXAMPLE
$orders = Get-JS7DailyPlanOrder
Set-JS7DailyPlanOrder -OrderId $orders[0].orderId -ScheduledFor $orders[0].plannedStartTime -RelativeScheduledTime '-03:00:00' -Cycle $orders[0].period

Moves the start time of a cyclic order of the current daily plan date 3 hours back.

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
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $ScheduledDate,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [String] $RelativeScheduledDate,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [String] $RelativeScheduledTime,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [PSCustomObject] $Cycle,
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

        if ( !$ScheduledFor -and !$RelativeScheduledFor -and !$RelativeScheduledDate)
        {
            throw 'one of the arguments -ScheduledFor, -RelativeScheduledFor and -RelativeScheduledDate has to be used'
        }

        if ( $ScheduledFor -and $RelativeScheduledFor )
        {
            throw 'only one of the arguments -ScheduledFor and -RelativeScheduledFor can be used'
        }

        $orderIds = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter OrderID=$OrderID"

        if ( $OrderId )
        {
            $orderIds += $OrderId
        }
    }

    End
    {
        if ( $RelativeScheduledFor )
        {
            $dateDirection = $RelativeScheduledFor[0]
            $dateRange = $RelativeScheduledFor.Substring( 1, $RelativeScheduledFor.Length-2 )
            $dateUnit = $RelativeScheduledFor[$RelativeScheduledFor.Length-1]

            switch( $dateUnit )
            {
                'd' { $dailyPlanScheduledFor = (Get-Date).AddDays( "$($dateDirection)$($dateRange)" ) }
                'w' { $dailyPlanScheduledFor = (Get-Date).AddDays( "$($dateDirection)$([int]$dateRange*7)" ) }
                'm' { $dailyPlanScheduledFor = (Get-Date).AddMonths( "$($dateDirection)$($dateRange)" ) }
                'y' { $dailyPlanScheduledFor = (Get-Date).AddYears( "$($dateDirection)$($dateRange)" ) }
            }
        } else {
            $dailyPlanScheduledFor = Get-Date (Get-Date $ScheduledFor)
        }

        if ( $ScheduledDate )
        {
            $dailyPlanScheduledFor = Get-Date $dailyPlanScheduledFor -Year (Get-Date $ScheduledDate).Year -Month (Get-Date $ScheduledDate).Month -Day (Get-Date $ScheduledDate).Day
        }

        if ( $RelativeScheduledDate )
        {
            $dateDirection = $RelativeScheduledDate[0]
            $dateRange = $RelativeScheduledDate.Substring( 1, $RelativeScheduledDate.Length-2 )
            $dateUnit = $RelativeScheduledDate[$RelativeScheduledDate.Length-1]

            switch( $dateUnit )
            {
                'd' { $dailyPlanScheduledFor = $dailyPlanScheduledFor.AddDays( "$($dateDirection)$($dateRange)" ) }
                'w' { $dailyPlanScheduledFor = $dailyPlanScheduledFor.AddDays( "$($dateDirection)$([int]$dateRange*7)" ) }
                'm' { $dailyPlanScheduledFor = $dailyPlanScheduledFor.AddMonths( "$($dateDirection)$($dateRange)" ) }
                'y' { $dailyPlanScheduledFor = $dailyPlanScheduledFor.AddYears( "$($dateDirection)$($dateRange)" ) }
            }
        }

        if ( $RelativeScheduledTime )
        {
            $dateDirection = $RelativeScheduledTime[0]
            $dailyPlanScheduledFor = $dailyPlanScheduledFor.AddHours( "$($dateDirection)$($RelativeScheduledTime.Substring( 1, 2 ))" )
            $dailyPlanScheduledFor = $dailyPlanScheduledFor.AddMinutes( "$($dateDirection)$($RelativeScheduledTime.Substring( 4, 2 ))" )
            $dailyPlanScheduledFor = $dailyPlanScheduledFor.AddSeconds( "$($dateDirection)$($RelativeScheduledTime.Substring( 7, 2 ))" )
        } else {
            $dailyPlanScheduledFor = Get-Date $dailyPlanScheduledFor
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): updating daily plan for date $dailyPlanScheduledFor"

        $body = New-Object PSObject

        if ( $ControllerId )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $boldy
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        }

        Add-Member -Membertype NoteProperty -Name 'scheduledFor' -value ( Get-Date (Get-Date $dailyPlanScheduledFor).ToUniversalTime() -Format 'yyyy-MM-dd HH:mm:ss' ) -InputObject $body

        if ( $orderIds )
        {
            Add-Member -Membertype NoteProperty -Name 'orderIds' -value $orderIds -InputObject $body
        }

        if ( $Cycle )
        {
            $scheduledCycle = New-Object PSObject
            if ( $Cycle.begin )
            {
                if ( $RelativeScheduledTime )
                {
                    $ts = ([TimeSpan]::Parse($Cycle.begin.Substring(11, 8)))

                    if ( $RelativeScheduledTime[0] -eq '-' )
                    {
                        $ts -= ([TimeSpan]::Parse($RelativeScheduledTime.Substring(1)))
                    } else {
                        $ts += ([TimeSpan]::Parse($RelativeScheduledTime.Substring(1)))
                    }

                    Add-Member -Membertype NoteProperty -Name 'begin' -value $ts.toString("hh\:mm\:ss") -InputObject $scheduledCycle
                } else {
                    Add-Member -Membertype NoteProperty -Name 'begin' -value $Cycle.begin.Substring(11, 8) -InputObject $scheduledCycle
                }
            }

            if ( $Cycle.end )
            {
                if ( $RelativeScheduledTime )
                {
                    $ts = ([TimeSpan]::Parse($Cycle.end.Substring(11, 8)))

                    if ( $RelativeScheduledTime[0] -eq '-' )
                    {
                        $ts -= ([TimeSpan]::Parse($RelativeScheduledTime.Substring(1)))
                    } else {
                        $ts += ([TimeSpan]::Parse($RelativeScheduledTime.Substring(1)))
                    }

                    Add-Member -Membertype NoteProperty -Name 'end' -value $ts.toString("hh\:mm\:ss") -InputObject $scheduledCycle
                } else {
                    Add-Member -Membertype NoteProperty -Name 'end' -value $Cycle.end.Substring(11, 8) -InputObject $scheduledCycle
                }
            }

            Add-Member -Membertype NoteProperty -Name 'repeat' -value ( "{0:hh\:mm\:ss}" -f ([timespan]::fromseconds($Cycle.repeat)) ) -InputObject $scheduledCycle

            Add-Member -Membertype NoteProperty -Name 'cycle' -value $scheduledCycle -InputObject $body
        }

        if ( $Variables )
        {
            Add-Member -Membertype NoteProperty -Name 'variables' -value $Variables -InputObject $body
        }

        if ( $RemoveVariables )
        {
            Add-Member -Membertype NoteProperty -Name 'removeVariables' -value @($RemoveVariables) -InputObject $body
        }

        if ( $StartPosition )
        {
            Add-Member -Membertype NoteProperty -Name 'startPosition' -value $StartPosition -InputObject $body
        }

        if ( $EndPosition )
        {
            Add-Member -Membertype NoteProperty -Name 'endPositions' -value @($EndPositions) -InputObject $body
        }

        if ( $BlockPosition )
        {
            Add-Member -Membertype NoteProperty -Name 'blockPosition' -value $BlockPosition -InputObject $body
        }

        if ( $ForceJobAdmission )
        {
            Add-Member -Membertype NoteProperty -Name 'forceJobAdmission' -value ( $ForceJobAdmission -eq $True ) -InputObject $body
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
                $dailyPlanItems = ( $response.Content | ConvertFrom-JSON ).orderIds
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

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
