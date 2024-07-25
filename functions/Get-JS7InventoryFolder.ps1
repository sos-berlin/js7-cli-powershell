function Get-JS7InventoryFolder
{
<#
.SYNOPSIS
Returns the configuration of JOC Cockpit inventory items from a folder, e.g. a workflow

.DESCRIPTION
Any inventory objects are returned in their native JSON reperesentation.

The following REST Web Service API resources are used:

* /inventory/folder

.PARAMETER Folder
Specifies the folder for which workflows should be returned.

.PARAMETER Recursive
When used with the -Folder parameter specifies that any sub-folders should be looked up.
By default no sub-folders will be searched for workflows.

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
** JOBTEMPLATE
** WORKINGDAYSCALENDAR
** NONWORKINGDAYSCALENDAR
** SCHEDULE
** REPORT

.OUTPUTS
This cmdlet returns a PowerShell object that represents the inventory objects.

.EXAMPLE
$fos = Get-JS7InventoryFolder -Folder /JS7Demo/08_FileWatching -Type FILEORDERSOURCE

Returns the inventory objects for file order sources from the given folder.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder = '/',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('FOLDER','WORKFLOW','FILEORDERSOURCE','INCLUDESCRIPT','JOBTEMPLATE','JOBRESOURCE','NOTICEBOARD','LOCK','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE','REPORT',IgnoreCase = $False)]
    [string[]] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Valid
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
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

        Write-Debug ".. $($MyInvocation.MyCommand.Name):"
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'path' -value $Folder -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $body

        if ( $Type )
        {
            Add-Member -Membertype NoteProperty -Name 'objectTypes' -value $Type -InputObject $body
        }

        Add-Member -Membertype NoteProperty -Name 'onlyValidObjects' -value ($Valid -eq $True) -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/inventory/read/folder' -Body $requestBody
        $inventoryItems = @()

        if ( $response.StatusCode -eq 200 )
        {
            if ( $Type )
            {
                switch ($Type.toUpper())
                {
                    'WORKFLOW'
                    {
                        $inventoryItems = ( $response | ConvertFrom-Json ).workflows
                        break;
                    }

                    'FILEORDERSOURCE'
                    {
                        $inventoryItems = ( $response | ConvertFrom-Json ).fileOrderSources
                        break;
                    }

                    'INCLUDESCRIPT'
                    {
                        $inventoryItems = ( $response | ConvertFrom-Json ).includeScripts
                        break;
                    }

                    'JOBTEMPLATE'
                    {
                        $inventoryItems = ( $response | ConvertFrom-Json ).jobTemplates
                        break;
                    }

                    'JOBRESOURCE'
                    {
                        $inventoryItems = ( $response | ConvertFrom-Json ).jobResources
                        break;
                    }

                    'NOTICEBOARD'
                    {
                        $inventoryItems = ( $response | ConvertFrom-Json ).noticeBoards
                        break;
                    }

                    'LOCK'
                    {
                        $inventoryItems = ( $response | ConvertFrom-Json ).locks
                        break;
                    }

                    'WORKINGDAYSCALENDAR'
                    {
                        $inventoryItems = ( $response | ConvertFrom-Json ).calendars
                        break;
                    }

                    'NONWORKINGDAYSCALENDAR'
                    {
                        $inventoryItems = ( $response | ConvertFrom-Json ).calendars
                        break;
                    }

                    'SCHEDULE'
                    {
                        $inventoryItems = ( $response | ConvertFrom-Json ).schedules
                        break;
                    }

                    'REPORT'
                    {
                        $inventoryItems = ( $response | ConvertFrom-Json ).reports
                        break;
                    }
                }
            } else {
                $inventoryItems = ( $response | ConvertFrom-Json )
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $inventoryItems

        if ( $inventoryItems.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($inventoryItems.count) inventory items found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no inventory items found"
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
