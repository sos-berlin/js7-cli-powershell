function Get-JS7FileTransferHistoryFile
{
<#
.SYNOPSIS
Returns details about individual files that have been transferred using YADE

.DESCRIPTION
Information is returned for individual files transferred with YADE from a JS7 workflow.
Files can be selected by file name, history status, transfer identification etc.

The history information returned includes source file name, target file name, hash value, status etc. for transfer of an indivdual file.
A file transfer can includes any number of files. For information about individual files
the Get-JS7FileTransferFile cmdlet can be used.

This cmdlet can be used for pipelining to return information about individual files like this:

$files = Get-JS7FileTransferHistory -RelativeDateFrom -1w -Successful | Get-JS7FileTransferHistoryFile

The following REST Web Service API resources are used:

* /yade/files

.PARAMETER ControllerId
Optionally limits file transfer history items to workflows that have been executed which the indicated Controller.

.PARAMETER TransferId
Optionally specifies the identifier of a transfer operation as returned by the Get-JS7FileTransferHistory cmdlet like this:

$files = Get-JS7FileTransferHistory -RelativeDateFrom -1w -Successful | Get-JS7FileTransferHistoryFile

The Get-JS7FileTransferHistory is used to select file transfes by date and execution result.
The result includes the transfer identifier and is pipelined to the Get-JS7FileTransferHistoryFile cmdlet to
return file items included with the specified file transfers.

.PARAMETER SourceFile
Optionally specifies the name of a source file to limit the file items returned.

This parameter accepts any number of source file names separated by a comma.

.PARAMETER TargetFile
Optionally specifies the name of a target file to limit the file items returned.

This parameter accepts any number of target file names separated by a comma.

.PARAMETER Hash
YADE can be configured to check the integrity of a file by a hash value.
The hash value is stored to the database and can be looked up by use of this parameter.

.PARAMETER State
Optionally specifies the state of a file transfer to limit the file items returned.

This parameter accepts one or more of the following states:

* UNDEFINED
* WAITING
* TRANSFERRING
* IN_PROGRESS
* TRANSFERRED
* SUCCESS
* SKIPPED
* FAILED
* ABORTED
* COMPRESSED
* NOT_OVERWRITTEN
* DELETED
* RENAMED
* IGNORED_DUE_TO_ZEROBYTE_CONSTRAINT
* ROLLED_BACK
* POLLING

.OUTPUTS
This cmdlet returns an array of file items.

.EXAMPLE
$items = Get-JS7FileTransferHistoryFile

Returns file items for today's file transfers.

.EXAMPLE
$items = Get-JS7FileTransferHistoryFile -Hash 'd41d8cd98f00b204e9800998ecf8427e'

Returns the file item for the file that matches the indicated hash.

.EXAMPLE
$items = Get-JS7FileTransferHistoryFile -SourceFile accounting.csv

Returns file items for the indicated file name.

.EXAMPLE
$items = Get-JS7FileTransferHistoryFile -TransferId 32767

Returns the file item for the file transfer identified with the indicated key.
The identifier for a file transfer can be retrieved by use of the Get-JS7FileTransferHistory cmdlet.

.EXAMPLE
$files = Get-JS7FileTransferHistory -RelativeDateFrom -1w -Successful | Get-JS7FileTransferHistoryFile

Returns the file items for file transfers performed since begin of the week that completed successfully.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Alias('ID')]
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $TransferId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [ValidateSet('UNDEFINED','WAITING','TRANSFERRING','IN_PROGRESS','TRANSFERRED','SUCCESS','SKIPPED','FAILED','ABORTED','COMPRESSED','NOT_OVERWRITTEN','DELETED','RENAMED','IGNORED_DUE_TO_ZEROBYTE_CONSTRAINT','ROLLED_BACK','POLLING',IgnoreCase = $False)]
    [string[]] $State,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $SourceFile,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $TargetFile,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Hash,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $Limit
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        $transferIds = @()
        $states = @()
        $sourceFiles = @()
        $targetFiles = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder, WorkflowPath=$WorkflowPath, OrderId=$OrderId"

        if ( $TransferId )
        {
            $transferIds += $TransferId
        }

        if ( $State )
        {
            $states += $State
        }

        if ( $SourceFile )
        {
            $sourcesFiles += $SourceFile
        }

        if ( $TargetFile )
        {
            $targetFiles += $TargetFile
        }
    }

    End
    {
        $body = New-Object PSObject

        if ( $ControllerId )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        }

        if ( $transferIds )
        {
            Add-Member -Membertype NoteProperty -Name 'transferIds' -value $transferIds -InputObject $body
        }

        if ( $sourceFiiles )
        {
            Add-Member -Membertype NoteProperty -Name 'sourceFiles' -value $sourceFiles -InputObject $body
        }

        if ( $targetFiles )
        {
            Add-Member -Membertype NoteProperty -Name 'targetFiles' -value $targetFiles -InputObject $body
        }

        if ( $Hash )
        {
            Add-Member -Membertype NoteProperty -Name 'integrityHash' -value $Hash -InputObject $body
        }

        if ( $states )
        {
            Add-Member -Membertype NoteProperty -Name 'states' -value $states -InputObject $body
        }

        if ( $Limit )
        {
            Add-Member -Membertype NoteProperty -Name 'limit' -value $Limit -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/yade/files' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnItems = ( $response.Content | ConvertFrom-Json ).files
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $returnItems

        if ( $returnItems.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnItems.count) items found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no items found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
