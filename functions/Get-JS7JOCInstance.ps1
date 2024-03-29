function Get-JS7JOCInstance
{
<#
.SYNOPSIS
Returns status information of cluster members for JS7 JOC Cockpit instances

.DESCRIPTION
Status information of each JOC Cockpit cluster member is returned.

The following REST Web Service API resources are used:

* /controller/components

.EXAMPLE
$cluster = Get-JS7JOCInstance

Returns status information about the JS7 JOC Cockpit cluster members.

.LINK
about_JS7

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
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/controller/components' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-JSON ).jocs
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $returnJOCs = New-Object PSObject
        $returnPassiveJOCs = @()

        foreach( $joc in $requestResult )
        {
            if ( $joc.clusterNodeState."_text" -eq 'active' )
            {
                Add-Member -Membertype NoteProperty -Name 'active' -value $joc -InputObject $returnJOCs
            } else {
                $returnPassiveJOCs += $joc
            }
        }

        if ( $returnPassiveJOCs )
        {
            Add-Member -Membertype NoteProperty -Name 'passive' -value @( $returnPassiveJOCs ) -InputObject $returnJOCs
        }

        $returnJOCs
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
