function New-JS7DailyPlanOrder
{
<#
.SYNOPSIS
Create the daily plan orders for a number of JS7 Controllers

.DESCRIPTION
Creates daily plan orders for a number of JS7 Controllers. Orders can be submitted to any
JS7 Controllers that are deployed the respective workflows.

.PARAMETER DailyPlanDate
Specifies the date for which daily plan orders should be created.
Consider that a UTC date has to be provided.

Default: current day as a UTC date

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow for which daily plan orders should be created.

.PARAMETER SchedulePath
Optionally specifies the path and name of a schedule for which daily plan orders should be created.

.PARAMETER Folder
Optionally specifies the a folder with schedules for which daily plan orders should be created.

.PARAMETER Recursive
Optionally specifies that schedules are looked up in any sub-folders recursively
if used with the -Folder parameter.

.PARAMETER ControllerId
Specifies the Controller to which daily plan orders are submitted should the -Submit switch be used.

Without this parameter daily plan orders are submitted to any Controllers that are deployed the
workflows that are indicated with the respective schedules.

.PARAMETER Submit
Specifies to immediately submit the daily plan orders to a JS7 Controller.

.PARAMETER Overwrite
Specifies to overwrite daily plan orders for the same date and schedule.

If such orders exist with a Controller and the -Submit parameter is used then they are cancelled and re-created.

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
New-JS7DailyPlanOrder -DailyPlanDate "2020-12-31"

Creates daily plan orders from any schedules for the given day.

.EXAMPLE
New-JS7DailyPlanOrder -DailyPlanDate "2020-12-31" -Submit -Overwrite

Creates daily plan orders from any schedules for the given date and submits
them to the

.EXAMPLE
New-JS7DailyPlanOrder -DailyPlanDate (Get-Date).AddDays(3) -SchedulePath /daily/eod

Creates daily plan orders from the indicated schedule for a date three days from now.

.EXAMPLE
New-JS7DailyPlanOrder -DailyPlanDate "2020-12-31" -Folder /daily -Recursive

Creates daily plan orders for the given date from schedules that are available with the
indicated folder and any sub-folders recursively.

.LINK
about_js7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DailyPlanDate = (Get-Date (Get-Date).ToUniversalTime() -Format 'yyyy-MM-dd'),
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $SchedulePath,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder = '/',
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Submit,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Overwrite,
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

        $folders = @()
        $workflowPaths = @()
        $schedulePaths = @()
        $controllerIds = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder, WorkflowPath=$WorkflowPath, SchedulePath=$SchedulePath"

        if ( $Folder -and $Folder -ne '/' )
        {
            if ( !$Folder.StartsWith( '/' ) )
            {
                $Folder = '/' + $Folder
            }

            if ( $Folder.EndsWith( '/' ) )
            {
                $Folder = $Folder.Substring( 0, $Folder.Length-1 )
            }
        }

        if ( !$WorkflowPath -and !$SchedulePath -and $Folder -eq '/' -and !$Recursive )
        {
            $Recursive = $True
        }

        if ( $WorkflowPath )
        {
            $workflowPaths += $WorkflowPath
        }

        if ( $SchedulePath )
        {
            $schedulePaths += $SchedulePath
        }

        if ( $Folder )
        {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $objFolder
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $objFolder

            $folders += $objFolder
        }

        if ( $ControllerId )
        {
            $controllerIds += $ControllerId
        }
    }

    End
    {
        if ( $folders -or $schedulePaths -or $controllerIds )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'dailyPlanDate' -value (Get-Date $DailyPlanDate -Format 'yyyy-MM-dd') -InputObject $body

            $selector = New-Object PSObject

            if ( $workflowPaths )
            {
                Add-Member -Membertype NoteProperty -Name 'workflowPaths' -value $workflowPaths -InputObject $selector
            }

            if ( $schedulePaths )
            {
                Add-Member -Membertype NoteProperty -Name 'schedulePaths' -value $schedulePaths -InputObject $selector
            }

            if ( $folders )
            {
                Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $selector
            }

            Add-Member -Membertype NoteProperty -Name 'selector' -value $selector -InputObject $body

            if ( $controllerIds )
            {
                Add-Member -Membertype NoteProperty -Name 'controllerIds' -value $controllerIds -InputObject $body
            }

            Add-Member -Membertype NoteProperty -Name 'withSubmit' -value ($Submit -eq $True) -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'overwrite' -value ($Overwrite -eq $True) -InputObject $body

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

                Write-Verbose ".. $($MyInvocation.MyCommand.Name): Daily Plan orders created"
            }
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no Daily Plan orders created"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
