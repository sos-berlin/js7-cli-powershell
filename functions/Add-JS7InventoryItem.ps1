function Add-JS7InventoryItem
{
<#
.SYNOPSIS
Add a configuration object such as a workflow from a JSON file to the JOC Cockpit inventory

.DESCRIPTION
This cmdlet reads configuration objects from JSON files and stores them with JOC Cockpit.
Consider that imported objects have to be deployed with the Deploy-JS7DeployableObject and Deploy-JS7ReleasableObject cmdlets.

.PARAMETER Path
Specifies the folder, sub-folder and name of the object to be added, e.g. a workflow path.

.PARAMETER Type
Specifies the object type which is one of: 

* WORKFLOW
* JOBCLASS
* LOCK
* JUNCTION
* WORKINGDAYSCALENDAR
* NONWORKINGDAYSCALENDAR
* SCHEDULE

.PARAMETER File
Specifies the path to the JSON file that holds the configuration object.

.PARAMETER DocPath
Specifies the path to the documentation that is assigned the object.

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
This cmdlet accepts pipelined objects that are e.g. returned from a Get-JS7Workflow cmdlet.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Add-JS7InventoryItem -Path /some/directory/sampleWorkflow -Type 'WORKFLOW' -File /tmp/workflow-174.json

Read the worfklow configuration from the given file and store the workflow with the specified path.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('WORKFLOW','JOBCLASS','LOCK','JUNCTION','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','ORDER')]
    [string] $Type,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $File,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $DocPath,
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

        if ( $Path.endsWith('/') )
        {
            throw "$($MyInvocation.MyCommand.Name): path has to include directory, sub-directory and object name"
        }
        
        if ( !$File )
        {
            throw "$($MyInvocation.MyCommand.Name): parameter -File required for import"
        }

        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }
    }
    
    Process
    {
        if ( !(Test-Path -Path $File -ErrorAction Continue) )
        {
            throw "$($MyInvocation.MyCommand.Name): file not found or not accessible: $File"
        }


        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'valid' -value $False -InputObject $body
        
        $objConfiguration = Get-Content -Raw -Path $File | ConvertFrom-Json -Depth 100
        Add-Member -Membertype NoteProperty -Name 'configuration' -value $objConfiguration -InputObject $body
        
        if ( $DocPath )
        {
            Add-Member -Membertype NoteProperty -Name 'docPath' -value $DocPath -InputObject $body
        }
    
        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/inventory/store' -Body $requestBody
        
        if ( $response.StatusCode -eq 200 )
        {
            $requestResult = ( $response.Content | ConvertFrom-JSON )
            
            if ( !$requestResult.path )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }
    
        Write-Verbose ".. $($MyInvocation.MyCommand.Name): object imported: $Path"                
    }

    End
    {
        Log-StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Touch-JS7Session
    }
}
