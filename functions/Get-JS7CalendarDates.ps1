function Get-JS7CalendarDates
{
<#
.SYNOPSIS
Returns dates from a calendar with the JOC Cockpit inventory

.DESCRIPTION
Return the list of dates that are included with a calendar.

Past and future dates can be retrieved.

.PARAMETER CalendarPath
Optionally specifies the path and name of a calendar that should be returned.

One of the parameters -Folder, -CalendarPath or -RegularExpression has to be specified if no pipelined order objects are provided.

.PARAMETER DateFrom
Specifies the date starting from which calendar dates should be returned.
Consider that a UTC date has to be provided.

Default: Begin of the current day as a UTC date

.PARAMETER DateTo
Specifies the date until which calendar dates should be returned.
Consider that a UTC date has to be provided.

Default: End of the calendar's date range or the end of the current year as a UTC date

.OUTPUTS
This cmdlet returns an array of calendar dates.

.EXAMPLE
$dates = Get-JS7CalendarDates -CalendarPath /BusinessDays

Returns the dates specified by the indicated calendar that is stored with the path "/BusinessDays".

.EXAMPLE
$dates = Get-JS7CalendarDates -CalendarPath /BusinessDays -DateTo (Get-Date).AddDays(30)

Returns the calendar dates for the next 30 days.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $CalendarPath,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateFrom,
    [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True)]
    [DateTime] $DateTo
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch
        
        $returnCalendarDates = @()
    }
        
    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter CalendarPath=$CalendarPath"
    
        if ( $CalendarPath.endsWith( '/') )
        {
            throw "$($MyInvocation.MyCommand.Name): the -CalendarPath parameter has to specify the folder and name of a calendar"
        }

        if ( $CalendarPath -and !$CalendarPath.startsWith( '/') )
        {
            $CalendarPath = '/' + $CalendarPath
        }


        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'path' -value $CalendarPath -InputObject $body

        if ( $DateFrom )
        {
            Add-Member -Membertype NoteProperty -Name 'dateFrom' -value (Get-Date $DateFrom -Format 'yyyy-MM-dd') -InputObject $body
        }
        
        if ( $DateTo )
        {
            Add-Member -Membertype NoteProperty -Name 'dateTo' -value (Get-Date $DateTo -Format 'yyyy-MM-dd') -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/calendar/dates' -Body $requestBody
    
        if ( $response.StatusCode -eq 200 )
        {
            $returnCalendarDateItems = ( $response.Content | ConvertFrom-JSON ).dates
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }
    
        $returnCalendarDates += $returnCalendarDateItems
    }

    End
    {        
        $returnCalendarDates

        if ( $returnCalendarDates.count )
        {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): $($returnCalendarDates.count) calendar dates found"
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no calendar dates found"
        }
        
        Log-StopWatch $MyInvocation.MyCommand.Name $stopWatch
    }
}
