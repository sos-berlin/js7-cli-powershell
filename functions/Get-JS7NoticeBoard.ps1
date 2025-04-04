function Get-JS7NoticeBoard
{
<#
.SYNOPSIS
Returns a number of Notice Boards

.DESCRIPTION
This cmdlet returns a number of Notices Boards including Notices.

The following REST Web Service API resources are used:

* /notice/boards

.PARAMETER NoticeBoardPath
Specifies the path to a Notice Board.

The path includes folder and sub-folders and the name of the Notice Board.

.PARAMETER Folder
Specifies the folder and optionally sub-folders from which Notices are returned.

.PARAMETER Recursive
When used with the -Folder parameter specifies that any sub-folders should be looked up.
By default no sub-folders will be searched for Notice Boards.

.PARAMETER PlanSchemaId
Specifies the Schema ID of the Plan to which notices are assigned.

One of the following can be specified:

* Global
* DailyPlan

.PARAMETER PlanKey
For plannable Notice Boards specified from the -PlanSchemaId argument with the value 'DailyPlan'
the key of the plan instance is a date in ISO format: yyyy-mm-dd.

The argument is ignored if the -PlanSchemaId argument is used with a value 'global'.

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
$boards = Get-JS7NoticeBoards

Returns all Notice Boards.

.EXAMPLE
$boards = Get-JS7NoticeBoards -Path /ProductDemo/Sequencing/pdSequenceSynchroneously

Returns the indicated Notice Board.

.EXAMPLE
$boards = Get-JS7NoticeBoards -Folder /ProductDemo -Recursive

Returns Notice Boards and Notices from the indicated folder and any sub-folders.

.LINK
about_JS7

#>
[cmdletbinding()]
[OutputType([System.Object[]])]
param
(
    [Alias('Path')]
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $NoticeBoardPath,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Folder,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Recursive,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('Global','DailyPlan',IgnoreCase = $False)]
    [string[]] $PlanSchemaId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $PlanKey,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Compact,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $Limit = 10000
)
	Begin
	{
		Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        if ( $Folder -and $NoticeBoardPath )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of the parameters -NoticeBoardPath or -Folder can be used"
        }

        $folders = @()
        $paths = @()
        $planSchemaIds = @()
        $planKeys = @()
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

        if ( $NoticeBoardPath )
        {
            $paths += $NoticeBoardPath
        }

        if ( $PlanSchemaId )
        {
            $planSchemaIds += $PlanSchemaId
        }

        if ( $PlanKey )
        {
            $planKeys += $PlanKey
        }
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'compact' -value ($Compact -eq $True) -InputObject $body

        if ( $ControllerId )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        }

        if ( $folders.count )
        {
            Add-Member -Membertype NoteProperty -Name 'folders' -value $folders -InputObject $body
        }

        if ( $paths.count )
        {
            Add-Member -Membertype NoteProperty -Name 'noticeBoardPaths' -value $paths -InputObject $body
        }

        if ( $planSchemaIds.count )
        {
            Add-Member -Membertype NoteProperty -Name 'planSchemaIds' -value $planSchemaIds -InputObject $body
        }

        if ( $planKeys.count )
        {
            Add-Member -Membertype NoteProperty -Name 'planKeys' -value $planKeys -InputObject $body
        }

        if ( $Limit )
        {
            Add-Member -Membertype NoteProperty -Name 'limit' -value $Limit -InputObject $body
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

        $requestResult

        Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($requestResult.count) Notice Boards found"

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
