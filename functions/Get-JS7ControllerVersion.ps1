function Get-JS7ControllerVersion
{
<#
.SYNOPSIS
Returns the JS7 Controller version

.DESCRIPTION
The cmdlet returns the version of the JS7 Controller.

The following REST Web Service API resources are used:

* /joc/versions

.EXAMPLE
Get-JS7ControllerVersion

Returns the JS7 Controller version.

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
        $script:jsWebService.ControllerVersion
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
