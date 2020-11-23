function Rename-JS7Object
{
<#
.SYNOPSIS
Import an XML configuration object such as a job, a job chain etc. to JOC Cockpit.

.DESCRIPTION
This cmdlet imports an XML configuration object that is stored with JOC Cockpit.
However, the object is not immediately deployed, see Deploy-JobSchedulerObject cmdlet.

.PARAMETER Name
Specifies the name of the object, e.g. a job name.

.PARAMETER Directory
Specifies the directory in JOC Cockpit to which the object should be stored.

.PARAMETER Type
Specifies the object type which is one of: 

* JOB
* JOBCHAIN
* ORDER
* PROCESSCLASS
* AGENTCLUSTER
* LOCK
* SCHEDULE
* MONITOR
* NODEPARAMS
* HOLIDAYS

.PARAMETER File
Specifies the XML file that holds the configuration object.

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
This cmdlet accepts pipelined job objects that are e.g. returned from a Get-Job cmdlet.

.OUTPUTS
This cmdlet returns no output.

.EXAMPLE
Import-JobSchedulerObject -Name job174 -Directory /some/directory -Type JOB -File /tmp/job174.job.xml

Import the job configuration from the given file and store the job with the specified directory and name.

.LINK
about_js7

#>
[cmdletbinding()]
param
(
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Path,
    [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('FOLDER','WORKFLOW','JOBCLASS','AGENTCLUSTER','LOCK','JUNCTION','WORKINGDAYSCALENDAR','NONWORKINGDAYSCALENDAR','ORDER')]
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

        if ( $Type -ne 'FOLDER' -and $Path.endsWith('/') )
        {
            throw "$($MyInvocation.MyCommand.Name): path has to include directory, sub-directory and object name"
        }
        
        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }
    }
    
    Process
    {
        if ( $Path.endsWith('/') )
        {
            $Path = $Path.Substring( 0, $Path.Length-1 )
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
        Log-StopWatch $MyInvocation.MyCommand.Name $stopWatch
    }
}
