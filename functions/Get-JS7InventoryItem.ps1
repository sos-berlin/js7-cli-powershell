function Get-JS7InventoryItem
{
<#
.SYNOPSIS
Returns the configuration of a JOC Cockpit inventory item, e.g. a workflow

.DESCRIPTION
Any inventory objects are returned in their native JSON reperesentation.

.PARAMETER Path
Specifies the folder, sub-folder and name of the object, e.g. a workflow path that should be
returned from the inventory.

.PARAMETER Type
Specifies the object type which is one of:

* Any Object Type
** FOLDER
* Deployable Object Types
** WORKFLOW
** FILEORDERSOURCE
** JOBRESOURCE
** NOTICEBOARD
** LOCK
* Releasable Object Types
** INCLUDESCRIPT
** WORKINGDAYSCALENDAR
** NONWORKINGDAYSCALENDAR
** SCHEDULE

.OUTPUTS
This cmdlet returns a PowerShell object that represents the inventory object.

.EXAMPLE
$fos = Get-JS7InventoryItem -Path /JS7Demo/08_FileWatching/jdFilesTxt -Type FILEORDERSOURCE

Returns the inventory object of a file order source.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('FOLDER','WORKFLOW','FILEORDERSOURCE','JOBRESOURCE','NOTICEBOARD','LOCK','INCLUDESCRIPT','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE')]
    [string] $Type
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        if ( $Path.endsWith('/') )
        {
            throw "$($MyInvocation.MyCommand.Name): path has to include folder, sub-folder and object name"
        }

        Write-Debug ".. $($MyInvocation.MyCommand.Name):"
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/inventory/read/configuration' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $inventoryItem = ( $response.Content | ConvertFrom-Json ).configuration
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $inventoryItem

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
