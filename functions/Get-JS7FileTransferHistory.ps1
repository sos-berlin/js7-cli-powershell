function Get-JS7FileTransferHistory
{
<#
.SYNOPSIS
Returns the history of file transfers performed with YADE

.DESCRIPTION
File transfer history information is returned for file transfers performed with YADE from a JS7 workflow.
File transfers can be selected by YADE profile, file name, history status etc.

The history information returned includes start time, end time, status etc. of a file transfer.
File transfers can include any number of files. For information about individual files
the Get-JS7FileTransferHistoryFile cmdlet can be used.

This cmdlet can be used for pipelining to return information about individual files like this:

$files = Get-JS7FileTransferHistory -RelativeDateFrom -1w -Successful | Get-JS7FileTransferHistoryFile

The following REST Web Service API resources are used:

* /yade/transfers

.PARAMETER ControllerId
Optionally limits file transfer history items to workflows that have been executed which the indicated Controller.

.PARAMETER Operation
Optionally limits file transfer history items to the ones using one or more of the following operations:

* COPY
* MOVE
* GETLIST
* RENAME

A number of operations can be specified by use of a comma, for example: -Operation COPY,MOVE.

.PARAMETER Profile
Optionally limits file transfer history items to the ones using the indicated YADE file transfer profile.

This parameter accepts any number of profiles separated by a comma.

.PARAMETER Source
Optionally specifies the host and port that act as the source of a file transfer to limit the file transfer history items returned.
Depending on the source protocol in use this can be the localhost for a local source or
the host configured with a file transfer fragment that is used as the source.

A source is specified by the hostname and optionally a port that are separated by a colon, for example: -Source some_host:22.

This parameter accepts any number of sources separated by a comma.

.PARAMETER Target
Optionally specifies the host and port that act as the target of a file transfer to limit the file transfer history items returned.
Depending on the target protocol in use this can be the localhost for a local target or
the host configured with a file transfer fragment that is used as the target.

A target is specified by the hostname and optionally a port that are separated by a colon, for example: -Target some_host:22.

This parameter accepts any number of targets separated by a comma.

.PARAMETER SourceFile
Optionally specifies the name of a source file to limit the file transfer history items returned.

This parameter accepts any number of source file names separated by a comma.

.PARAMETER TargetFile
Optionally specifies the name of a target file to limit the file transfer history items returned.

This parameter accepts any number of target file names separated by a comma.

.PARAMETER DateFrom
Specifies the date starting from which file transfer history items should be returned.
Consider that a UTC date has to be provided.

Default: Beginning of the current day as a UTC date

.PARAMETER DateTo
Specifies the date until which file transfer history items should be returned.
Consider that a UTC date has to be provided.

Default: End of the current day as a UTC date

.PARAMETER RelativeDateFrom
Specifies a relative date starting from which file transfer history items should be returned, for example:

* -1s, -2s: one second ago, two seconds ago
* -1m, -2m: one minute ago, two minutes ago
* -1h, -2h: one hour ago, two hours ago
* -1d, -2d: one day ago, two days ago
* -1w, -2w: one week ago, two weeks ago
* -1M, -2M: one month ago, two months ago
* -1y, -2y: one year ago, two years ago

Optionally a time offset can be specified, e.g. -1d+02:00, as otherwise midnight UTC is assumed.
Alternatively a timezone offset can be added, e.g. by using -1d+TZ. This is calculated by the cmdlet
for the timezone that is specified with the -Timezone parameter.

This parameter takes precedence over the -DateFrom parameter.

.PARAMETER RelativeDateTo
Specifies a relative date until which file transfer history items should be returned, for example:

* -1s, -2s: one second ago, two seconds ago
* -1m, -2m: one minute ago, two minutes ago
* -1h, -2h: one hour ago, two hours ago
* -1d, -2d: one day ago, two days ago
* -1w, -2w: one week ago, two weeks ago
* -1M, -2M: one month ago, two months ago
* -1y, -2y: one year ago, two years ago

Optionally a time offset can be specified, e.g. -1d+02:00, as otherwise midnight UTC is assumed.
Alternatively a timezone offset can be added, e.g. by using -1d+TZ. This is calculated by the cmdlet
for the timezone that is specified with the -Timezone parameter.

This parameter takes precedence over the -DateFrom parameter.

.PARAMETER Timezone
Specifies the timezone to which dates should be converted available from the file transfer history.
A timezone can be specified like this:

  Get-JS7FileTransferHistory -Timezone (Get-Timezone -Id 'GMT Standard Time')

All dates in JS7 are UTC and can be converted e.g. to the local time zone like this:

  Get-JS7FileTransferHistory -Timezone (Get-Timezone)

Default: Dates are returned in UTC.

.PARAMETER Limit
Specifies the max. number of history items for file transfers to be returned.
The default value is 10000, for an unlimited number of items the value -1 can be specified.

.PARAMETER Compact
Specifies the a smaller subset of properties to be returned with the file transfer history items.

.PARAMETER Successful
Returns history items for successfully completed file transfers.

.PARAMETER Failed
Returns history items for failed file transfers.

.PARAMETER InProgress
Specifies that history items for running file transfers should be returned.

.OUTPUTS
This cmdlet returns an array of file transfer history items.

.EXAMPLE
$items = Get-JS7FileTransferHistory

Returns today's file transfer history from any workflows.

.EXAMPLE
$items = Get-JS7FileTransferHistory -Profile copy_to_remote,move_to_remote

Returns today's file transfers that have been performed by use of the indicated YADE profiles.

.EXAMPLE
$items = Get-JS7FileTransferHistory -Timezone (Get-Timezone)

Returns today's file transfers with dates being converted to the local timezone.

.EXAMPLE
$items = Get-JS7FileTransferHistory -Timezone (Get-Timezone -Id 'GMT Standard Time')

Returns today's file transfers with dates being converted to the GMT timezone.

.EXAMPLE
$items = Get-JS7FileTransferHistory -Successful -DateFrom "2020-08-11 14:00:00Z"

Returns the file transfer history for successfully completed orders that started after the specified UTC date and time.

.EXAMPLE
$items = Get-JS7FileTransferHistory -Failed -DateFrom (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(-7).ToUniversalTime()

Returns the file transfer history for any failed orders for the last seven days.

.EXAMPLE
$items = Get-JS7FileTransferHistory -RelativeDateFrom -7d

Returns the file transfer history for the last seven days.
The history is reported starting from midnight UTC.

.EXAMPLE
$items = Get-JS7FileTransferHistory -RelativeDateFrom -7d+01:00

Returns the file transfer history for the last seven days.
The history is reported starting from 1 hour after midnight UTC.

.EXAMPLE
$items = Get-JS7FileTransferHistory -RelativeDateFrom -7d+TZ

Returns the file transfer history for the last seven days.
The history is reported starting from midnight in the same timezone that is used with the -Timezone parameter.

.EXAMPLE
$items = Get-JS7FileTransferHistory -RelativeDateFrom -1w

Returns the file transfer history for the last week.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('COPY','MOVE','GETLIST','RENAME',IgnoreCase = $False)]
    [string[]] $Operation,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Profile,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Source,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $Target,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $SourceFile,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string[]] $TargetFile,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateFrom = (Get-Date (Get-Date).ToUniversalTime() -Format 'yyyy-MM-dd'),
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateTo,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeDateFrom,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $RelativeDateTo,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [TimeZoneInfo] $Timezone = (Get-Timezone -Id 'UTC'),
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $Limit,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Compact,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Successful,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Failed,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [switch] $InProgress
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        $operations = @()
        $profiles = @()
        $states = @()
        $sources = @()
        $targets = @()
        $sourceFiles = @()
        $targetFiles = @()
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name):"

        if ( $Successful )
        {
            $states += 'SUCCESSFUL'
        }

        if ( $Failed )
        {
            $states += 'FAILED'
        }

        if ( $InProgress )
        {
            $states += 'INCOMPLETE'
        }

        if ( $Operation )
        {
            $operations += $Operation
        }

        if ( $Profile )
        {
            $profiles += $Profile
        }

        if ( $Source )
        {
            $sources += $Source
        }

        if ( $Target )
        {
            $targets += $Target
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
        # PowerShell/.NET does not create date output in the target timezone but with the local timezone only, let's work around this:
        $timezoneOffsetPrefix = if ( $Timezone.BaseUtcOffset.toString().startsWith( '-' ) ) { '-' } else { '+' }
        $timezoneOffsetHours = [Math]::Abs($Timezone.BaseUtcOffset.hours)

        if ( $Timezone.SupportsDaylightSavingTime -and $Timezone.IsDaylightSavingTime( (Get-Date) ) )
        {
            $timezoneOffsetHours += 1
        }

        [string] $timezoneOffset = "$($timezoneOffsetPrefix)$($timezoneOffsetHours.ToString().PadLeft( 2, '0' )):$($Timezone.BaseUtcOffset.Minutes.ToString().PadLeft( 2, '0' ))"

        $body = New-Object PSObject

        if ( $ControllerId )
        {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $body
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        }

        if ( $operations )
        {
            Add-Member -Membertype NoteProperty -Name 'operations' -value $operations -InputObject $body
        }

        if ( $profiles )
        {
            Add-Member -Membertype NoteProperty -Name 'profiles' -value $profiles -InputObject $body
        }

        if ( $sources )
        {
            $objSources = @()

            foreach( $sourceItem in $sources )
            {
                $objSource = New-Object PSObject
                $matchinfo = ( $sourceItem | Select-String -Pattern '^(.*)\:([0-9]+)$' )

                if ( $matchInfo -and $matchInfo.Matches -and $matchInfo.Matches.Groups.count )
                {
                    Add-Member -Membertype NoteProperty -Name 'host' -value $matchInfo.Matches.Groups[1] -InputObject $objSource

                    if ( $matchInfo.Matches.Groups.count -eq 3 )
                    {
                        Add-Member -Membertype NoteProperty -Name 'protocol' -value $matchInfo.Matches.Groups[1] -InputObject $objSource
                    }
                } else {
                    Add-Member -Membertype NoteProperty -Name 'host' -value $source -InputObject $objSource
                }

                $objSources += $objSource
            }

            Add-Member -Membertype NoteProperty -Name 'sources' -value $objSources -InputObject $body
        }

        if ( $targets )
        {
            $objTargets = @()

            foreach( $targetItem in $targets )
            {
                $objTarget = New-Object PSObject
                $matchinfo = ( $targetItem | Select-String -Pattern '^(.*)\:([0-9]+)$' )

                if ( $matchInfo -and $matchInfo.Matches -and $matchInfo.Matches.Groups.count )
                {
                    Add-Member -Membertype NoteProperty -Name 'host' -value $matchInfo.Matches.Groups[1] -InputObject $objTarget

                    if ( $matchInfo.Matches.Groups.count -eq 3 )
                    {
                        Add-Member -Membertype NoteProperty -Name 'protocol' -value $matchInfo.Matches.Groups[1] -InputObject $objTarget
                    }
                } else {
                    Add-Member -Membertype NoteProperty -Name 'host' -value $target -InputObject $objTarget
                }
                $objTargets += $objTarget
            }

            Add-Member -Membertype NoteProperty -Name 'sources' -value $objSources -InputObject $body
        }

        if ( $sourceFiles )
        {
            Add-Member -Membertype NoteProperty -Name 'sourceFiles' -value $sourceFiles -InputObject $body
        }

        if ( $targetFiles )
        {
            Add-Member -Membertype NoteProperty -Name 'targetFiles' -value $targetFiles -InputObject $body
        }

        if ( $DateFrom -or $RelativeDateFrom )
        {
            if ( $RelativeDateFrom )
            {
                if ( $RelativeDateFrom.endsWith( '+TZ' ) )
                {
                    $RelativeDateFrom = $RelativeDateFrom.Substring( 0, $RelativeDateFrom.length-3 ) + $timezoneOffset
                }
                Add-Member -Membertype NoteProperty -Name 'dateFrom' -value $RelativeDateFrom -InputObject $body
            } else {
                Add-Member -Membertype NoteProperty -Name 'dateFrom' -value ( Get-Date (Get-Date $DateFrom).ToUniversalTime() -Format 'u').Replace(' ', 'T') -InputObject $body
            }
        }

        if ( $DateTo -or $RelativeDateTo )
        {
            if ( $RelativeDateTo )
            {
                if ( $RelativeDateTo.endsWith( '+TZ' ) )
                {
                    $RelativeDateTo = $RelativeDateTo.Substring( 0, $RelativeDateTo.length-3 ) + $timezoneOffset
                }
                Add-Member -Membertype NoteProperty -Name 'dateTo' -value $RelativeDateTo -InputObject $body
            } else {
                Add-Member -Membertype NoteProperty -Name 'dateTo' -value ( Get-Date (Get-Date $DateTo).ToUniversalTime() -Format 'u').Replace(' ', 'T') -InputObject $body
            }
        }

        if ( $states )
        {
            Add-Member -Membertype NoteProperty -Name 'states' -value $states -InputObject $body
        }

        if ( $Limit )
        {
            Add-Member -Membertype NoteProperty -Name 'limit' -value $Limit -InputObject $body
        }

        if ( $Compact )
        {
            Add-Member -Membertype NoteProperty -Name 'compact' -value ($Compact -eq $True) -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/yade/transfers' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnItems = ( $response.Content | ConvertFrom-Json ).transfers
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        if ( $Timezone.Id -eq 'UTC' )
        {
            $returnItems
        } else {
            $returnItems | Select-Object -Property `
                                           controllerId, `
                                           id, `
                                           historyId, `
                                           orderId, `
                                           workflowPath, `
                                           job, `
                                           jobPosition, `
                                           _operation, `
                                           error, `
                                           numOfFiles, `
                                           source, `
                                           target, `
                                           state, `
                                           @{name='start'; expression={ ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($_.start)".Substring(0, 19), 'UTC'), $Timezone ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset }}, `
                                           @{name='end';   expression={ ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($_.end)".Substring(0, 19), 'UTC'), $Timezone ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset }}, `
                                           @{name='surveyDate'; expression={ ( [System.TimeZoneInfo]::ConvertTimeFromUtc( [datetime]::SpecifyKind( [datetime] "$($_.surveyDate)".SubString(0, 19), 'UTC'), $($Timezone) ) ).ToString("yyyy-MM-dd HH:mm:ss") + $timezoneOffset }}
        }

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
