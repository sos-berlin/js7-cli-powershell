function Get-JS7JOCLogFilename
{
<#
.SYNOPSIS
Return the list of available JOC Cockpit log file names

.DESCRIPTION
Returns the list of JOC Cockpit log file names.

.OUTPUTS
This cmdlet returns an array of JOC Cockpit log file names.

.EXAMPLE
Get-JS7JOCLogFilename

Returns an array of log files available with JOC Cockpit.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        $body = New-Object PSObject

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/joc/logs' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            ( $response.Content | ConvertFrom-JSON ).filenames
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
