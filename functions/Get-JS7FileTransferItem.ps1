function Get-JS7FileTransferItem
{
<#
.SYNOPSIS
Returns the XML representation of a file transfer configuration managed with the JOC Cockpit inventory

.DESCRIPTION
A file transfer configuration is returned from the JOC Cockpit inventory

.PARAMETER Name
Specifies the name of the file transfer configuration in the JOC Cockpit inventory.

.OUTPUTS
This cmdlet returns the XML representation of a file transfer inventory object.

.EXAMPLE
$xml = Get-JS7FileTransferItem

Returns the list of available file transfer configurations.

.EXAMPLE
$xml = Get-JS7FileTransferItem -Name primaryAgent

Returns the XML object of the given file transfer configuration.

.LINK
about_js7

#>
[cmdletbinding()]
[OutputType([Hashtable])]
[OutputType([XML])]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string] $Name
)
    Begin
    {
        Approve-JS7Command $MyInvocation.MyCommand
        $stopWatch = Start-JS7StopWatch
    }

    Process
    {
        Write-Debug ".. $($MyInvocation.MyCommand.Name): Name = $Name"
    }

    End
    {
        $body = New-Object PSObject
        Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
        Add-Member -Membertype NoteProperty -Name 'objectType' -value 'YADE' -InputObject $body

        [string] $requestBody = $body | ConvertTo-Json -Depth 100
        $response = Invoke-JS7WebRequest -Path '/xmleditor/read' -Body $requestBody

        if ( $response.StatusCode -eq 200 )
        {
            $fileTransferItems = ( $response.Content | ConvertFrom-Json ).configurations
        } else {
            throw ( $response | Format-List -Force | Out-String )
        }

        if ( $Name )
        {
            $found = $False
            foreach( $fileTransferItem in $fileTransferItems )
            {
                if ( $fileTransferItem.name -eq $Name )
                {
                    $found = $True
                    break
                }
            }

            if ( $found )
            {
                Write-Verbose ".. $($MyInvocation.MyCommand.Name): File Transfer Item found: $Name"

                $body = New-Object PSObject
                Add-Member -Membertype NoteProperty -Name 'controllerId' -value $script:jsWebService.ControllerId -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'objectType' -value 'YADE' -InputObject $body
                Add-Member -Membertype NoteProperty -Name 'id' -value $fileTransferItem.id -InputObject $body

                [string] $requestBody = $body | ConvertTo-Json -Depth 100
                $response = Invoke-JS7WebRequest -Path '/xmleditor/read' -Body $requestBody

                if ( $response.StatusCode -eq 200 )
                {
                    $fileTransferItem = ( $response.Content | ConvertFrom-Json ).configuration
                } else {
                    throw ( $response | Format-List -Force | Out-String )
                }

                [xml] $fileTransferItem.configuration
            } else {
                Write-Verbose ".. $($MyInvocation.MyCommand.Name): No File Transfer Item found for name: $Name"
            }
        } else {
            $fileTransferItems
        }

        Trace-JS7StopWatch -CommandName $MyInvocation.MyCommand.Name -StopWatch $stopWatch
        Update-JS7Session
    }
}
