function Get-JS7Version
{
<#
.SYNOPSIS
Returns the JS7 Controller version

.DESCRIPTION
The cmdlet returns the version of the JS7 Controller.

.PARAMETER NoCache
Specifies that the cache for JS7 objects is ignored.
This results in the fact that for each Get-JS7* cmdlet execution the response is 
retrieved directly from the JS7 Controller and is not resolved from the cache.

.EXAMPLE
Get-JS7Version

Returns the JS7 version.

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
        $stopWatch = Start-StopWatch        
    }
    
    Process
    {    
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/controller/p' -Body $requestBody
    
        if ( $response.StatusCode -eq 200 )
        {
            $returnStatus = ( $response.Content | ConvertFrom-JSON ).controller
            $returnStatus.version            
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }    
    }

    End
    {
        Log-StopWatch $MyInvocation.MyCommand.Name $stopWatch
    }    
}
