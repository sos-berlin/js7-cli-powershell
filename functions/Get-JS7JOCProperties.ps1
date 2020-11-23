function Get-JS7JOCProperties
{ 
<#
.SYNOPSIS
Returns JS7 properties

.DESCRIPTION
A number of JS7 properties can be specified with the JOC Cockpit joc.properties file.
This cmdlet returns the list of active properties.

.EXAMPLE
$props = Get-JS7JOCProperties

Returns the list of JS7 JOC Cockpit properties

.LINK
about_js7

#>
param
(
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch
    }

    Process
    {        
        $response = Invoke-JS7WebRequest -Path '/joc/properties' 
        
        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-JSON )
            
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
        Log-StopWatch $MyInvocation.MyCommand.Name $stopWatch
    }
}
