function Switch-JS7JOCInstance
{ 
<#
.SYNOPSIS
Switches the role of the active JS7 JOC Cockpit instance in a cluster

.DESCRIPTION
During switchover the active JOC Cockpit instance becomes passive and vice versa.

.PARAMETER MemberId
Specifies the identification of the passive JOC Cockpit cluster member that should become active.
This information is provided with the Get-JS7JOCInstance cmdlet that returns an array of passive cluster members.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of JOC Cockpit.
This parameter is not mandatory, however, JOC Cockpit can be configured to enforce Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is visible with the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JobScheduler.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JobScheduler.

This information is visible with the Audit Log view of JOC Cockpit. 
It can be useful when integrated with a ticket system that logs interventions with JobScheduler.

.EXAMPLE
Switch-JS7JOCInstance

Switches the roles of the active and passive JS7 JOC Cockpit instances:
The active instance becomes passive and one of the passive instances becomes active.

.EXAMPLE
Switch-JS7JOCInstance -MemberId ( (Get-JS7JOCInstance).Passive | Where-Object -Property 'host' -eq -Value 'joc-2-0-secondary' ).memberId

Switches the role of the active JOC Cockpit instance to the indicated cluster member that is currently passive. 
As any number of JOC Cockpit passive cluster members can be used, one of them is selected by its hostname.

.LINK
about_js7

#>
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $MemberId,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $AuditComment,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $AuditTimeSpent,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [Uri] $AuditTicketLink
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-StopWatch

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }
    }

    Process
    {
        if ( !$MemberId )
        {
            $jocCluster = Get-JS7JOCCluster
            if ( $jocCluster.passive.count -gt 0 )
            {
                $MemberId = $jocCluster.passive[0].memberId
            }
        }
        
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'memberId' -value $MemberId -InputObject $body

        if ( $AuditComment -or $AuditTimeSpent -or $AuditTicketLink )
        {
            $objAuditLog = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'comment' -value $AuditComment -InputObject $objAuditLog

            if ( $AuditTimeSpent )
            {
                Add-Member -Membertype NoteProperty -Name 'timeSpent' -value $AuditTimeSpent -InputObject $objAuditLog
            }

            if ( $AuditTicketLink )
            {
                Add-Member -Membertype NoteProperty -Name 'ticketLink' -value $AuditTicketLink -InputObject $objAuditLog
            }

            Add-Member -Membertype NoteProperty -Name 'auditLog' -value $objAuditLog -InputObject $body
        }

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/joc/cluster/switch_member' -Body $requestBody
                
        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-JSON )
            
            if ( !$requestResult.ok )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }        
    }

    End
    {
        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session
    }
}
