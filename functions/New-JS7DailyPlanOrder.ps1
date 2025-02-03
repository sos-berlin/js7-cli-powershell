function New-JS7DailyPlanOrder
{
<#
.SYNOPSIS
Creates daily plan orders for a number of JS7 Controllers

.DESCRIPTION
Creates daily plan orders for a number of JS7 Controllers. Orders can be submitted to any
JS7 Controllers that are deployed the respective workflows.

The following REST Web Service API resources are used:

* /daily_plan/orders/generate

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow for which daily plan orders should be created.

.PARAMETER WorkflowFolder
Optionally specifies a folder with schedules for which daily plan orders should be created.

.PARAMETER SchedulePath
Optionally specifies the path and name of a schedule for which daily plan orders should be created.

.PARAMETER ScheduleFolder
Optionally specifies a folder with schedules for which daily plan orders should be created.

.PARAMETER Recursive
When used with the -WorkflowFolder or -ScheduleFolder parameters then any sub-folders are looked up recursively
for workflows or schedules for which to create orders.

.PARAMETER ControllerId
Specifies the Controller to which daily plan orders are submitted should the -Submit switch be used.

Without this parameter daily plan orders are submitted to any Controllers that are deployed together with the
workflows that are indicated with their respective schedules.

.PARAMETER Overwrite
Specifies to overwrite daily plan orders for the same date and schedule.

If such orders exist with a Controller and the -Submit parameter is used then they are cancelled and re-created.

.PARAMETER Submit
Specifies to immediately submit the daily plan orders to a JS7 Controller.

.PARAMETER NonAutoPlanned
Specifies thtat orders will be created from schedules that are not configured for automated planning of orders.

.PARAMETER DateFrom
Optionally specifies the date starting from which daily plan orders should be created.

Default: The current day in the local time zone

.PARAMETER DateTo
Optionally specifies the date until which daily plan orders should be created.

Default: The current day in the local time zone

.PARAMETER RelativeDateFrom
Specifies a relative date starting from which daily plan orders should be created, e.g.

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
Specifies a relative date until which daily plan orders should be created, e.g.

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
This cmdlet returns no output.

.EXAMPLE
New-JS7DailyPlanOrder -DateFrom "2020-12-31" -ControllerId Controller

Creates daily plan orders from any schedules for the given day that
make use of workflows deployed to the indicated Controller.

.EXAMPLE
New-JS7DailyPlanOrder -DateFrom "2020-12-15" -DateTo "2020-12-31" -Submit -Overwrite

Creates daily plan orders from any schedules for the given date range and submits
them to any Controllers that are deployed the respective workflows.

.EXAMPLE
New-JS7DailyPlanOrder -DateTo (Get-Date).AddDays(3) -SchedulePath /daily/eod

Creates daily plan orders from the indicated schedule starting from today until a date three days from now.

.EXAMPLE
New-JS7DailyPlanOrder -DateFrom "2020-12-31" -Folder /daily -Recursive

Creates daily plan orders for the given date from schedules that are available with the
indicated folder and any sub-folders recursively.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowFolder,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $SchedulePath,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ScheduleFolder,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Overwrite,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Submit,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $NonAutoPlanned,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateFrom = (Get-Date),
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateTo,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeDateFrom,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeDateTo,
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

        $schedulePaths = @()
        $scheduleFolders = @()
        $workflowPaths = @()
        $workflowFolders = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter WorkflowFolder=$WorkflowFolder, WorkflowPath=$WorkflowPath, SchedulePath=$SchedulePath, ScheduleFolder=$ScheduleFolder"

        if ( $WorkflowFolder -and $WorkflowFolder -ne '/' )
        {
            if ( !$WorkflowFolder.StartsWith( '/' ) )
            {
                $WorkflowFolder = '/' + $WorkflowFolder
            }

            if ( $WorkflowFolder.EndsWith( '/' ) )
            {
                $WorkflowFolder = $WorkflowFolder.Substring( 0, $WorkflowFolder.Length-1 )
            }
        }

        if ( $ScheduleFolder -and $ScheduleFolder -ne '/' )
        {
            if ( !$ScheduleFolder.StartsWith( '/' ) )
            {
                $ScheduleFolder = '/' + $ScheduleFolder
            }

            if ( $ScheduleFolder.EndsWith( '/' ) )
            {
                $ScheduleFolder = $ScheduleFolder.Substring( 0, $ScheduleFolder.Length-1 )
            }
        }


        if ( $WorkflowPath )
        {
            $workflowPaths += $WorkflowPath
        }

        if ( $WorkflowFolder )
        {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $WorkflowFolder -InputObject $objFolder
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $objFolder

            $workflowFolders += $objFolder
        }

        if ( $SchedulePath )
        {
            $schedulePaths += $SchedulePath
        }

        if ( $ScheduleFolder )
        {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $ScheduleFolder -InputObject $objFolder
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $objFolder

            $scheduleFolders += $objFolder
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

            $dailyPlanDateFrom = Get-Date $dailyPlanDateFrom -Format 'yyyy-MM-dd'
        } else {
            $dailyPlanDateFrom = Get-Date $DateFrom -Format 'yyyy-MM-dd'
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

            $dailyPlanDateTo = Get-Date $dailyPlanDateTo -Format 'yyyy-MM-dd'
        } else {
            if ( !$DateTo )
            {
                $dailyPlanDateTo = Get-Date $dailyPlanDateFrom -Format 'yyyy-MM-dd'
            } else {
                $dailyPlanDateTo = Get-Date $DateTo -Format 'yyyy-MM-dd'
            }
        }

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): removing daily plan orders for date range $dailyPlanDateFrom - $dailyPlanDateTo"
        $loops = 0

        for( $day=(Get-Date $dailyPlanDateFrom); $day -le (Get-Date $dailyPlanDateTo); $day=(Get-Date $day).AddDays(1) )
        {
            $body = New-Object PSObject

            if ( $ControllerId )
            {
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
            } else {
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            }

            Add-Member -Membertype NoteProperty -Name 'dailyPlanDate' -value (Get-Date $day -Format 'yyyy-MM-dd') -InputObject $body

            if ( $workflowPaths -or $workflowFolders )
            {
                $workflowPathsObj = New-Object PSObject

                if ( $workflowPaths )
                {
                    Add-Member -Membertype NoteProperty -Name 'singles' -value $workflowPaths -InputObject $workflowPathsObj
                }

                if ( $workflowFolders )
                {
                    Add-Member -Membertype NoteProperty -Name 'folders' -value $workflowFolders -InputObject $workflowPathsObj
                }

                Add-Member -Membertype NoteProperty -Name 'workflowPaths' -value $workflowPathsObj -InputObject $body
            }

            if ( $schedulePaths -or $scheduleFolders )
            {
                $schedulePathsObj = New-Object PSObject

                if ( $schedulePaths )
                {
                    Add-Member -Membertype NoteProperty -Name 'singles' -value $schedulePaths -InputObject $schedulePathsObj
                }

                if ( $scheduleFolders )
                {
                    Add-Member -Membertype NoteProperty -Name 'folders' -value $scheduleFolders -InputObject $schedulePathsObj
                }

                Add-Member -Membertype NoteProperty -Name 'schedulePaths' -value $schedulePathsObj -InputObject $body
            }

            Add-Member -Membertype NoteProperty -Name 'overwrite' -value ($Overwrite -eq $True) -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'withSubmit' -value ($Submit -eq $True) -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'includeNonAutoPlannedOrders' -value ($NonAutoPlanned -eq $True) -InputObject $body

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

            if ( $PSCmdlet.ShouldProcess( 'orders', '/daily_plan/orders/generate' ) )
            {
                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/daily_plan/orders/generate' -Body $requestBody

                if ( $response.StatusCode -eq 200 )
                {
                    $requestResult = ( $response.Content | ConvertFrom-JSON )

                    if ( !$requestResult.ok )
                    {
                        throw ( $response | Format-List -Force | Out-String )
                    }
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }

                Write-Verbose ".. $($MyInvocation.MyCommand.Name): Daily Plan orders created for: $(Get-Date $day -Format 'yyyy-MM-dd')"
            }

            $loops++
        }

        if ( $loops )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): Daily Plan orders for $loops days created"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no Daily Plan orders created"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
