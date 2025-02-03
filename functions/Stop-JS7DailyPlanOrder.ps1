function Stop-JS7DailyPlanOrder
{
<#
.SYNOPSIS
Cancels daily plan orders from a JS7 Controller

.DESCRIPTION
Cancels daily plan orders from a JS7 Controller.

The following REST Web Service API resources are used:

* /daily_plan/orders/cancel

.PARAMETER OrderId
Optionally specifies the Order ID of the daily plan order that should be cancelled.

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow for which daily plan orders should be cancelled.

.PARAMETER WorkflowFolder
Optionally specifies the folder with workflows for which daily plan orders should be cancelled.

.PARAMETER SchedulePath
Optionally specifies the path and name of a schedule for which daily plan orders should be cancelled.

.PARAMETER ScheduleFolder
Optionally specifies the folder with schedules for which daily plan orders should be cancelled.

.PARAMETER Recursive
When used with the -WorkflowFolder or -ScheduleFolder parameters then any sub-folders of the specified folder will be looked up.

.PARAMETER ControllerId
Specifies the Controller to which daily plan orders have been submitted and should be cancelled.

Without this parameter daily plan orders are cancelled from any Controllers that are deployed
together with the workflows that are indicated with their respective parameters.

.PARAMETER DateFrom
Optionally specifies the date starting from which daily plan orders should be cancelled.

Default: The current day in the local time zone

.PARAMETER DateTo
Optionally specifies the date until which daily plan orders should be cancelled.

Default: The current day in the local time zone

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
Stop-JS7DailyPlanOrder -DateFrom "2020-12-31"

Cancels any daily plan orders for the given date.

.EXAMPLE
Stop-JS7DailyPlanOrder -DateTo (Get-Date).AddDays(3)

Cancels any daily plan orders starting from today until a date three days from now.

.EXAMPLE
Stop-JS7DailyPlanOrder -OrderId "#2020-11-19#P0000000498-orderSampleWorfklow2a"

Cancels the order with the given Order ID from the daily plan.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowFolder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $SchedulePath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ScheduleFolder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
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

        $orderIds = @()
        $workflowPaths = @()
        $workflowFolders = @()
        $schedulePaths = @()
        $scheduleFolders = @()
        $controllerIds = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter OrderId=$OrderId, WorkflowPath=$WorkflowPath, WorkflowFolder=$WorkflowFolder, SchedulePath=$SchedulePath, ScheduleFolder=$ScheduleFolder"

        if ( $WorkflowFolder -and $WorkflowFolder -ne '/' )
        {
            if ( !$WorkflowFolder.startsWith( '/' ) ) {
                $WorkflowFolder = '/' + $WorkflowFolder
            }

            if ( $WorkflowFolder.endsWith( '/' ) )
            {
                $WorkflowFolder = $WorkflowFolder.Substring( 0, $WorkflowFolder.Length-1 )
            }
        }

        if ( $ScheduleFolder -and $ScheduleFolder -ne '/' )
        {
            if ( !$ScheduleFolder.startsWith( '/' ) ) {
                $ScheduleFolder = '/' + $ScheduleFolder
            }

            if ( $ScheduleFolder.endsWith( '/' ) )
            {
                $ScheduleFolder = $ScheduleFolder.Substring( 0, $ScheduleFolder.Length-1 )
            }
        }

        if ( $OrderId )
        {
            $orderIds += $OrderId
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

        if ( $ControllerId )
        {
            $controllerIds += $ControllerId
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

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): cancelling daily plan orders for date range $dailyPlanDateFrom - $dailyPlanDateTo"

        $body = New-Object PSObject

        Add-Member -Membertype NoteProperty -Name 'dailyPlanDateFrom' -value "$($dailyPlanDateFrom)" -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'dailyPlanDateTo' -value "$($dailyPlanDateTo)" -InputObject $body

        if ( $orderIds )
        {
            Add-Member -Membertype NoteProperty -Name 'orderIds' -value $orderIds -InputObject $body
        }

        if ( $workflowPaths )
        {
            Add-Member -Membertype NoteProperty -Name 'workflowPaths' -value $workflowPaths -InputObject $body
        }

        if ( $workflowFolders )
        {
            Add-Member -Membertype NoteProperty -Name 'workflowFolders' -value $workflowFolders -InputObject $body
        }

        if ( $schedulePaths )
        {
            Add-Member -Membertype NoteProperty -Name 'schedulePaths' -value $schedulePaths -InputObject $body
        }

        if ( $scheduleFolders )
        {
            Add-Member -Membertype NoteProperty -Name 'scheduleFolders' -value $scheduleFolders -InputObject $body
        }

        if ( $controllerIds )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerIds' -value $controllerIds -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerIds' -value @( $script:jsWebService.ControllerId ) -InputObject $body
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

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): Daily Plan orders cancelled"

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
