function Get-JS7Order
{
<#
.SYNOPSIS
Returns orders from the JS7 Controller

.DESCRIPTION
Orders are selected from the JS7 Controller

* by the folder of the order location including sub-folders,
* by the workflow that is assigned to an order,
* by an individual order ID.

Resulting orders can be forwarded to other cmdlets for pipelined bulk operations.

.PARAMETER OrderId
Optionally specifies the identifier of an order that should be returned.

.PARAMETER WorkflowPath
Optionally specifies the path and name of a workflow for which orders should be returned.

One of the parameters -Folder, -WorkflowPath or -OrderId has to be specified if no pipelined order objects are provided.

.PARAMETER WorkflowVersionId
Deployed workflows can be assigned a version identifier. This parameters allows to select 
workflows that are assigned the specified version.

.PARAMETER Folder
Optionally specifies the folder with workflows for which orders should be returned.

One of the parameters -Folder, -WorkflowPath or -OrderId has to be specified if no pipelined order objects are provided.

.PARAMETER Recursive
Specifies that any sub-folders should be looked up if the -Folder parameter is used.
By default no sub-folders will be searched for orders.

.PARAMETER RegularExpression
Specifies that a regular expession is applied to the order IDs to filter results.

.PARAMETER Compact
Specifies that fewer attributes of orders are returned.

.PARAMETER Pending
Specifies that orders in a pending state should be returned. Such orders are scheduled
for a later start.

.PARAMETER Running
Specifies that orders in a running state should be returned, i.e. orders for which a job has
been executed in a workflow.

.PARAMETER Suspended
Specifies that orders in suspended state should be returned. An order can be suspended
e.g. when being affected by the Suspend-JobSchedulerOrder cmdlet or the respective manual operation from the GUI.

.PARAMETER Waiting
Specifies that orders in a setback state should be returned. Such orders make use of an interval
specified by a retry operation in the workflow for which they are repeated in case that a job fails.

.PARAMETER Failed
Specifies that orders in a failed state should be returned. Orders are considered being failed
if a job in the workflow fails.

.PARAMETER Blocked
Specifies that orders should be returned that are blocked by a resource, e.g. if a job's task limit
is exceeded and the order has to wait for the next available task.

.PARAMETER IgnoreFailed
Specifies that errors relating to orders not being found are ignored.
An empty response will be returned.

.OUTPUTS
This cmdlet returns an array of order objects.

.EXAMPLE
$orders = Get-JS7Order

Returns all orders available with a JS7 Controller.

.EXAMPLE
$orders = Get-JS7Order -Folder /some_path -Recursive

Returns all orders that are configured for workflows with the folder "/some_path"
including any sub-folders.

.EXAMPLE
$orders = Get-JS7Order -WorkflowPath /test/globals/workflow1

Returns the orders for workflow "workflow1" from the folder "/test/globals".

.EXAMPLE
$orders = Get-JS7Order -OrderId #2020-11-19#P0000000498-orderSampleWorfklow2a

Returns the order with the respective identifier.

.EXAMPLE
$orders = Get-JS7Order -Suspended -Waiting

Returns any orders that have been suspended, e.g. after job failures, or
that are waiting to retry execution of a job after failure.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $OrderId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $WorkflowVersionId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder = '/',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RegularExpression,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Compact,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Pending,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Running,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Suspended,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Waiting,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Failed,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Blocked,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $IgnoreFailed
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch

        $returnOrders = @()
        $workflowIds = @()
        $folders = @()
        $states = @()
    }
        
    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder, WorkflowPath=$WorkflowPath, OrderId=$OrderId"
    
        if ( !$Folder -and !$WorkflowPath -and !$OrderId -and !$RegularExpression)
        {
            throw "$($MyInvocation.MyCommand.Name): no folder, no workflow path, order id or regular expression is specified, use -Folder or -WorkflowPath or -OrderId or -RegularExpression"
        }

        if ( $Folder -and $Folder -ne '/' )
        { 
            if ( !$Folder.StartsWith( '/' ) )
            {
                $Folder = '/' + $Folder
            }
        
            if ( $Folder.endsWith( '/' ) )
            {
                $Folder = $Folder.Substring( 0, $Folder.Length-1 )
            }
        }           

        if ( $Folder -eq '/' -and !$WorkflowPath -and !$OrderId -and !$Recursive )
        {
            $Recursive = $True
        }

        if ( $Pending )
        {
            $states += 'PENDING'
        }

        if ( $Running )
        {
            $states += 'RUNNING'
        }

        if ( $Suspended )
        {
            $states += 'SUSPENDED'
        }

        if ( $Waiting )
        {
            $states += 'WAITING'
        }

        if ( $Failed )
        {
            $states += 'FAILED'
        }

        if ( $Blocked )
        {
            $states += 'BLOCKED'
        }


        if ( $OrderId )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

            if ( $Compact )
            {
                Add-Member -Membertype NoteProperty -Name 'compact' -value $True -InputObject $body
            }
            
            Add-Member -Membertype NoteProperty -Name 'orderId' -value $orderId -InputObject $body            
            Add-Member -Membertype NoteProperty -Name 'suppressNotExistException' -value $False -InputObject $body            

            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/order' -Body $requestBody
        
            if ( $response.StatusCode -eq 200 )
            {
                $returnOrders = ( $response.Content | ConvertFrom-JSON )
            } elseif ( $response.StatusCode -eq 420 -and $IgnoreFailed ) {
                # exception not forwarded
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }
        
            $returnOrders
        } elseif ( $WorkflowPath ) {
            $objWorkflow = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'path' -value $WorkflowPath -InputObject $objWorkflow
                
            if ( $WorkflowVersionId )
            {
                Add-Member -Membertype NoteProperty -Name 'versionId' -value $WorkflowVersionId -InputObject $objWorkflow
            }

            $workflowIds += $objWorkflow
        } elseif ( $Folder ) {
            $objFolder = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $objFolder
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $objFolder

            $folders += $objFolder
        }
    }

    End
    {
        if ( !$OrderId )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

            if ( $Compact )
            {
                Add-Member -Membertype NoteProperty -Name 'compact' -value $True -InputObject $body
            }

            if ( $workflowIds.count )
            {
                Add-Member -Membertype NoteProperty -Name 'workflowIds' -value $workflowIds -InputObject $body
            }
    
            if ( $folders.count )
            {
                Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $body                
            }
            
            if ( $states.count )
            {
                Add-Member -Membertype NoteProperty -Name 'states' -value $states -InputObject $body
            }

            if ( $RegularExpression )
            {
                Add-Member -Membertype NoteProperty -Name 'regex' -value $RegularExpression -InputObject $body
            }

            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/orders' -Body $requestBody
        
            if ( $response.StatusCode -eq 200 )
            {
                $returnOrders = ( $response.Content | ConvertFrom-JSON ).orders
            } elseif ( $response.StatusCode -eq 420 -and $IgnoreFailed ) {
                # no exception
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }
        
            $returnOrders
        }

        if ( $returnOrders.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnOrders.count) orders found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no orders found"
        }
        
        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session
    }
}
