function Get-JS7JOCVersion
{
<#
.SYNOPSIS
Returns the JS7 JOC Cockpit version

.DESCRIPTION
The cmdlet returns the version of the JS7 JOC Cockpit.

The following REST Web Service API resources are used:

* /joc/versions

.EXAMPLE
Get-JS7JOCVersion

Returns the JS7 JOC Cockpit version.

.LINK
about_JS7

#>
[cmdletbinding()]
param
()
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        $script:jsWebService.JOCVersion
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
