function Stop-JS7DailyPlanOrder
{
<#
.SYNOPSIS
Cancels daily plan orders from a number of JS7 Controllers

.DESCRIPTION
Cancels daily plan orders from a number of JS7 Controllers.

.PARAMETER OrderId
Optionally specifies the order ID of the daily plan order that should be cancelled.

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow for which daily plan orders should be cancelled.

.PARAMETER SchedulePath
Optionally specifies the path and name of a schedule for which daily plan orders should be cancelled.

.PARAMETER Folder
Optionally specifies the folder with workflows for which daily plan orders should be cancelled.

.PARAMETER Recursive
When used with the -Folder parameter then any sub-folders of the specified folder will be looked up.

.PARAMETER ControllerId
Specifies the Controller to which daily plan orders have been submitted and should be cancelled.

Without this parameter daily plan orders are cancelled from any Controllers that are deployed the
workflows that are indicated with the respective parameters.

.PARAMETER Late
Specifies that daily plan orders are cancelled that are late or that started later than expected.

.PARAMETER DateFrom
Optionally specifies the date starting from which daily plan orders should be cancelled.
Consider that a UTC date has to be provided.

Default: Begin of the current day as a UTC date

.PARAMETER DateTo
Optionally specifies the date until which daily plan orders should be cancelled.
Consider that a UTC date has to be provided.

Default: End of the current day as a UTC date

.PARAMETER RelativeDateFrom
Specifies a relative date starting from which daily plan orders should be cancelled, e.g.

* -1d, -2d: one day ago, two days ago
* +1d, +2d: one day later, two days later
* -1w, -2w: one week ago, two weeks ago
* +1w, +2w: one week later, two weeks later
* -1M, -2M: one month ago, two months ago
* +1M, +2M: one month later, two months later
* -1y, -2y: one year ago, two years ago
* +1y, +2y: one year later, two years later

Optionally a time offset can be specified, e.g. -1d+02:00, as otherwise midnight UTC is assumed.

This parameter takes precedence over the -DateFrom parameter.

.PARAMETER RelativeDateTo
Specifies a relative date until which daily plan orders should be cancelled, e.g.

* -1d, -2d: one day ago, two days ago
* +1d, +2d: one day later, two days later
* -1w, -2w: one week ago, two weeks ago
* +1w, +2w: one week later, two weeks later
* -1M, -2M: one month ago, two months ago
* +1M, +2M: one month later, two months later
* -1y, -2y: one year ago, two years ago
* +1y, +2y: one year later, two years later

Optionally a time offset can be specified, e.g. -1d+02:00, as otherwise midnight UTC is assumed.

This parameter takes precedence over the -DateTo parameter.

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
This cmdlet returns no output.

.EXAMPLE
Stop-JS7DailyPlanOrder -DateFrom "2020-12-31"

Cancels any daily plan orders for the given date.

.EXAMPLE
Stop-JS7DailyPlanOrder -DateTo (Get-Date).AddDays(3)

Cancels any daily plan orders starting from today until a date three days from now.

.EXAMPLE
Stop-JS7DailyPlanOrder -OrderId "#2020-11-19#P0000000498-orderSampleWorfklow2a"

Cancels the order with the given order ID from the daily plan.

.EXAMPLE
Stop-JS7DailyPlanOrder -WorkflowPath /some_folder/some_workflow

Cancels the daily plan orders for the indicated workflow in today's daily plan.

.LINK
about_js7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $SchedulePath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder = '/',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Late,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateFrom = (Get-Date (Get-Date).ToUniversalTime() -Format 'yyyy-MM-dd'),
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateTo,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeDateFrom,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeDateTo,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Pending,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $InProgress,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Running,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Blocked,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Finished,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Failed,
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

        $orderIds = @()
        $workflowPaths = @()
        $schedulePaths = @()
        $folders = @()
        $controllerIds = @()
        $states = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder, OrderId=$OrderId, WorkflowPath=$WorkflowPath, SchedulePath=$SchedulePath"

        if ( $Folder -and $Folder -ne '/' )
        {
            if ( !$Folder.startsWith( '/' ) ) {
                $Folder = '/' + $Folder
            }

            if ( $Folder.endsWith( '/' ) )
            {
                $Folder = $Folder.Substring( 0, $Folder.Length-1 )
            }
        }

        if ( $Folder -eq '/' -and !$WorkflowPath -and !$SchedulePath -and !$Late -and !$Recursive )
        {
            $Recursive = $True
        }


        if ( $OrderId )
        {
            $orderIds += $OrderId
        }

        if ( $WorkflowPath )
        {
            $workflowPaths += $WorkflowPath
        }

        if ( $SchedulePath )
        {
            $schedulePaths += $SchedulePath
        }

        if ( $Folder -ne '/' )
        {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $objFoldere
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $objFolder
            $folders += $objFolder
        }

        if ( $ControllerId )
        {
            $controllerIds += $ControllerId
        }

        if ( $Pending )
        {
            $states += 'PENDING'
        }

        if ( $InProgress )
        {
            $states += 'INPROGRESS'
        }

        if ( $Running )
        {
            $states += 'RUNNING'
        }

        if ( $Blocked )
        {
            $states += 'BLOCKED'
        }

        if ( $Finished )
        {
            $states += 'FINISHED'
        }

        if ( $Failed )
        {
            $states += 'FAILED'
        }
    }

    End
    {
        if ( $RelativeDateFrom )
        {
            $dateDirection = $RelativeDateFrom[0]
            $dateRange = $RelativeDateFrom.Substring( 1, $RelativeDateFrom.Length-2 )
            $dateUnit = $RelativeDateFrom[$RelativeDateFrom.Length-1]

            switch( $dateUnit )
            {
                'd' { $dailyPlanDateFrom = (Get-Date).AddDays( "$($dateDirection)$($dateRange)" ) }
                'w' { $dailyPlanDateFrom = (Get-Date).AddDays( "$($dateDirection)$([int]$dateRange*7)" ) }
                'm' { $dailyPlanDateFrom = (Get-Date).AddMonths( "$($dateDirection)$($dateRange)" ) }
                'y' { $dailyPlanDateFrom = (Get-Date).AddYears( "$($dateDirection)$($dateRange)" ) }
            }
        } else {
            $dailyPlanDateFrom = Get-Date (Get-Date $DateFrom)
        }

        if ( $RelativeDateTo )
        {
            $dateDirection = $RelativeDateTo[0]
            $dateRange = $RelativeDateTo.Substring( 1, $RelativeDateTo.Length-2 )
            $dateUnit = $RelativeDateTo[$RelativeDateTo.Length-1]

            switch( $dateUnit )
            {
                'd' { $dailyPlanDateTo = (Get-Date).AddDays( "$($dateDirection)$($dateRange)" ) }
                'w' { $dailyPlanDateTo = (Get-Date).AddDays( "$($dateDirection)$([int]$dateRange*7)" ) }
                'm' { $dailyPlanDateTo = (Get-Date).AddMonths( "$($dateDirection)$($dateRange)" ) }
                'y' { $dailyPlanDateTo = (Get-Date).AddYears( "$($dateDirection)$($dateRange)" ) }
            }
        } else {
            if ( !$DateTo )
            {
                $DateTo = $dailyPlanDateFrom
            }

            $dailyPlanDateTo = Get-Date (Get-Date $DateTo)
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): removing daily plan orders for date range $dailyPlanDateFrom - $dailyPlanDateTo"
        $loops = 0

        for( $day=$dailyPlanDateFrom; $day -le $dailyPlanDateTo; $day=$day.AddDays(1) )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

            $filter = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'dailyPlanDate' -value (Get-Date $day -Format 'yyyy-MM-dd') -InputObject $filter

            if ( $orderIds )
            {
                Add-Member -Membertype NoteProperty -Name 'orderIds' -value $orderIds -InputObject $filter
            }

            if ( $workflowPaths )
            {
                Add-Member -Membertype NoteProperty -Name 'workflowPaths' -value $workflowPaths -InputObject $filter
            }

            if ( $schedulePaths )
            {
                Add-Member -Membertype NoteProperty -Name 'schedulePaths' -value $schedulePaths -InputObject $filter
            }

            if ( $folders )
            {
                Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $filter
            }

            if ( $controllerIds )
            {
                Add-Member -Membertype NoteProperty -Name 'controllerIds' -value $controllerIds -InputObject $filter
            }

            if ( $Late )
            {
                Add-Member -Membertype NoteProperty -Name 'late' -value ( $Late -eq $True ) -InputObject $filter
            }

            if ( $states )
            {
                Add-Member -Membertype NoteProperty -Name 'states' -value $states -InputObject $filter
            }

            if ( $filter )
            {
               Add-Member -Membertype NoteProperty -Name 'filter' -value $filter -InputObject $body
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

            if ( $PSCmdlet.ShouldProcess( $Path, '/daily_plan/orders/cancel' ) )
            {
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/daily_plan/orders/cancel' -Body $requestBody

                if ( $response.StatusCode -eq 200 )
                {
                    $requestResult = ( $response.Content | ConvertFrom-Json )

                    if ( !$requestResult.ok )
                    {
                        throw ( $response | Format-List -Force | Out-String )
                    }
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }
            }

            $loops++
        }

        if ( $loops )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): Daily Plan orders cancelled"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no Daily Plan orders cancelled"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
