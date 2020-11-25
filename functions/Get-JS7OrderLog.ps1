function Get-JS7OrderLog
{
<#
.SYNOPSIS
Read the order log from the JS7 History

.DESCRIPTION
Reads an order log for a given workflow, order ID and history ID. This cmdlet is mostly used for pipelined input from the
Get-JS7OrderHistory cmdlet that allows to search the execution history of orders and
that returns history IDs that are used by this cmdlet to retrieve the order's log output.

.PARAMETER HistoryId
Specifies the history ID that the order was running for. This information is provided by the
Get-JS7OrderHistory cmdlet.

.PARAMETER ControllerId
This parameter is used to accept pipeline input from the Get-JS7OrderHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER OrderId
This parameter is used to accept pipeline input from the Get-JS7OrderHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER Workflow
This parameter is used to accept pipeline input from the Get-JS7OrderHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER Position
This parameter is used to accept pipeline input from the Get-JS7OrderHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER State
This parameter is used to accept pipeline input from the Get-JS7OrderHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER PlannedTime
This parameter is used to accept pipeline input from the Get-JS7OrderHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER StartTime
This parameter is used to accept pipeline input from the Get-JS7OrderHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER EndTime
This parameter is used to accept pipeline input from the Get-JS7OrderHistory cmdlet and forwards the parameter to the resulting object.

.INPUTS
This cmdlet accepts pipelined order history objects that are e.g. returned from the Get-JS7OrderHistory cmdlet.

.OUTPUTS
This cmdlet returns and an object with history properties including the order log.

.EXAMPLE
Get-JS7OrderHistory -WorkflowPath /product_demo/sample_workflow | Get-JS7OrderLog

Retrieves the most recent order log for the given workflow.

.EXAMPLE
Get-JS7OrderHistory -WorkflowPath /product_demo/sample_workflow | Get-JS7OrderLog | Out-File /tmp/shell_chain.log -Encoding Unicode

Writes the order log to a file.

.EXAMPLE
Get-JS7OrderHistory -RelativeDateFrom -8h | Get-JS7OrderLog | Select-Object @{name='path'; expression={ "/tmp/history/$(Get-Date $_.startTime -f 'yyyyMMdd-hhmmss')-$([io.path]::GetFileNameWithoutExtension($_.workflow))-$($_.orderId).log"}}, @{name='value'; expression={ $_.log }} | Set-Content

Read the logs of orders that completed within the last 8 hours and writes the log output to individual files. The log file names are created from the start time, the workflow name and order ID.

.EXAMPLE
# execute once
$lastHistory = Get-JS7OrderHistory -RelativeDateFrom -8h | Sort-Object -Property startTime
# execute by interval
Get-JS7OrderHistory -DateFrom $lastHistory[0].startTime | Tee-Object -Variable lastHistory | Get-JS7OrderLog | Select-Object @{name='path'; expression={ "/tmp/history/$(Get-Date $_.startTime -f 'yyyyMMdd-hhmmss')-$([io.path]::GetFileNameWithoutExtension($_.workflow))-$($_.orderId).log"}}, @{name='value'; expression={ $_.log }} | Set-Content

Provides a mechanism to subsequently retrieve previous logs. Starting from initial execution of the Get-JS7OrderHistory cmdlet the resulting $lastHistory object is used for any subsequent calls. 
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
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $HistoryId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Workflow,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Position,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [PSCustomObject] $State,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [datetime] $PlannedTime,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [datetime] $StartTime,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [datetime] $EndTime
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch

        $historyIds = @()
        $historyItems = @()
        $returnResults = @()
    }
    
    Process
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'historyId' -value $HistoryId -InputObject $body
    
        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/order/log/download' -Body $requestBody
        
        if ( $response.StatusCode -ne 200 )
        {
            throw ( $response | Format-List -Force | Out-String )
        }
    
        $objResult = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'historyId' -value $HistoryId -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'orderId' -value $OrderId -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'workflow' -value $Workflow -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'position' -value $Position -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'state' -value $State -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'plannedTime' -value $PlannedTime -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'startTime' -value $StartTime -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'endTime' -value $EndTime -InputObject $objResult
        Add-Member -Membertype NoteProperty -Name 'log' -value ([System.Text.Encoding]::UTF8.GetString( $response.Content )) -InputObject $objResult
    
        $objResult
    }

    End
    {
        Log-StopWatch $MyInvocation.MyCommand.Name $stopWatch
    }
}
