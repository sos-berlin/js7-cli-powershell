function Get-JS7ControllerVersion
{
<#
.SYNOPSIS
Returns the JS7 Controller version

.DESCRIPTION
The cmdlet returns the version of the JS7 Controller.

.EXAMPLE
Get-JS7ControllerVersion

Returns the JS7 Controller version.

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
