function Export-JS7Object
{
<#
.SYNOPSIS
Export an XML configuration object such as a job, a job chain etc. from JOC Cockpit.

.DESCRIPTION
This cmdlet exports an XML configuration object that is stored with JOC Cockpit.

.PARAMETER Name
Specifies the name of the object, e.g. a job name.

.PARAMETER Directory
Specifies the directory in JOC Cockpit in which the object is available.

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
Specifies the XML file that the exported configuration object is written to.

.PARAMETER ForeLive
Specifies that the XML configuration object is not used from JOC Cockpit but is retrieved from the Controller's "live" folder. 
This option can be used to ensure that no draft versions of configurations objects are exported but objects only that
have been deployed to a Controller.

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
This cmdlet returns the XML configuration object.

.EXAMPLE
$jobXml = Export-JobSchedulerObject -Name job174 -Directory /some/directory -Type JOB

Returns the exported job configuration from the specified directory.

.EXAMPLE
Export-JobSchedulerObject -Name job174 -Directory /some/directory -Type JOB -File /tmp/job174.job.xml | Out-Null

Exports the XML job configuration to the specified file.

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
    [string] $FileExtension = 'zip',
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
        
        if ( !$AuditComment -and ( $AuditTimeSpent -or $AuditTicketLink ) )
        {
            throw "$($MyInvocation.MyCommand.Name): Audit Log comment required, use parameter -AuditComment if one of the parameters -AuditTimeSpent or -AuditTicketLink is used"
        }
        
        $exportObjects = @()
        $downloadFilename = "tmp-$(Get-Random).$($FileExtension)"
    }
    
    Process
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'objectType' -value $Type -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'path' -value $Path -InputObject $body
        
        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/inventory/deployable' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $deployableObject = ( $response.Content | ConvertFrom-JSON ).deployable
            
            if ( !$deployableObject.id )
            {
                throw ( $response | Format-List -Force | Out-String )
            }
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        $exportObjects += $deployableObject.id        
    }

    End
    {
        if ( $exportObjects.count )
        {
            $body = New-Object PSObject
            Add-Member -Membertype NoteProperty -Name 'configurations' -value $exportObjects -InputObject $body            
            Add-Member -Membertype NoteProperty -Name 'filename' -value $downloadFilename -InputObject $body
    
            [string] $requestBody = $body | ConvertTo-Json -Depth 100
            $response = Invoke-JS7WebRequest -Path '/publish/export' -Body $requestBody
            
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

            $requestResult
            
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): object exported"                
        } else {
            Write-Verbose ".. $($MyInvocation.MyCommand.Name): no object exported"                
        }

        Log-StopWatch $MyInvocation.MyCommand.Name $stopWatch
    }
}
