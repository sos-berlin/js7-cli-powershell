function Get-JS7NotificationConfiguration
{
<#
.SYNOPSIS
Returns the configuration for Notifications

.DESCRIPTION
The configuration for Notifications is returned from a JOC Cockpit instance.

The following REST Web Service API resources are used:

* /notification

.PARAMETER Released
Optionally specifies that the released version of the configuration is returned, not a draft version that optionally exists.

.OUTPUTS
This cmdlet returns the configuration of notifications.

.EXAMPLE
$configuration = Get-JS7NotificationConfiguration

Returns the XML configuration of notifications.

.EXAMPLE
$configuration = Get-JS7NotificationConfiguration -Released

Returns the XML configuration of notifications.

.LINK
about_JS7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [switch] $Released
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): parameter Released=$Released"
    }

    End
    {

        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'forceRelease' -value ($Released -eq $True) -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/notification' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnNotification = ( $response.Content | ConvertFrom-Json )
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $returnNotification

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
