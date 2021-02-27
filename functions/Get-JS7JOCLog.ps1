function Get-JS7JOCLog
{
<#
.SYNOPSIS
Return the JOC Cockpit log

.DESCRIPTION
Returns the latest JOC Cockpit log or the specified log file. Should the JOC Cockpit log have rotated
then previous log files can be specified using the -Filename parameter. The list of JOC Cockpit log file names is available from the Get-JS7JOCLogFilename cmdlet.

.PARAMETER Filename
Optionally specifies a log file name. Without use of this parameter the most recent JOC Cockpit log is returned.
A file name can be specified as returned by the list of available JOC Cockpit logs with the Get-JS7JOCLogFilename cmdlet.

.INPUTS
This cmdlet accepts pipelined JOC Cockpit logs file names that are e.g. returned from the Get-JS7JOCLogFilename cmdlet.

.OUTPUTS
This cmdlet returns the JOC Cockpit log output.

.EXAMPLE
Get-JS7JOCLog | Out-File /tmp/joc.log

Returns the output of the most recent JOC Cockpit log and writes it to a file.

.EXAMPLE
$logs = Get-JS7JOCLogFilename | Get-JS7JOCLog

Returns the output of any available JOC Cockpit log files to an array.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Filename
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        $body = New-Object PSObject
        if ( $Filename )
        {
            Add-Member -Membertype NoteProperty -Name 'filename' -value $Filename -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/joc/log' -Body $requestBody

        if ( $response.StatusCode -ne 200 )
        {
            throw ( $response | Format-List -Force | Out-String )
        }

        [System.Text.Encoding]::UTF8.GetString( $response.Content )
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
