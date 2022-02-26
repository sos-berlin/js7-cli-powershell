function Get-JS7RepositoryItem
{
<#
.SYNOPSIS
Returns a list of scheduling objects from a local Git repository.

.DESCRIPTION
A list of scheduling objects such as workflows etc. are returned from a local Git repository

* by the category for LOCAL or ROLLOUT scheduling objects,
* by the folder of the item location optionally including sub-folders.

Resulting items can be forwarded to other cmdlets for pipelined bulk operations.

.PARAMETER Folder
Specifies the repository folder for which items should be returned.

.PARAMETER Recursive
Specifies that any sub-folders should be looked up if the -Folder parameter is used.
By default no sub-folders will be looked up.

.PARAMETER Local
Specifies that a repository holding local scheduling objects should be used.
This corresponds to the LOCAL category. If this switch is not used then then
ROLLOUT category is assumed for a repository that holds scheduling objects
intended for rollout to later environments such as test, prod.

.OUTPUTS
This cmdlet returns an array of items.

.EXAMPLE
$items = Get-JS7RepositoryItem -Folder /samples

Returns all items available with a repository of category ROLLOUT.

.EXAMPLE
$items = Get-JS7RepositoryItem -Folder /samples -Recursive

Returns all items available from the "/samples" folder
including any sub-folders from a repository of category ROLLOUT.

.EXAMPLE
$items = Get-JS7RepositoryItem -Folder /samples/some_sub_folder -Local

Returns the items for scheduling objects that are local to the scheduling environment from the indicated folder.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Local
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Folder=$Folder"

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
    }

    End
    {
        if ( $Local )
        {
            $category = 'LOCAL'
        } else {
            $category = 'ROLLOUT'
        }

        $body = New-Object PSObject

        Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'category' -value $category -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/inventory/repository/read' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnItems = ( $response.Content | ConvertFrom-JSON ).folders
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
