function Set-JS7Option
{
<#
.SYNOPSIS
Set options for access to the JS7 REST Web Service.

.PARAMETER DebugMaxOutputSize
When using $DebugPreference settings then the JS7 CLI provides the
XML documents of JS7 responses for inspection. Such responses are written to the
console window if their size does not exceed the max. output size.

Should the max. output size be exceeded then XML responses are written to temporary
files and a console debug message indicates the location of the respective file.

This cmdlet allows to set the max. output size to an individual value.

Default: 1000 Byte

.PARAMETER WebRequestTimeout
Specifies the number of seconds for establishing a connection to the JS7 REST Web Service.
With the timeout being exceeded an exception is raised.

Default: 15000 ms

.EXAMPLE
Set-JS7Option -WebRequestTimeout 10

Modifies the timeout for web service requests to 10s.

.LINK
about_js7

#>
[cmdletbinding(SupportsShouldProcess)]
param
(
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $DebugMaxOutputSize=1000,
    [Parameter(Mandatory=$False,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$True)]
    [int] $WebRequestTimeout=30
)
    Process
    {
		if ( $DebugMaxOutputSize )
		{
            if ( $PSCmdlet.ShouldProcess( 'jsOptionDebugMaxOutputSize' ) )
            {
                $script:jsOptionDebugMaxOutputSize = $DebugMaxOutputSize
            }
		}

		if ( $WebRequestTimeout )
		{
            if ( $PSCmdlet.ShouldProcess( 'jsOptionWebRequestTimeout' ) )
            {
                $script:jsOptionWebRequestTimeout = $WebRequestTimeout
            }
		}
	}
}
