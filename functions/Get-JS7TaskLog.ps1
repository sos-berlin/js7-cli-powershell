function Get-JS7TaskLog
{
<#
.SYNOPSIS
Read the task log from the JS7 History

.DESCRIPTION
Reads a task log for a given task ID. This cmdlet is mostly used for pipelined input from the
Get-JS7TaskHistory cmdlet that allows to search the execution history of tasks and
that returns task IDs that are used by this cmdlet to retrieve the task's log output.

.PARAMETER TaskId
Specifies the ID that the task was running with. This information is provided by the
Get-JS7TaskHistory cmdlet.

.PARAMETER ControllerId
This parameter is used to accept pipeline input from the Get-JS7TaskHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER AgentUrl
This parameter is used to accept pipeline input from the Get-JS7TaskHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER OrderId
This parameter is used to accept pipeline input from the Get-JS7TaskHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER Workflow
This parameter is used to accept pipeline input from the Get-JS7TaskHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER Position
This parameter is used to accept pipeline input from the Get-JS7TaskHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER Job
This parameter is used to accept pipeline input from the Get-JS7TaskHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER Criticality
This parameter is used to accept pipeline input from the Get-JS7TaskHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER ExitCode
This parameter is used to accept pipeline input from the Get-JS7TaskHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER State
This parameter is used to accept pipeline input from the Get-JS7TaskHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER StartTime
This parameter is used to accept pipeline input from the Get-JS7TaskHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER EndTime
This parameter is used to accept pipeline input from the Get-JS7TaskHistory cmdlet and forwards the parameter to the resulting object.

.INPUTS
This cmdlet accepts pipelined task history objects that are e.g. returned from the Get-JS7TaskHistory cmdlet.

.OUTPUTS
This cmdlet returns and an object with history properties including the task log.

.EXAMPLE
Get-JS7TaskHistory -WorkflowPath /product_demo/sample_workflow -Job job174 | Get-JS7TaskLog

Retrieves the most recent task log for the given job.

.EXAMPLE
Get-JS7TaskHistory -WorkflowPath /product_demo/sample_workflow -Job job174 | Get-JS7TaskLog | Out-File /tmp/job174.log -Encoding Unicode

Writes the task log to a file.

.EXAMPLE
Get-JS7TaskHistory -RelativeDateFrom -8h | Get-JS7TaskLog | Select-Object @{name='path'; expression={ "/tmp/history/$(Get-Date $_.startTime -f 'yyyyMMdd-hhmmss')-$([io.path]::GetFileNameWithoutExtension($_.job)).log"}}, @{name='value'; expression={ $_.log }} | Set-Content

Read the logs of tasks that completed within the last 8 hours and writes the log output to individual files. The log file names are created from the start time and the job name of each task.

.EXAMPLE
# execute once
$lastHistory = Get-JS7TaskHistory -RelativeDateFrom -8h | Sort-Object -Property startTime
# execute by interval
Get-JS7TaskHistory -DateFrom $lastHistory[0].startTime | Tee-Object -Variable lastHistory | Get-JS7TaskLog | Select-Object @{name='path'; expression={ "/tmp/history/$(Get-Date $_.startTime -f 'yyyyMMdd-hhmmss')-$([io.path]::GetFileNameWithoutExtension($_.job)).log"}}, @{name='value'; expression={ $_.log }} | Set-Content

Provides a mechanism to subsequently retrieve previous logs. Starting from intial execution of the Get-JS7TaskHistory cmdlet the resulting $lastHistory object is used for any subsequent calls. 
Consider use of the Tee-Object cmdlet in the pipeline that updates the $lastHistory object that can be used for later executions of the same pipeline. 
The pipeline can e.g. be executed in a cyclic job.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $AgentUrl,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $TaskId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Workflow,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Position,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Job,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Criticality,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $ExitCode,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [PSCustomObject] $State,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [datetime] $StartTime,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [datetime] $EndTime
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch
    }
    
    Process
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'taskId' -value $TaskId -InputObject $body
        
        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/task/log/download' -Body $requestBody
            
        if ( $response.StatusCode -ne 200 )
        {
            throw ( $response | Format-List -Force | Out-String )
        }
        
        $objResult = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'agentUrl' -value $AgentUrl -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'taskId' -value $TaskId -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'orderId' -value $OrderId -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'workflow' -value $Workflow -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'position' -value $Position -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'job' -value $Job -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'criticality' -value $Criticality -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'exitCode' -value $ExitCode -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'state' -value $State -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'startTime' -value $StartTime -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'endTime' -value $EndTime -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'log' -value ([System.Text.Encoding]::UTF8.GetString( $response.Content )) -InputObject $objResult
        
        $objResult
    }

    End
    {
        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session
    }
}
