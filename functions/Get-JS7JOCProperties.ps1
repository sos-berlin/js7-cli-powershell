function Get-JS7JOCProperties
{
<#
.SYNOPSIS
Returns JS7 JOC Cockpit properties

.DESCRIPTION
A number of properties can be specified with the JOC Cockpit Settings page.
This cmdlet returns the list of active properties.

The following REST Web Service API resources are used:

* /joc/properties

.EXAMPLE
$props = Get-JS7JOCProperties

Returns the list of JS7 JOC Cockpit properties

.LINK
about_JS7

#>
param
()
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        $response = Invoke-JS7WebRequest -Path '/joc/properties'

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-Json )

            if ( !$requestResult )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $requestResult
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
