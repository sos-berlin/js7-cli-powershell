@{

# Script module or binary module file associated with this manifest.
RootModule = 'JS7.psm1'

# Version number of this module.
ModuleVersion = '2.0.15.0'

# ID used to uniquely identify this module
GUID = '904a35e3-39b4-40bf-ab5f-e8c4ad5ae38d'

# Author of this module
Author = 'Andreas Pueschel'

# Company or vendor of this module
CompanyName = 'SOS GmbH'

# Copyright statement for this module
Copyright = 'Copyright (c) 2020 by SOS GmbH, licensed under GPL v3 License.'

# Description of the functionality provided by this module
Description = 'Manage and Control workflows and jobs with JS7 JobScheduler Controller and Agents, access the JS7 REST Web Service API'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Functions to export from this module
FunctionsToExport = @(
    'Add-JS7Folder',
    'Add-JS7GitCredentials',
    'Add-JS7InventoryItem',
    'Add-JS7Order',
    'Add-JS7SigningKey',
    'Confirm-JS7Order',
	'Connect-JS7',
    'Disable-JS7Agent',
    'Disable-JS7IAMAccount',
    'Disable-JS7Subagent',
    'Disconnect-JS7',
    'Enable-JS7Agent',
    'Enable-JS7IAMAccount',
    'Enable-JS7Subagent',
    'Export-JS7InventoryItem',
    'Import-JS7InventoryItem',
    'Get-JS7Agent',
    'Get-JS7AgentReport',
    'Get-JS7AgentStatus',
    'Get-JS7AuditLog',
    'Get-JS7Calendar',
    'Get-JS7CalendarDates',
    'Get-JS7ControllerInstance',
    'Get-JS7ControllerStatus',
    'Get-JS7ControllerVersion',
    'Get-JS7DailyPlanOrder',
    'Get-JS7DeployableItem',
    'Get-JS7FileTransferHistory',
    'Get-JS7FileTransferHistoryFile',
    'Get-JS7FileTransferItem',
    'Get-JS7GitCredentials',
    'Get-JS7IAMAccount',
    'Get-JS7IAMFolder',
    'Get-JS7IAMAccountPermission',
    'Get-JS7IAMPermission',
    'Get-JS7IAMRole',
    'Get-JS7IAMService',
    'Get-JS7InventoryItem',
    'Get-JS7InventoryStatistics',
    'Get-JS7ReleasableItem',
    'Get-JS7JOCInstance',
    'Get-JS7JOCLicense',
    'Get-JS7JOCLog',
    'Get-JS7JOCLogFilename',
    'Get-JS7JOCProperties',
    'Get-JS7JOCSettings',
    'Get-JS7Lock',
    'Get-JS7Notice',
    'Get-JS7NoticeBoard',
    'Get-JS7Notification',
    'Get-JS7NotificationConfiguration',
    'Get-JS7Order',
    'Get-JS7OrderAddPosition',
    'Get-JS7OrderHistory',
    'Get-JS7OrderLog',
    'Get-JS7OrderSnapshot',
    'Get-JS7OrderSummary',
    'Get-JS7RepositoryItem',
    'Get-JS7OrderResumePosition',
    'Get-JS7Schedule',
    'Get-JS7SigningKey',
    'Get-JS7SubagentCluster',
    'Get-JS7SystemCredentials',
    'Get-JS7TaskHistory',
    'Get-JS7TaskLog',
    'Get-JS7Workflow',
    'Hide-JS7Agent',
    'Invoke-JS7ApiRequest',
    'Invoke-JS7GitRepositoryAdd',
    'Invoke-JS7GitRepositoryCheckout',
    'Invoke-JS7GitRepositoryClone',
    'Invoke-JS7GitRepositoryCommit',
    'Invoke-JS7GitRepositoryPull',
    'Invoke-JS7GitRepositoryPush',
    'Invoke-JS7IAMChangePassword',
    'Invoke-JS7IAMForcePasswordChange',
    'Invoke-JS7IAMResetPassword',
    'Invoke-JS7TestRun',
    'New-JS7ControllerInstance',
    'New-JS7DailyPlanOrder',
    'New-JS7SigningKey',
    'New-JS7Subagent',
    'Publish-JS7Agent',
    'Publish-JS7ClusterAgent',
    'Publish-JS7DeployableItem',
    'Publish-JS7ReleasableItem',
    'Publish-JS7SubagentCluster',
    'Remove-JS7Agent',
    'Remove-JS7CompletedOrder',
    'Remove-JS7DailyPlanOrder',
    'Remove-JS7DailyPlanSubmission',
    'Remove-JS7FileTransferItem',
    'Remove-JS7Folder',
    'Remove-JS7GitCredentials',
    'Remove-JS7IAMAccount',
    'Remove-JS7IAMFolder',
    'Remove-JS7IAMPermission',
    'Remove-JS7IAMRole',
    'Remove-JS7IAMService',
    'Remove-JS7InventoryItem',
    'Remove-JS7Notice',
    'Remove-JS7RepositoryItem',
    'Remove-JS7Subagent',
    'Remove-JS7SubagentCluster',
    'Rename-JS7Folder',
    'Rename-JS7IAMAccount',
    'Rename-JS7IAMFolder',
    'Rename-JS7IAMPermission',
    'Rename-JS7IAMRole',
    'Rename-JS7IAMService',
    'Rename-JS7InventoryItem',
    'Reset-JS7Agent',
    'Reset-JS7Subagent',
    'Restart-JS7ControllerInstance',
    'Restart-JS7JOCService',
    'Restore-JS7Agent',
    'Restore-JS7Folder',
    'Restore-JS7InventoryItem',
    'Resume-JS7Order',
    'Resume-JS7Workflow',
    'Revoke-JS7ClusterAgent',
    'Revoke-JS7SubagentCluster',
	'Send-JS7Mail',
    'Set-JS7Agent',
    'Set-JS7ClusterAgent',
    'Set-JS7Controller',
    'Set-JS7Credentials',
    'Set-JS7Option',
    'Show-JS7Agent',
    'Set-JS7FileTransferItem',
    'Set-JS7IAMAccount',
    'Set-JS7IAMFolder',
    'Set-JS7IAMPermission',
    'Set-JS7IAMRole',
    'Set-JS7IAMService',
    'Set-JS7InventoryItem',
    'Set-JS7JOCSettings',
    'Set-JS7NotificationConfiguration',
    'Set-JS7RepositoryItem',
    'Set-JS7Subagent',
    'Set-JS7SubagentCluster',
    'Start-JS7ExecutableFile',
    'Start-JS7Order',
    'Stop-JS7ControllerInstance',
    'Stop-JS7DailyPlanOrder',
    'Stop-JS7Order',
    'Submit-JS7DailyPlanOrder',
    'Submit-JS7Notice',
    'Suspend-JS7Order',
    'Suspend-JS7Workflow',
    'Switch-JS7ControllerInstance',
    'Switch-JS7JOCInstance',
    'Test-JS7ControllerInstance',
    'Update-JS7FromRepositoryItem'
)

# # Cmdlets to export from this module
# CmdletsToExport = '*'

# Variables to export from this module
# VariablesToExport = @()

# # Aliases to export from this module
# AliasesToExport = '*'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

PrivateData = @{
    # PSData is module packaging and gallery metadata embedded in PrivateData
    # It's for rebuilding PowerShellGet (and PoshCode) NuGet-style packages
    # We had to do this because it's the only place we're allowed to extend the manifest
    # https://connect.microsoft.com/PowerShell/feedback/details/421837
    PSData = @{
        # The primary categorization of this module (from the TechNet Gallery tech tree).
        Category = "Scripting Techniques"

        # Keyword tags to help users find this module via navigations and search.
        Tags = @('PSEdition_Desktop','PSEdition_Core','Windows','Linux','MacOS','Cmdlet','Workflow','JobScheduler','JS7','Scheduling','Workload-Automation')

        # The web address of an icon which can be used in galleries to represent this module
        IconUri = "https://kb.sos-berlin.com/download/attachments/3638359/JS7_blue_orange_on_white.png?api=v2"

        # The web address of this module's project or support homepage.
        ProjectUri = "https://kb.sos-berlin.com/x/PpQwAw"

        # The web address of this module's license. Points to a page that's embeddable and linkable.
        LicenseUri = "https://www.gnu.org/licenses/gpl-3.0.en.html"

        # Release notes for this particular version of the module
        # ReleaseNotes = False

        # If true, the LicenseUrl points to an end-user license (not just a source license) which requires the user agreement before use.
        # RequireLicenseAcceptance = ""

        # Indicates this is a pre-release/testing version of the module.
        IsPrerelease = 'False'
    }
}

# HelpInfo URI of this module
HelpInfoURI = 'https://kb.sos-berlin.com/x/fpQwAw'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

# SIG # Begin signature block
# MIIslwYJKoZIhvcNAQcCoIIsiDCCLIQCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCbKfEytydM0wRm
# LIIMYllKQCAQkh0Cmj9Q9E7raWTbjKCCJawwggVvMIIEV6ADAgECAhBI/JO0YFWU
# jTanyYqJ1pQWMA0GCSqGSIb3DQEBDAUAMHsxCzAJBgNVBAYTAkdCMRswGQYDVQQI
# DBJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcMB1NhbGZvcmQxGjAYBgNVBAoM
# EUNvbW9kbyBDQSBMaW1pdGVkMSEwHwYDVQQDDBhBQUEgQ2VydGlmaWNhdGUgU2Vy
# dmljZXMwHhcNMjEwNTI1MDAwMDAwWhcNMjgxMjMxMjM1OTU5WjBWMQswCQYDVQQG
# EwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS0wKwYDVQQDEyRTZWN0aWdv
# IFB1YmxpYyBDb2RlIFNpZ25pbmcgUm9vdCBSNDYwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCN55QSIgQkdC7/FiMCkoq2rjaFrEfUI5ErPtx94jGgUW+s
# hJHjUoq14pbe0IdjJImK/+8Skzt9u7aKvb0Ffyeba2XTpQxpsbxJOZrxbW6q5KCD
# J9qaDStQ6Utbs7hkNqR+Sj2pcaths3OzPAsM79szV+W+NDfjlxtd/R8SPYIDdub7
# P2bSlDFp+m2zNKzBenjcklDyZMeqLQSrw2rq4C+np9xu1+j/2iGrQL+57g2extme
# me/G3h+pDHazJyCh1rr9gOcB0u/rgimVcI3/uxXP/tEPNqIuTzKQdEZrRzUTdwUz
# T2MuuC3hv2WnBGsY2HH6zAjybYmZELGt2z4s5KoYsMYHAXVn3m3pY2MeNn9pib6q
# RT5uWl+PoVvLnTCGMOgDs0DGDQ84zWeoU4j6uDBl+m/H5x2xg3RpPqzEaDux5mcz
# mrYI4IAFSEDu9oJkRqj1c7AGlfJsZZ+/VVscnFcax3hGfHCqlBuCF6yH6bbJDoEc
# QNYWFyn8XJwYK+pF9e+91WdPKF4F7pBMeufG9ND8+s0+MkYTIDaKBOq3qgdGnA2T
# OglmmVhcKaO5DKYwODzQRjY1fJy67sPV+Qp2+n4FG0DKkjXp1XrRtX8ArqmQqsV/
# AZwQsRb8zG4Y3G9i/qZQp7h7uJ0VP/4gDHXIIloTlRmQAOka1cKG8eOO7F/05QID
# AQABo4IBEjCCAQ4wHwYDVR0jBBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYD
# VR0OBBYEFDLrkpr/NZZILyhAQnAgNpFcF4XmMA4GA1UdDwEB/wQEAwIBhjAPBgNV
# HRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsGA1UdIAQUMBIwBgYE
# VR0gADAIBgZngQwBBAEwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC5jb21v
# ZG9jYS5jb20vQUFBQ2VydGlmaWNhdGVTZXJ2aWNlcy5jcmwwNAYIKwYBBQUHAQEE
# KDAmMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9jYS5jb20wDQYJKoZI
# hvcNAQEMBQADggEBABK/oe+LdJqYRLhpRrWrJAoMpIpnuDqBv0WKfVIHqI0fTiGF
# OaNrXi0ghr8QuK55O1PNtPvYRL4G2VxjZ9RAFodEhnIq1jIV9RKDwvnhXRFAZ/ZC
# J3LFI+ICOBpMIOLbAffNRk8monxmwFE2tokCVMf8WPtsAO7+mKYulaEMUykfb9gZ
# pk+e96wJ6l2CxouvgKe9gUhShDHaMuwV5KZMPWw5c9QLhTkg4IUaaOGnSDip0TYl
# d8GNGRbFiExmfS9jzpjoad+sPKhdnckcW67Y8y90z7h+9teDnRGWYpquRRPaf9xH
# +9/DUp/mBlXpnYzyOmJRvOwkDynUWICE5EV7WtgwggWNMIIEdaADAgECAhAOmxiO
# +dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAi
# BgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAw
# MDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERp
# Z2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCC
# AgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsb
# hA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iT
# cMKyunWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGb
# NOsFxl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclP
# XuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCr
# VYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFP
# ObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTv
# kpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWM
# cCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls
# 5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBR
# a2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6
# MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qY
# rhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8E
# BAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDig
# NoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCg
# v0NcVec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQT
# SnovLbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh
# 65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSw
# uKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAO
# QGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjD
# TZ9ztwGpn1eqXijiuZQwggYcMIIEBKADAgECAhAz1wiokUBTGeKlu9M5ua1uMA0G
# CSqGSIb3DQEBDAUAMFYxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExp
# bWl0ZWQxLTArBgNVBAMTJFNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBSb290
# IFI0NjAeFw0yMTAzMjIwMDAwMDBaFw0zNjAzMjEyMzU5NTlaMFcxCzAJBgNVBAYT
# AkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNlY3RpZ28g
# UHVibGljIENvZGUgU2lnbmluZyBDQSBFViBSMzYwggGiMA0GCSqGSIb3DQEBAQUA
# A4IBjwAwggGKAoIBgQC70f4et0JbePWQp64sg/GNIdMwhoV739PN2RZLrIXFuwHP
# 4owoEXIEdiyBxasSekBKxRDogRQ5G19PB/YwMDB/NSXlwHM9QAmU6Kj46zkLVdW2
# DIseJ/jePiLBv+9l7nPuZd0o3bsffZsyf7eZVReqskmoPBBqOsMhspmoQ9c7gqgZ
# YbU+alpduLyeE9AKnvVbj2k4aOqlH1vKI+4L7bzQHkNDbrBTjMJzKkQxbr6PuMYC
# 9ruCBBV5DFIg6JgncWHvL+T4AvszWbX0w1Xn3/YIIq620QlZ7AGfc4m3Q0/V8tm9
# VlkJ3bcX9sR0gLqHRqwG29sEDdVOuu6MCTQZlRvmcBMEJd+PuNeEM4xspgzraLqV
# T3xE6NRpjSV5wyHxNXf4T7YSVZXQVugYAtXueciGoWnxG06UE2oHYvDQa5mll1Ce
# HDOhHu5hiwVoHI717iaQg9b+cYWnmvINFD42tRKtd3V6zOdGNmqQU8vGlHHeBzoh
# +dYyZ+CcblSGoGSgg8sCAwEAAaOCAWMwggFfMB8GA1UdIwQYMBaAFDLrkpr/NZZI
# LyhAQnAgNpFcF4XmMB0GA1UdDgQWBBSBMpJBKyjNRsjEosYqORLsSKk/FDAOBgNV
# HQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADATBgNVHSUEDDAKBggrBgEF
# BQcDAzAaBgNVHSAEEzARMAYGBFUdIAAwBwYFZ4EMAQMwSwYDVR0fBEQwQjBAoD6g
# PIY6aHR0cDovL2NybC5zZWN0aWdvLmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25p
# bmdSb290UjQ2LmNybDB7BggrBgEFBQcBAQRvMG0wRgYIKwYBBQUHMAKGOmh0dHA6
# Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1B1YmxpY0NvZGVTaWduaW5nUm9vdFI0
# Ni5wN2MwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMA0GCSqG
# SIb3DQEBDAUAA4ICAQBfNqz7+fZyWhS38Asd3tj9lwHS/QHumS2G6Pa38Dn/1oFK
# WqdCSgotFZ3mlP3FaUqy10vxFhJM9r6QZmWLLXTUqwj3ahEDCHd8vmnhsNufJIkD
# 1t5cpOCy1rTP4zjVuW3MJ9bOZBHoEHJ20/ng6SyJ6UnTs5eWBgrh9grIQZqRXYHY
# NneYyoBBl6j4kT9jn6rNVFRLgOr1F2bTlHH9nv1HMePpGoYd074g0j+xUl+yk72M
# lQmYco+VAfSYQ6VK+xQmqp02v3Kw/Ny9hA3s7TSoXpUrOBZjBXXZ9jEuFWvilLIq
# 0nQ1tZiao/74Ky+2F0snbFrmuXZe2obdq2TWauqDGIgbMYL1iLOUJcAhLwhpAuNM
# u0wqETDrgXkG4UGVKtQg9guT5Hx2DJ0dJmtfhAH2KpnNr97H8OQYok6bLyoMZqaS
# dSa+2UA1E2+upjcaeuitHFFjBypWBmztfhj24+xkc6ZtCDaLrw+ZrnVrFyvCTWrD
# UUZBVumPwo3/E3Gb2u2e05+r5UWmEsUUWlJBl6MGAAjF5hzqJ4I8O9vmRsTvLQA1
# E802fZ3lqicIBczOwDYOSxlP0GOabb/FKVMxItt1UHeG0PL4au5rBhs+hSMrl8h+
# eplBDN1Yfw6owxI9OjWb4J0sjBeBVESoeh2YnZZ/WVimVGX/UUIL+Efrz/jlvzCC
# Bq4wggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcNAQELBQAwYjEL
# MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3
# LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0
# MB4XDTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkGA1UEBhMCVVMx
# FzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVz
# dGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCAiIwDQYJKoZI
# hvcNAQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8TykTepl1Gh1tKD
# 0Z5Mom2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsmc5Zt+FeoAn39
# Q7SE2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r07G1decf
# BmWNlCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2R/dhgxndX7RU
# CyFobjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0QKfAcsW6Th+x
# tVhNef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/oBpHIEPjQ2OA
# e3VuJyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1pslPJSlRErWHRA
# KKtzQ87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0z9JMq++b
# Pf4OuGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y99xh3pP+
# OcD5sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkUEBIDfV8ju2Tj
# Y+Cm4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1GnrXTdrnSDmuZ
# DNIztM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQW
# BBS6FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/
# 57qYrhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgwdwYI
# KwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5j
# b20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9j
# cmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAGA1Ud
# IAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEA
# fVmOwJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7cIoNqilp/GnB
# zx0H6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2pVs8Vc40BIiXO
# lWk/R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxkJodskr2dfNBw
# CnzvqLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpknG6skHibBt94q
# 6/aesXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2n82HhyS7T6NJ
# uXdmkfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HNT7ZAmyEh
# QNC3EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvtCl8zOYdBeHo4
# 6Zzh3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU5vIXmVnKcPA3
# v5gA3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8KvYHZE/6/pNHz
# V9m8BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/GqSFD/yYlvZV
# VCsfgPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggbAMIIEqKADAgECAhAM
# TWlyS5T6PCpKPSkHgD1aMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcw
# FQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3Rl
# ZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwHhcNMjIwOTIxMDAw
# MDAwWhcNMzMxMTIxMjM1OTU5WjBGMQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGln
# aUNlcnQxJDAiBgNVBAMTG0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIyIC0gMjCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAM/spSY6xqnya7uNwQ2a26HoFIV0
# MxomrNAcVR4eNm28klUMYfSdCXc9FZYIL2tkpP0GgxbXkZI4HDEClvtysZc6Va8z
# 7GGK6aYo25BjXL2JU+A6LYyHQq4mpOS7eHi5ehbhVsbAumRTuyoW51BIu4hpDIjG
# 8b7gL307scpTjUCDHufLckkoHkyAHoVW54Xt8mG8qjoHffarbuVm3eJc9S/tjdRN
# lYRo44DLannR0hCRRinrPibytIzNTLlmyLuqUDgN5YyUXRlav/V7QG5vFqianJVH
# hoV5PgxeZowaCiS+nKrSnLb3T254xCg/oxwPUAY3ugjZNaa1Htp4WB056PhMkRCW
# fk3h3cKtpX74LRsf7CtGGKMZ9jn39cFPcS6JAxGiS7uYv/pP5Hs27wZE5FX/Nurl
# fDHn88JSxOYWe1p+pSVz28BqmSEtY+VZ9U0vkB8nt9KrFOU4ZodRCGv7U0M50GT6
# Vs/g9ArmFG1keLuY/ZTDcyHzL8IuINeBrNPxB9ThvdldS24xlCmL5kGkZZTAWOXl
# LimQprdhZPrZIGwYUWC6poEPCSVT8b876asHDmoHOWIZydaFfxPZjXnPYsXs4Xu5
# zGcTB5rBeO3GiMiwbjJ5xwtZg43G7vUsfHuOy2SJ8bHEuOdTXl9V0n0ZKVkDTvpd
# 6kVzHIR+187i1Dp3AgMBAAGjggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0T
# AQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeB
# DAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+e
# yG8wHQYDVR0OBBYEFGKK3tBh/I8xFO2XC809KpQU31KcMFoGA1UdHwRTMFEwT6BN
# oEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJT
# QTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGA
# MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUH
# MAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRH
# NFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQAD
# ggIBAFWqKhrzRvN4Vzcw/HXjT9aFI/H8+ZU5myXm93KKmMN31GT8Ffs2wklRLHiI
# Y1UJRjkA/GnUypsp+6M/wMkAmxMdsJiJ3HjyzXyFzVOdr2LiYWajFCpFh0qYQitQ
# /Bu1nggwCfrkLdcJiXn5CeaIzn0buGqim8FTYAnoo7id160fHLjsmEHw9g6A++T/
# 350Qp+sAul9Kjxo6UrTqvwlJFTU2WZoPVNKyG39+XgmtdlSKdG3K0gVnK3br/5iy
# JpU4GYhEFOUKWaJr5yI+RCHSPxzAm+18SLLYkgyRTzxmlK9dAlPrnuKe5NMfhgFk
# nADC6Vp0dQ094XmIvxwBl8kZI4DXNlpflhaxYwzGRkA7zl011Fk+Q5oYrsPJy8P7
# mxNfarXH4PMFw1nfJ2Ir3kHJU7n/NBBn9iYymHv+XEKUgZSCnawKi8ZLFUrTmJBF
# YDOA4CPe+AOk9kVH5c64A0JH6EE2cXet/aLol3ROLtoeHYxayB6a1cLwxiKoT5u9
# 2ByaUcQvmvZfpyeXupYuhVfAYOd4Vn9q78KVmksRAsiCnMkaBXy6cbVOepls9Oie
# 1FqYyJ+/jbsYXEP10Cro4mLueATbvdH7WwqocH7wl4R44wgDXUcsY6glOJcB0j86
# 2uXl9uab3H4szP8XTE0AotjWAQ64i+7m4HJViSwnGWH2dwGMMIIHDjCCBXagAwIB
# AgIQSw+NgvCzdrKXturaTqbU7DANBgkqhkiG9w0BAQsFADBXMQswCQYDVQQGEwJH
# QjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdvIFB1
# YmxpYyBDb2RlIFNpZ25pbmcgQ0EgRVYgUjM2MB4XDTIzMDUzMDAwMDAwMFoXDTI2
# MDUyOTIzNTk1OVowgdQxEjAQBgNVBAUTCUhSQiAyMTAxNTETMBEGCysGAQQBgjc8
# AgEDEwJERTEdMBsGA1UEDxMUUHJpdmF0ZSBPcmdhbml6YXRpb24xCzAJBgNVBAYT
# AkRFMQ8wDQYDVQQIDAZCZXJsaW4xNTAzBgNVBAoMLFNPUyBTb2Z0d2FyZS0gdW5k
# IE9yZ2FuaXNhdGlvbnMtU2VydmljZSBHbWJIMTUwMwYDVQQDDCxTT1MgU29mdHdh
# cmUtIHVuZCBPcmdhbmlzYXRpb25zLVNlcnZpY2UgR21iSDCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBAL5t1usDS85Xcw3cIgVDvb43V9y9hiRn8cWnpnYr
# W8KcS58120n0rRCXPW8sFJvm4Uqf1xs1sXkmyBrdd0p/RBaKTkWtuScbsAPMUxDs
# SzPwhJYD/2jfv65ebB82qSURfO4ne8iF75WccYrgD2b6ZE3Px1ks/yH2zTw7VjSY
# ZgjpYhiUd215hTxwww35a32OS/f79sMi1ERC8qcVQYudwGm2brYgGuNC0qqL1Z3W
# 2EPKkH3VvUFUSQxdIQzEPMZrt9ZAepizAlyv/UZuxdmIr9DTL4OId6od5FfpCx8x
# HGiDHgULvlbQj7zBJ/GoUUcPNG5Ye1dn/Tl9xkcmJ9A0H4zGXRo6Zo+D9MZXavBn
# tj1ZvqwlCXiUkFGLDtay4TMgQKDJfs+qocFrsYeXCWiWqw0Ly1qYsa4rAPgCTSVJ
# 4j8l06/nWU0r57dvXRt9AuuikbJBSlg7gc462gK95FFkACeZEuhtSkrsnW8YFpPf
# TI7fomhyyg5bHiRKlyHq3Hgr7C88PjTmLAOQDhHQs/jgi3aMEDNHrTcFoHBlYmQb
# snU9zr0PMOUJXSRF1PsIe2vvvw9rpfvuLobUN21g1spNuEil+jrKgxYHKxcVqvlS
# Vn5SISqhQPYRGbLeZPIB2ZMl5w+z5Wwg6HqrdrD1MomSkPwWNxEjjSg3Ph2WizBt
# gEY3AgMBAAGjggHWMIIB0jAfBgNVHSMEGDAWgBSBMpJBKyjNRsjEosYqORLsSKk/
# FDAdBgNVHQ4EFgQURHB21fi7IRRpsoiNNppx0kxQ2YIwDgYDVR0PAQH/BAQDAgeA
# MAwGA1UdEwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwSQYDVR0gBEIwQDA1
# BgwrBgEEAbIxAQIBBgEwJTAjBggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0aWdvLmNv
# bS9DUFMwBwYFZ4EMAQMwSwYDVR0fBEQwQjBAoD6gPIY6aHR0cDovL2NybC5zZWN0
# aWdvLmNvbS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdDQUVWUjM2LmNybDB7Bggr
# BgEFBQcBAQRvMG0wRgYIKwYBBQUHMAKGOmh0dHA6Ly9jcnQuc2VjdGlnby5jb20v
# U2VjdGlnb1B1YmxpY0NvZGVTaWduaW5nQ0FFVlIzNi5jcnQwIwYIKwYBBQUHMAGG
# F2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMEgGA1UdEQRBMD+gHAYIKwYBBQUHCAOg
# EDAODAxERS1IUkIgMjEwMTWBH2FuZHJlYXMucHVlc2NoZWxAc29zLWJlcmxpbi5j
# b20wDQYJKoZIhvcNAQELBQADggGBAGQVsECtVc3Unom81ITXzXk3s9N6nMrsyxIX
# BTtFpa1Kq/oRZjhL3YuHZmA3kSpi8NjO0TvpI17KE/lEB8tm8qxLAOTCQ7l2CskA
# bcz5LIFKDbz+fm694GaeAp82KaxE45/V+esji36D8VKtywDABarTZADXxpIfQ5+9
# sLNy0dzpCwUcUrw0UArob6Nrom8F6nS9fcBoD8hLx/WIwZyhpKYGmKtEhpF7lsK7
# IxU2/t9N53NzfJ+vmSuMRKdZu1uoANx9PXkWolihmfR/J82HoYLM7okZGbhMzT3x
# 6DOn0tir+mCOIcgk8iMA1nxkucPiWBHYYn3LxP8afogSk11Hxk5m9ZHvdrqsHZU3
# 0lf7ERzm7zCjaExsdT/1GtUJlNytDrJQyK0JtiP3CxxuZrGh8bFONRTpDHkrff1a
# g/XGPZR+yLCWgqmO3JgoPLRAkPlIIJEka+4MDuRo36OzTrTkSKAYm4uGA9xacldG
# ojre4aXgSKndSSBFrQ9RqVAOwOqqgzGCBkEwggY9AgEBMGswVzELMAkGA1UEBhMC
# R0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEuMCwGA1UEAxMlU2VjdGlnbyBQ
# dWJsaWMgQ29kZSBTaWduaW5nIENBIEVWIFIzNgIQSw+NgvCzdrKXturaTqbU7DAN
# BglghkgBZQMEAgEFAKCBhDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqG
# SIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3
# AgEVMC8GCSqGSIb3DQEJBDEiBCCLKCdPUj6w9PPTrfa6e+k8gWv5e91/zceZhJTV
# ZynjlDANBgkqhkiG9w0BAQEFAASCAgABAzdmc7GX6qAo0S4roS+8+boOzTDZbZh0
# L07CW/YEVo4j0vZt5qG7Nu1cB/PiTuouITZTrBY3ugdhrkT04y8SK6FrDuWjc4VV
# Cp1i3SRQgI2l+vFTqKlmIB1ED66W1+uhdzZ2HxkH9bauDin2zxM+lpql4h9NGrM+
# B86jjMKne+ax5dYb3rBYsxLjfH0Lpgs3JATxhmWa8sj23Or9s1R2C4tWcIPsvtFf
# lPLlihyUosLbBRRjEZLYDb4fTlj7agvUl9hRYpeNUORnrDtuioM8GQbl1hnFx3sl
# coWte/VgAo4zj2j34E2cM41bPRooH69B/16vlIBwpUvtPQWHR5Jxex0KUGee/BVd
# rh1pbCNuj0ucitOMebg2x2k3SSo/bprCPhUoPT/ZPMAEuk4fkAVV28r1voqLpTYD
# aeJSBCtsDLKJoF0CCP0X49w6TrMOovjopV/tNcrkHjs1IYX3yJlalH4gSLSd9I07
# aETgFLg8Gc6cXDy1X+xo9AeJz7dVLRUFcSy5kZjCMlHtxfcXJ56nFg6Te5tuFsbB
# NImQo3dGGSUBgRrjKSjFftIyJtxlg97bEOBru+CkCSs3HcYKjqwhiAUjwRgBEue0
# Q9BlY574Vve5g3AAfy2RP2E2j1VyxvhZIOWwxi36Le087+98xouxYqjxt95dSHd9
# 6+W0/58tE6GCAyAwggMcBgkqhkiG9w0BCQYxggMNMIIDCQIBATB3MGMxCzAJBgNV
# BAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNl
# cnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAxN
# aXJLlPo8Kko9KQeAPVowDQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG9w0BCQMxCwYJ
# KoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMzA2MDYxNzM5MDhaMC8GCSqGSIb3
# DQEJBDEiBCC8Cktd/oRnYXAmldFzKrsL9CP0VhJVe3FzmNiCPEqIfzANBgkqhkiG
# 9w0BAQEFAASCAgBe/I+aEwcA5/RiPVOxGuYk+qzFGFHeTelyFlr74Rdvz6vcI8MA
# jUeUKbObIr7zTZvRyGfcIoMZY1uo5QdbCL1h4bkJiIabosAFSJyfAXTKNZoa+LLN
# PEMUVPi9wV7BWESdtz3pXYwVJOD7OjaVZQ993axHOTcn7woxekLFh/C5LRu8YzvC
# JHemVoyX1ZqO+BaBJZ7gN2dNgntX06z4U99jdEqQwpowM76SUBu1AKcBNPVmfJdp
# yeapcmRH99z862XyuyU+Yljtyb7mZi/gP8k26GAPcr2sKlhTNcM6iyT0clARVr2T
# a+DfmYOi2blWXJgPeiYk20JDid8mxmxeiaPe6qiN6ywIDOfSLz8fK93Agy0Q6dm0
# MBJVI/fjmEa/U9rYkc+BGriRnyG10LTC1CEN9Q147H0iHdRtgiuIpAWwKR85uGsy
# qg8HNDX/bTLTebwiCyTiTIxDiEKAo/2G5AHgFbaG5TDivQRBfy+xIegNYfo3cLSm
# phXe8xk/uqNKOuid0SYqKoQqd021LkOwG6Gmaa/Xr/aDL0CXTM5I7ezEJp/PSKyl
# DV0Ik7p9ZMT4aI1AnlZMkHqY9efEvNP9tNC4N4lA0wbFE1qClQTLOjsCkXv3o9VK
# UgmSlxWmkIhNZpyeHp5DObglsXc3rC5XbwnkyP/h+uifrZ6qLcOhgms5fg==
# SIG # End signature block
