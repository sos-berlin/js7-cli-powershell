function Get-JS7OrderLog
{
<#
.SYNOPSIS
Read the order log from the JS7 History.

.DESCRIPTION
Reads an order log for a given workflow, order ID and history ID. This cmdlet is mostly used for pipelined input from the
Get-JobSchedulerOrderHistory cmdlet that allows to search the execution history of orders and
that returns history IDs that are used by this cmdlet to retrieve the order's log output.

.PARAMETER HistoryId
Specifies the history ID that the order was running for. This information is provided by the
Get-JS7OrderHistory cmdlet.

.PARAMETER OrderId
This parameter specifies the order ID that was running for the given history ID.

.PARAMETER WorkflowPath
This parameter specifies the workflow path and name that the order is assigned.

.PARAMETER Path
This parameter is used to accept pipeline input from the Get-JobSchedulerOrderHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER Node
This parameter is used to accept pipeline input from the Get-JobSchedulerOrderHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER StartTime
This parameter is used to accept pipeline input from the Get-JobSchedulerOrderHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER EndTime
This parameter is used to accept pipeline input from the Get-JobSchedulerOrderHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER ExitCode
This parameter is used to accept pipeline input from the Get-JobSchedulerOrderHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER State
This parameter is used to accept pipeline input from the Get-JobSchedulerOrderHistory cmdlet and forwards the parameter to the resulting object.

.PARAMETER JobSchedulerId
This parameter is used to accept pipeline input from the Get-JobSchedulerOrderHistory cmdlet and forwards the parameter to the resulting object.

.INPUTS
This cmdlet accepts pipelined order history objects that are e.g. returned from the Get-JobSchedulerOrderHistory cmdlet.

.OUTPUTS
This cmdlet returns and an object with history properties including the order log.

.EXAMPLE
Get-JS7OrderHistory -WorkflowPath /product_demo/shell_chain | Get-JS7OrderLog

Retrieves the most recent order log for the given workflow.

.EXAMPLE
Get-JS7OrderHistory -WorkflowPath /product_demo/shell_chain | Get-JS7OrderLog | Out-File /tmp/shell_chain.log -Encoding Unicode

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
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $HistoryId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder = '/',
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Node,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [datetime] $StartTime,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [datetime] $EndTime,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [int] $ExitCode,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [PSCustomObject] $State,
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch
        
        if ( !$HistoryId -and !$OrderId -and !$WorkflowPath -and !$Folder)
        {
            throw "$($MyInvocation.MyCommand.Name): no folder, no workflow path, no order id and history id specified, use -Folder or -WorkflowPath or -OrderId or -HistoryId"
        }
        
        $historyIds = @()
        $historyItems = @()
        $returnResults = @()
    }
    
    Process
    {
        if ( $HistoryId )
        {
            $historyIds += $HistoryId
        } else {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            
            if ( $OrderId -or $WorkflowPath )
            {
                $objOrder = New-Object PSObject
            
                if ( $WorkflowPath )
                {
                    Add-Member -Membertype NoteProperty -Name 'workflowPath' -value $WorkflowPath -InputObject $objOrder
                }
            
                if ( $OrderId )
                {
                    Add-Member -Membertype NoteProperty -Name 'orderId' -value $OrderId -InputObject $objOrder
                }

                Add-Member -Membertype NoteProperty -Name 'orders' -value @( $objOrder ) -InputObject $body
            } elseif ( $Folder ) {
                $objFolder = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $objFolder
                Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $objFolder
                
                Add-Member -Membertype NoteProperty -Name 'folders' -value @( $objFolder ) -InputObject $body
            }
            
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/orders/history' -Body $requestBody
                
            if ( $response.StatusCode -eq 200 )
            {
                $historyItems = ( $response.Content | ConvertFrom-JSON ).history
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }
            
            foreach( $historyItem in $historyItems )
            {
                $historyIds += $historyItem.historyId
            }
        }
        
        foreach( $historyId in $historyIds )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
            Add-Member -Membertype NoteProperty -Name 'historyId' -value $historyId -InputObject $body
        
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/order/log/download' -Body $requestBody
            
            if ( $response.StatusCode -ne 200 )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        
            $objResult = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'endTime' -value $EndTime -InputObject $objResult
            Add-Member -Membertype NoteProperty -Name 'exitCode' -value $ExitCode -InputObject $objResult
            Add-Member -Membertype NoteProperty -Name 'historyId' -value $HistoryId -InputObject $objResult
            Add-Member -Membertype NoteProperty -Name 'workflow' -value $WorkflowPath -InputObject $objResult
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $objResult
            Add-Member -Membertype NoteProperty -Name 'node' -value $Node -InputObject $objResult
            Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $objResult
            Add-Member -Membertype NoteProperty -Name 'startTime' -value $StartTime -InputObject $objResult
            Add-Member -Membertype NoteProperty -Name 'state' -value $State -InputObject $objResult
            Add-Member -Membertype NoteProperty -Name 'orderId' -value $OrderId -InputObject $objResult
            Add-Member -Membertype NoteProperty -Name 'log' -value ([System.Text.Encoding]::UTF8.GetString( $response.Content )) -InputObject $objResult
        
            $returnResults += $objResult
        }
        
        $returnResults
    }

    End
    {
        Log-StopWatch $MyInvocation.MyCommand.Name $stopWatch
    }
}
