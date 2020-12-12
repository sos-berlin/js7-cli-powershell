function Rename-JS7InventoryItem
{
<#
.SYNOPSIS
Rename an object in the JOC Cockpit inventory

.DESCRIPTION
This cmdlet renames an object in the JOC Cockpit inventory.

.PARAMETER Path
Specifies the folder, sub-folders and object name that should be renamed in the JOC Cockpit inventory.

.PARAMETER Type
Specifies the object type which is one of: 

* WORKFLOW
* JOBCLASS
* LOCK
* JUNCTION
* WORKINGDAYSCALENDAR
* NONWORKINGDAYSCALENDAR
* SCHEDULE

.PARAMETER Name
Specifies the new name of the object, e.g. the name of a workflow.

.PARAMETER AuditComment
Specifies a free text that indicates the reason for the current intervention, e.g. "business requirement", "maintenance window" etc.

The Audit Comment is visible from the Audit Log view of JOC Cockpit.
This parameter is not mandatory, however, JOC Cockpit can be configured to enforece Audit Log comments for any interventions.

.PARAMETER AuditTimeSpent
Specifies the duration in minutes that the current intervention required.

This information is visible with the Audit Log view. It can be useful when integrated
with a ticket system that logs the time spent on interventions with JobScheduler.

.PARAMETER AuditTicketLink
Specifies a URL to a ticket system that keeps track of any interventions performed for JobScheduler.

This information is visible with the Audit Log view of JOC Cockpit. 
It can be useful when integrated with a ticket system that logs interventions with JobScheduler.

.INPUTS
This cmdlet accepts pipelined job objects that are e.g. returned from a Get-JS7Workflow cmdlet.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Rename-JS7InventoryItem -Path /some_path/workflow173 -Type WORKFLOW -Name workflow174

Renames the given workflow in the JOC Cockpit inventory.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('WORKFLOW','JOBCLASS','LOCK','JUNCTION','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','SCHEDULE')]
    [string] $Type,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Name,
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
        if ( $Path.endsWith('/') )
        {
            throw "$($MyInvocation.MyCommand.Name): path has to include folder, sub-folder and object name"
        }
        
        if ( $Name.IndexOf( '/' ) -ge 0 )
        {
            throw "$($MyInvocation.MyCommand.Name): object name cannot container a folder separator such as '/'"            
        }
        
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'name' -value $Name -InputObject $body
            
        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/inventory/rename' -Body $requestBody
        
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
    
        Write-Verbose ".. $($MyInvocation.MyCommand.Name): object renamed: $Name"                
    }

    End
    {
        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session
    }
}
