function Get-JS7InventoryStatistics
{
<#
.SYNOPSIS
Returns statistics information about the JOC Cockpit inventory

.DESCRIPTION
Statistics informationn includes the number of workflows, jobs etc. from the JOC Cockpit inventory

.OUTPUTS
This cmdlet returns an array of statistics information items.

.EXAMPLE
$stats = Get-JS7InventoryStatistics

Returns information items such as the number of workflows and jobs from the JOC Cockpit inventory.

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
        Write-Debug ".. $($MyInvocation.MyCommand.Name):"
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/inventory/statistics' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $returnStatistics = ( $response.Content | ConvertFrom-JSON )
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $returnStatistics

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
