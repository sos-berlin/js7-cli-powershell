function Get-JS7JOCSettings
{
<#
.SYNOPSIS
Returns JS7 settings

.DESCRIPTION
A number of JS7 settings are available - for example from the JOC Cockpit Settings page and from Identity Services.
This cmdlet returns such settings, for example:

* Global Settings
* Identity Service Settings

The following REST Web Service API resources are used:

* /configurations
* /configuration

.PARAMETER ConfigurationType
Specifies the type of settings that defaults to GLOBALS. Possible values include:

* GLOBALS
* IAM

.PARAMETER ObjectType
Optionally specifies the type of an object depending on the configuration type, for example:

* Configuration Type: GLOBALS
* Configuration Type: IAM
** Object Type: JOC
** Object Type: LDAP
** Object Type: VAULT

.PARAMETER Name
Optionally specifies the name of an object, for example for the configuration type IAM and the object type LDAP the name of the LDAP Identity Service has to be specified.

.INPUTS
This cmdlet accepts pipelined input.

.OUTPUTS
This cmdlet returns two objects:

* settings: the settings object as returned from the REST Web Service API
* item: a PowerShell object holding the configuration items

.EXAMPLE
$settings,$item = Get-JS7JOCSettings

Returns the global JS7 settings as available from the JOC Cockpit Settings page.

.EXAMPLE
$settings,$item = Get-JS7JOCSettings -ConfigurationType 'IAM' -ObjectType 'LDAP' -Name 'PublicLDAP'

Returns settings for the Identity Service 'PublicLDAP'.

.LINK
about_JS7

#>
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [ValidateSet('GLOBALS','IAM',IgnoreCase = $False)]
    [string] $ConfigurationType = 'GLOBALS',
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $ObjectType,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [string] $Name
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'configurationType' -value $ConfigurationType -InputObject $body

        switch ( $ConfigurationType )
        {
            'GLOBALS'
            {
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'account' -value $script:jsWebServiceCredential.UserName -InputObject $body

                [string] $requestBody = $body | ConvertTo-Json -Depth 100

                $response = Invoke-JS7WebRequest -Path '/configurations' -Body $requestBody
                if ( $response.StatusCode -eq 200 )
                {
                    $requestResult = ( $response.Content | ConvertFrom-Json )

                    if ( !$requestResult )
                    {
                        throw ( $response | Format-List -Force | Out-String )
                    }
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }

                $requestResult.configurations
                $requestResult.configurations.configurationItem | ConvertFrom-Json -Depth 100
            }

            'IAM'
            {
                Add-Member -Membertype NoteProperty -Name 'id' -value 0 -InputObject $body

                if ( $ObjectType )
                {
                    Add-Member -Membertype NoteProperty -Name 'objectType' -value $ObjectType -InputObject $body
                }

                if ( $Name )
                {
                    Add-Member -Membertype NoteProperty -Name 'name' -value $Name -InputObject $body
                }

                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/configuration' -Body $requestBody

                if ( $response.StatusCode -eq 200 )
                {
                    $requestResult = ( $response.Content | ConvertFrom-Json )

                    if ( !$requestResult )
                    {
                        throw ( $response | Format-List -Force | Out-String )
                    }
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }

                $requestResult.configuration
                $requestResult.configuration.configurationItem | ConvertFrom-Json -Depth 100
            }
        }
        Write-Verbose ".. $($MyInvocation.MyCommand.Name): settings returned"
    }

    End
    {
        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
