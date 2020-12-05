function Remove-JS7DailyPlanOrder
{
<#
.SYNOPSIS
Removes the daily plan orders for a JS7 Controller

.DESCRIPTION
Removes daily plan orders from a JS7 Controller.

.PARAMETER OrderId
Optionally specifies the order ID of the daily plan order that should be removed.

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow for which daily plan orders should be removed.

.PARAMETER SchedulePath
Optionally specifies the path and name of a schedule for which daily plan orders should be removed.

.PARAMETER DailyPlanDate
Specifies the date starting for which daily plan orders should be removed.
Consider that a UTC date has to be provided.

Default: Current day as a UTC date

.OUTPUTS
This cmdlet returns an array of daily plan orders.

.EXAMPLE
Remove-JS7DailyPlanOrder -DailyPlanDate "2020-12-31"

Removes any daily plan orders for the given day.

.EXAMPLE
Remove-JS7DailyPlanOrder -DailyPlanDate (Get-Date).AddDays(3)

Removes any daily plan orders for a date three days from now.

.EXAMPLE
Remove-JS7DailyPlanOrder -OrderId #2020-11-19#P0000000498-orderSampleWorfklow2a

Removes the given order ID from the daily plan.

.EXAMPLE
Remove-JS7DailyPlanOrder -WorkflowPath /some_folder/some_workflow

Removes the daily plan orders for the indicated workflow in today's daily plan.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $SchedulePath,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DailyPlanDate = (Get-Date (Get-Date).ToUniversalTime() -Format 'yyyy-MM-dd')
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch

        $orderIds = @()
        $workflowPaths = @()
        $schedulePaths = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder, WorkflowPath=$WorkflowPath, Schedule=$Schedule"

        if ( !$DailyPlanDate )
        {
            throw "$($MyInvocation.MyCommand.Name): daily plan date is required, use parameter -DailyPlanDate"
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
    }

    End
    {
        if ( $orderIds.count -or $workflowPaths.count -or $schedulePaths.count -or $DailyPlanDate )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'dailyPlanDate' -value (Get-Date $DailyPlanDate -Format 'yyyy-MM-dd') -InputObject $body
    
            if ( $orderIds.count )
            {
                Add-Member -Membertype NoteProperty -Name 'orderIds' -value $orderIds -InputObject $body
            }
    
            if ( $workflowPaths.count )
            {
                Add-Member -Membertype NoteProperty -Name 'workflowPaths' -value $workflowPaths[0] -InputObject $body
            }
            
            if ( $schedulePaths.count )
            {
                Add-Member -Membertype NoteProperty -Name 'schedules' -value $schedulePaths -InputObject $body
            }
    
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/daily_plan/orders/remove' -Body $requestBody
            
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

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): Daily Plan orders removed"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no Daily Plan orders removed"
        }
        
        Log-StopWatch $MyInvocation.MyCommand.Name $stopWatch
    }
}
