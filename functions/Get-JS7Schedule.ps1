function Get-JS7Schedule
{
<#
.SYNOPSIS
Returns schedules from the JOC Cockpit inventory

.DESCRIPTION
Schedules are selected from the JOC Cockpit inventory

* by the path and name of a schedule,
* by the folder of the schedule location including sub-folders,
* by the path and name of a workflow.

Resulting schedules can be forwarded to other cmdlets for pipelined bulk operations.

The following REST Web Service API resources are used:

* /schedules

.PARAMETER SchedulePath
Optionally specifies the path and name of a schedule that should be returned.

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow for which schedules should be returned.

.PARAMETER Folder
Optionally specifies the folder for which schedules should be returned.

.PARAMETER Recursive
Specifies that any sub-folders should be looked up if the -Folder parameter is used.
By default no sub-folders will be searched for schedules.

.OUTPUTS
This cmdlet returns an array of schedule objects.

.EXAMPLE
$schedules = Get-JS7Schedule

Returns all schedules available with the JOC Cockpit inventory.

.EXAMPLE
$schedules = Get-JS7Schedule -Folder /some_folder -Recursive

Returns all schedules that are configured with the folder "/some_folder"
including any sub-folders.

.EXAMPLE
$schedule = Get-JS7Schedule -SchedulePath /BusinessDays

Returns the schedule that is stored with the path "/BusinessDays".

.EXAMPLE
$schedules = Get-JS7Schedule -WorkflowPath /some/path

Returns the schedules that are assigned the given workflow.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $SchedulePath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder = '/',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        if ( $WorkingDays -and $NonWorkingDays )
        {
            throw "$($MyInvocation.MyCommand.Name): only one of the parameters -WorkingDays or -NonWorkingDays can be used"
        }

        $controllerIds = @()
        $schedulePaths = @()
        $workflowPaths = @()
        $folders = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder, SchedulePath=$SchedulePath"

        if ( $SchedulePath.endsWith( '/') )
        {
            throw "$($MyInvocation.MyCommand.Name): the -SchedulePath parameter has to specify the folder and name of a schedule"
        }

        if ( $SchedulePath -and !$SchedulePath.startsWith( '/') )
        {
            $SchedulePath = '/' + $SchedulePath
        }

        if ( $WorkflowPath.endsWith( '/') )
        {
            throw "$($MyInvocation.MyCommand.Name): the -WorkflowPath parameter has to specify the folder and name of a schedule"
        }

        if ( $WorkflowPath -and !$WorkflowPath.startsWith( '/') )
        {
            $WorkflowPath = '/' + $WorkflowPath
        }

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

        if ( $Folder -eq '/' -and !$WorkflowPath -and !$SchedulePath -and !$Recursive )
        {
            $Recursive = $True
        }


        if ( $ControllerId )
        {
            $controllerIds += $ControllerId
        }

        if ( $SchedulePath )
        {
            $SchedulePaths += $SchedulePath
        }

        if ( $WorkflowPath )
        {
            $workflowPaths += $WorkflowPath
        }

        if ( $Folder )
        {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $objFolder
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $objFolder

            $folders += $objFolder
        }
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

        if ( $schedulePaths.count -or $workflowPaths.count -or $folders.count )
        {
            $selector = New-Object PSObject

            if ( $controllerIds.count )
            {
                Add-Member -Membertype NoteProperty -Name 'controllerIds' -value $controllerIds -InputObject $selector
            }

            if ( $schedulePaths.count )
            {
                Add-Member -Membertype NoteProperty -Name 'schedulePaths' -value $schedulePaths -InputObject $selector
            }

            if ( $workflowPaths.count )
            {
                Add-Member -Membertype NoteProperty -Name 'workflowPaths' -value $workflowPaths -InputObject $selector
            }

            if ( $folders.count )
            {
                Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $selector
            }

            Add-Member -Membertype NoteProperty -Name 'selector' -value $selector -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/schedules' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnSchedules = ( $response.Content | ConvertFrom-Json ).schedules
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $returnSchedules

        if ( $returnSchedules.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnSchedules.count) schedules found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no schedules found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
