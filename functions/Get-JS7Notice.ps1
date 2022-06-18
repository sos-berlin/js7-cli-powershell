function Get-JS7Notice
{
<#
.SYNOPSIS
Returns Notices from a number of Notice Boards

.DESCRIPTION
This cmdlet returns a number of Notices from Notice Boards.

The following REST Web Service API resources are used:

* /notice/boards

.PARAMETER Path
Specifies the path to a Notice Board.

The path includes folder and sub-folders and the name of the Notice Board.

.PARAMETER Folder
Specifies the folder and optionally sub-folders from which Notices are returned.

.PARAMETER Recursive
When used with the -Folder parameter specifies that any sub-folders should be looked up.
By default no sub-folders will be searched for Notice Boards.

.PARAMETER ControllerId
Optionally specifies the identification of the Controller from which to read Notices.

.PARAMETER Limit
Specifies the number of Notice Boards for which notices are returned.

* Default: 10000
* Umlimited: -1

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns an array of Notices.

.EXAMPLE
$notices = Get-JS7Notice

Returns Notices form all Notice Boards.

.EXAMPLE
$notices = Get-JS7Notice -Path /ProductDemo/Sequencing/pdSequenceSynchroneously

Returns Notices from the indicated Notice Board.

.EXAMPLE
$notices = Get-JS7Notice -Folder /ProductDemo -Recursive

Returns Notices for Notice Boards from the indicated folder and any sub-folders.

.LINK
about_JS7

#>
[cmdletbinding()]
[OutputType([System.Object[]])]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $Limit = 10000
)
	Begin
	{
		Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        if ( $Folder -and $Path )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of the parameters -Path or -Folder can be used"
        }

        $folders = @()
        $paths = @()
    }

    Process
    {
        if ( $Folder.endsWith('/') )
        {
            $Folder = $Folder.Substring( 0, $Folder.Length-1 )
        }

        if ( $Folder )
        {
            $folderObj = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'folder' -value $Folder -InputObject $folderObj
            Add-Member -Membertype NoteProperty -Name 'recursive' -value ($Recursive -eq $True) -InputObject $folderObj
            $folders += $folderObj
        }

        if ( $Path )
        {
            $paths += $Path
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

        if ( $folders )
        {
            Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $body
        }

        if ( $paths )
        {
            Add-Member -Membertype NoteProperty -Name 'noticeBoardPaths' -value $paths -InputObject $body
        }

        if ( $limit )
        {
            Add-Member -Membertype NoteProperty -Name 'limit' -value $limit -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/notice/boards' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-Json ).noticeBoards

            if ( !$requestResult )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $returnResults = @()
        foreach( $noticeBoard in $requestResult )
        {
            if ( $noticeBoard.notices )
            {
                foreach( $notice in $noticeBoard.notices )
                {
                    $returnResult =  New-Object PSObject
                    Add-Member -Membertype NoteProperty -Name 'path' -value $noticeBoard.path -InputObject $returnResult
                    Add-Member -Membertype NoteProperty -Name 'noticeId' -value $notice.id -InputObject $returnResult
                    $returnResults += $returnResult
                }
            }
        }

        $returnResults

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnResults.count) Notices found"

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
