function Submit-JS7Notice
{
<#
.SYNOPSIS
Submits a Notice to a Notice Board in the JOC Cockpit

.DESCRIPTION
This cmdlet submits a Notice to a Notice Board in the JOC Cockpit.

The following REST Web Service API resources are used:

* /notice/post

.PARAMETER NoticeBoardPath
Specifies the path to the Notice Board which includes the folder, sub-folders and the name of the Notice Board.

.PARAMETER NoticeId
Specifies the identifier of the Notice to be submitted.

.PARAMETER EndOfLifeDate
Specifies an absolute date for the lifetime of the Notice, e.g.

* (Get-Date).AddSeconds(10): 10s from now
* (Get-Date).AddDays(1).AddHours(4).AddSeconds(10): 1 day, 4 hours and 10s from now

Note that the cmdlet converts the data specified to UTC.

.PARAMETER EndOfLifeRelativeDate
Specifies a relative date for the lifetime of the Notice, e.g.

* 1s, 2s: one second from now, two seconds from now
* 1m, 2m: one minute from now, two minutes from now
* 1h, 2h: one hour from now, two hours from now
* 1d, 2d: one day from now, two days from now
* 1w, 2w: one week from now, two weeks from now
* 1M, 2M: one month from now, two months from now
* 1y, 2y: one year from now, two years from now

Optionally a time offset can be specified, e.g. -1d+02:00, as otherwise midnight UTC is assumed.
Alternatively a timezone offset can be added, e.g. by using -1d+TZ. This will be calculated by the cmdlet
for the timezone that is specified with the -Timezone parameter.

.PARAMETER Timezone
Specifies the timezone for which dates should be converted to from the history information.
A timezone can e.g. be specified like this:

  Submit-JS7Notice -Timezone (Get-Timezone -Id 'GMT Standard Time')

All dates in JS7 are UTC and can be converted e.g. to the local time zone like this:

  Submit-JS7Notice -Path /ProductDemo/Seaqencning/pdSequenceSynchroneously -NoticeId 2022-07-14 -EndOfLifeRelativeDate 3h -Timezone (Get-Timezone)

Default: Dates are specified in UTC.

.PARAMETER ControllerId
Optionally specifies the identification of the Controller to which to submit Notices.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of the JOC Cockpit.
This parameter is not mandatory. However, the JOC Cockpit can be configured to require Audit Log comments for all interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is shown in the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JS7.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JS7.

This information is shown in the Audit Log view of JOC Cockpit.
It can be useful when integrated with a ticket system that logs interventions with JS7.

.INPUTS
This cmdlet does not accept pipelined input.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Submit-JS7Notice -NoticeBoardPath -Folder /ProductDemo/Sequencing/pdSequenceSynchroneously -NoticeId 2022-03-24

Submits a Notice to the indicated Notice Board.

.LINK
about_JS7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Alias('Path')]
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $NoticeBoardPath,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $NoticeId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $EndOfLifeDate,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $EndOfLifeRelativeDate,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [TimeZoneInfo] $Timezone = (Get-Timezone -Id 'UTC'),
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ControllerId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $AuditComment,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $AuditTimeSpent,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [Uri] $AuditTicketLink
)
	Begin
	{
		Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }

        if ( $EndOfLifeDate -and $EndOfLifeRelativeDate )
        {
            throw "$($MyInvocation.MyCommand.Name): Only one of the Arguments -EndOfLifeDate or -EndOfLifeRelativeDate can be used"
        }
    }

    Process
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
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $ControllerId -InputObject $boldy
        } else {
            Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        }

        Add-Member -Membertype NoteProperty -Name 'noticeBoardPath' -value $NoticeBoardPath -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'noticeId' -value $NoticeId -InputObject $body

        if ( $EndOfLifeDate -or $EndOfLifeRelativeDate )
        {
            if ( $EndOfLifeRelativeDate )
            {
                if ( $EndOfLifeRelativeDate.endsWith( '+TZ' ) )
                {
                    $EndOfLifeRelativeDate = $EndOfLifeRelativeDate.Substring( 0, $EndOfLifeRelativeDate.length-3 ) + $timezoneOffset
                }

                Add-Member -Membertype NoteProperty -Name 'endOfLife' -value $EndOfLifeRelativeDate -InputObject $body
            } else {
                Add-Member -Membertype NoteProperty -Name 'endOfLife' -value ( Get-Date (Get-Date $EndOfLifeDate).ToUniversalTime() -Format 'u').Replace(' ', 'T') -InputObject $body
            }
        }

        if ( $AuditComment -or $AuditTimeSpent -or $AuditTicketLink )
        {
            $objAuditLog = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'comment' -value $AuditComment -InputObject $objAuditLog

            if ( $AuditTimeSpent )
            {
                Add-Member -Membertype NoteProperty -Name 'timeSpent' -value $AuditTimeSpent -InputObject $objAuditLog
            }

            if ( $AuditTicketLink )
            {
                Add-Member -Membertype NoteProperty -Name 'ticketLink' -value $AuditTicketLink -InputObject $objAuditLog
            }

            Add-Member -Membertype NoteProperty -Name 'auditLog' -value $objAuditLog -InputObject $body
        }

        if ( $PSCmdlet.ShouldProcess( $NoticeBoardPath, '/notice/post' ) )
        {
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/notice/post' -Body $requestBody

            if ( $response.StatusCode -eq 200 )
            {
                $requestResult = ( $response.Content | ConvertFrom-Json )

                if ( !$requestResult.ok )
                {
                    throw ( $response | Format-List -Force | Out-String )
                }
            } else {
                throw ( $response | Format-List -Force | Out-String )
            }

            Write-Verbose ".. $($MyInvocation.MyCommand.Name): notice submitted: $NoticeId"
        }
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
