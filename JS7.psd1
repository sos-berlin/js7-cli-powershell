@{

# Script module or binary module file associated with this manifest.
RootModule = 'JS7.psm1'

# Version number of this module.
ModuleVersion = '2.0.21.0'

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
    'Confirm-JS7InventoryFolder',
    'Confirm-JS7Order',
    'Connect-JS7',
    'Disable-JS7Agent',
    'Disable-JS7IAMAccount',
    'Disable-JS7Subagent',
    'Disconnect-JS7',
    'Enable-JS7Agent',
    'Enable-JS7IAMAccount',
    'Enable-JS7Subagent',
    'Export-JS7Agent',
    'Export-JS7InventoryFolder',
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
    'Get-JS7InventoryFolder',
    'Get-JS7InventoryItem',
    'Get-JS7InventoryStatistics',
    'Get-JS7ReleasableItem',
    'Get-JS7JOCInstance',
    'Get-JS7JOCLicense',
    'Get-JS7JOCLog',
    'Get-JS7JOCLogFilename',
    'Get-JS7JOCProperties',
    'Get-JS7JOCSettings',
    'Get-JS7JOCVersion',
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
    'Get-JS7Version',
    'Get-JS7Workflow',
    'Hide-JS7Agent',
    'Invoke-JS7ApiRequest',
    'Invoke-JS7Encrypt',
    'Invoke-JS7Decrypt',
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
    'Revoke-JS7DeployableItem',
    'Revoke-JS7ReleasableItem',
    'Revoke-JS7SubagentCluster',
    'Send-JS7Mail',
    'Set-JS7Agent',
    'Set-JS7ClusterAgent',
    'Set-JS7Controller',
    'Set-JS7Credentials',
    'Set-JS7DailyPlanOrder',
    'Set-JS7Option',
    'Set-JS7Order',
    'Show-JS7Agent',
    'Set-JS7FileTransferItem',
    'Set-JS7IAMAccount',
    'Set-JS7IAMFolder',
    'Set-JS7IAMPermission',
    'Set-JS7IAMRole',
    'Set-JS7IAMService',
    'Set-JS7InventoryItem',
    'Set-JS7JobResource',
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
# MIIsmQYJKoZIhvcNAQcCoIIsijCCLIYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCMWvl6eTppFhJH
# gMQ8ycm98KrjNBkVIVmhXCdQ32bfQqCCJa4wggVvMIIEV6ADAgECAhBI/JO0YFWU
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
# VCsfgPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggbCMIIEqqADAgECAhAF
# RK/zlJ0IOaa/2z9f5WEWMA0GCSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcw
# FQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3Rl
# ZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwHhcNMjMwNzE0MDAw
# MDAwWhcNMzQxMDEzMjM1OTU5WjBIMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGln
# aUNlcnQsIEluYy4xIDAeBgNVBAMTF0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIzMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAo1NFhx2DjlusPlSzI+DPn9fl
# 0uddoQ4J3C9Io5d6OyqcZ9xiFVjBqZMRp82qsmrdECmKHmJjadNYnDVxvzqX65RQ
# jxwg6seaOy+WZuNp52n+W8PWKyAcwZeUtKVQgfLPywemMGjKg0La/H8JJJSkghra
# arrYO8pd3hkYhftF6g1hbJ3+cV7EBpo88MUueQ8bZlLjyNY+X9pD04T10Mf2SC1e
# RXWWdf7dEKEbg8G45lKVtUfXeCk5a+B4WZfjRCtK1ZXO7wgX6oJkTf8j48qG7rSk
# IWRw69XloNpjsy7pBe6q9iT1HbybHLK3X9/w7nZ9MZllR1WdSiQvrCuXvp/k/Xtz
# PjLuUjT71Lvr1KAsNJvj3m5kGQc3AZEPHLVRzapMZoOIaGK7vEEbeBlt5NkP4FhB
# +9ixLOFRr7StFQYU6mIIE9NpHnxkTZ0P387RXoyqq1AVybPKvNfEO2hEo6U7Qv1z
# fe7dCv95NBB+plwKWEwAPoVpdceDZNZ1zY8SdlalJPrXxGshuugfNJgvOuprAbD3
# +yqG7HtSOKmYCaFxsmxxrz64b5bV4RAT/mFHCoz+8LbH1cfebCTwv0KCyqBxPZyS
# kwS0aXAnDU+3tTbRyV8IpHCj7ArxES5k4MsiK8rxKBMhSVF+BmbTO77665E42FEH
# ypS34lCh8zrTioPLQHsCAwEAAaOCAYswggGHMA4GA1UdDwEB/wQEAwIHgDAMBgNV
# HRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcwCAYG
# Z4EMAQQCMAsGCWCGSAGG/WwHATAfBgNVHSMEGDAWgBS6FtltTYUvcyl2mi91jGog
# j57IbzAdBgNVHQ4EFgQUpbbvE+fvzdBkodVWqWUxo97V40kwWgYDVR0fBFMwUTBP
# oE2gS4ZJaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0
# UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNybDCBkAYIKwYBBQUHAQEEgYMw
# gYAwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggrBgEF
# BQcwAoZMaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3Rl
# ZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsF
# AAOCAgEAgRrW3qCptZgXvHCNT4o8aJzYJf/LLOTN6l0ikuyMIgKpuM+AqNnn48Xt
# JoKKcS8Y3U623mzX4WCcK+3tPUiOuGu6fF29wmE3aEl3o+uQqhLXJ4Xzjh6S2sJA
# OJ9dyKAuJXglnSoFeoQpmLZXeY/bJlYrsPOnvTcM2Jh2T1a5UsK2nTipgedtQVyM
# adG5K8TGe8+c+njikxp2oml101DkRBK+IA2eqUTQ+OVJdwhaIcW0z5iVGlS6ubzB
# aRm6zxbygzc0brBBJt3eWpdPM43UjXd9dUWhpVgmagNF3tlQtVCMr1a9TMXhRsUo
# 063nQwBw3syYnhmJA+rUkTfvTVLzyWAhxFZH7doRS4wyw4jmWOK22z75X7BC1o/j
# F5HRqsBV44a/rCcsQdCaM0qoNtS5cpZ+l3k4SF/Kwtw9Mt911jZnWon49qfH5U81
# PAC9vpwqbHkB3NpE5jreODsHXjlY9HxzMVWggBHLFAx+rrz+pOt5Zapo1iLKO+ua
# gjVXKBbLafIymrLS2Dq4sUaGa7oX/cR3bBVsrquvczroSUa31X/MtjjA2Owc9bah
# uEMs305MfR5ocMB3CtQC4Fxguyj/OOVSWtasFyIjTvTs0xf7UGv/B3cfcZdEQcm4
# RtNsMnxYL2dHZeUbc7aZ+WssBkbvQR7w8F/g29mtkIBEr4AQQYowggcOMIIFdqAD
# AgECAhBLD42C8LN2spe26tpOptTsMA0GCSqGSIb3DQEBCwUAMFcxCzAJBgNVBAYT
# AkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxLjAsBgNVBAMTJVNlY3RpZ28g
# UHVibGljIENvZGUgU2lnbmluZyBDQSBFViBSMzYwHhcNMjMwNTMwMDAwMDAwWhcN
# MjYwNTI5MjM1OTU5WjCB1DESMBAGA1UEBRMJSFJCIDIxMDE1MRMwEQYLKwYBBAGC
# NzwCAQMTAkRFMR0wGwYDVQQPExRQcml2YXRlIE9yZ2FuaXphdGlvbjELMAkGA1UE
# BhMCREUxDzANBgNVBAgMBkJlcmxpbjE1MDMGA1UECgwsU09TIFNvZnR3YXJlLSB1
# bmQgT3JnYW5pc2F0aW9ucy1TZXJ2aWNlIEdtYkgxNTAzBgNVBAMMLFNPUyBTb2Z0
# d2FyZS0gdW5kIE9yZ2FuaXNhdGlvbnMtU2VydmljZSBHbWJIMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAvm3W6wNLzldzDdwiBUO9vjdX3L2GJGfxxaem
# ditbwpxLnzXbSfStEJc9bywUm+bhSp/XGzWxeSbIGt13Sn9EFopORa25JxuwA8xT
# EOxLM/CElgP/aN+/rl5sHzapJRF87id7yIXvlZxxiuAPZvpkTc/HWSz/IfbNPDtW
# NJhmCOliGJR3bXmFPHDDDflrfY5L9/v2wyLURELypxVBi53AabZutiAa40LSqovV
# ndbYQ8qQfdW9QVRJDF0hDMQ8xmu31kB6mLMCXK/9Rm7F2Yiv0NMvg4h3qh3kV+kL
# HzEcaIMeBQu+VtCPvMEn8ahRRw80blh7V2f9OX3GRyYn0DQfjMZdGjpmj4P0xldq
# 8Ge2PVm+rCUJeJSQUYsO1rLhMyBAoMl+z6qhwWuxh5cJaJarDQvLWpixrisA+AJN
# JUniPyXTr+dZTSvnt29dG30C66KRskFKWDuBzjraAr3kUWQAJ5kS6G1KSuydbxgW
# k99Mjt+iaHLKDlseJEqXIerceCvsLzw+NOYsA5AOEdCz+OCLdowQM0etNwWgcGVi
# ZBuydT3OvQ8w5QldJEXU+wh7a++/D2ul++4uhtQ3bWDWyk24SKX6OsqDFgcrFxWq
# +VJWflIhKqFA9hEZst5k8gHZkyXnD7PlbCDoeqt2sPUyiZKQ/BY3ESONKDc+HZaL
# MG2ARjcCAwEAAaOCAdYwggHSMB8GA1UdIwQYMBaAFIEykkErKM1GyMSixio5EuxI
# qT8UMB0GA1UdDgQWBBREcHbV+LshFGmyiI02mnHSTFDZgjAOBgNVHQ8BAf8EBAMC
# B4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzBJBgNVHSAEQjBA
# MDUGDCsGAQQBsjEBAgEGATAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28u
# Y29tL0NQUzAHBgVngQwBAzBLBgNVHR8ERDBCMECgPqA8hjpodHRwOi8vY3JsLnNl
# Y3RpZ28uY29tL1NlY3RpZ29QdWJsaWNDb2RlU2lnbmluZ0NBRVZSMzYuY3JsMHsG
# CCsGAQUFBwEBBG8wbTBGBggrBgEFBQcwAoY6aHR0cDovL2NydC5zZWN0aWdvLmNv
# bS9TZWN0aWdvUHVibGljQ29kZVNpZ25pbmdDQUVWUjM2LmNydDAjBggrBgEFBQcw
# AYYXaHR0cDovL29jc3Auc2VjdGlnby5jb20wSAYDVR0RBEEwP6AcBggrBgEFBQcI
# A6AQMA4MDERFLUhSQiAyMTAxNYEfYW5kcmVhcy5wdWVzY2hlbEBzb3MtYmVybGlu
# LmNvbTANBgkqhkiG9w0BAQsFAAOCAYEAZBWwQK1VzdSeibzUhNfNeTez03qcyuzL
# EhcFO0WlrUqr+hFmOEvdi4dmYDeRKmLw2M7RO+kjXsoT+UQHy2byrEsA5MJDuXYK
# yQBtzPksgUoNvP5+br3gZp4CnzYprETjn9X56yOLfoPxUq3LAMAFqtNkANfGkh9D
# n72ws3LR3OkLBRxSvDRQCuhvo2uibwXqdL19wGgPyEvH9YjBnKGkpgaYq0SGkXuW
# wrsjFTb+303nc3N8n6+ZK4xEp1m7W6gA3H09eRaiWKGZ9H8nzYehgszuiRkZuEzN
# PfHoM6fS2Kv6YI4hyCTyIwDWfGS5w+JYEdhifcvE/xp+iBKTXUfGTmb1ke92uqwd
# lTfSV/sRHObvMKNoTGx1P/Ua1QmU3K0OslDIrQm2I/cLHG5msaHxsU41FOkMeSt9
# /VqD9cY9lH7IsJaCqY7cmCg8tECQ+UggkSRr7gwO5Gjfo7NOtORIoBibi4YD3Fpy
# V0aiOt7hpeBIqd1JIEWtD1GpUA7A6qqDMYIGQTCCBj0CAQEwazBXMQswCQYDVQQG
# EwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS4wLAYDVQQDEyVTZWN0aWdv
# IFB1YmxpYyBDb2RlIFNpZ25pbmcgQ0EgRVYgUjM2AhBLD42C8LN2spe26tpOptTs
# MA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJ
# KoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQB
# gjcCARUwLwYJKoZIhvcNAQkEMSIEIPek3jNGHmRiyxgDi/dPjGrVb0BJHOoQ+HY/
# 3I4AxPxxMA0GCSqGSIb3DQEBAQUABIICAK5yQZP08xULPcVUNjvaUaQSSBL16QAA
# wIJapyav+7BQgmAaRxB4/XertYiQ/dZhQDrkDYlv4ppokVm1msLOP66NQyIVKxFu
# D0sPApkSY6mzl70W8jWNEwQaD45MyKF8ce8yd5xFM/OsO2Zp2eqeHzS3Ml+YOx03
# VfF7X3+OVoyJS1tanjD1LbTj2uhikhJjIeBvKxSBHbHDXmoql5aShq93MwEAtmMv
# pn5y/jWwoxPadGE5UTS1BJSTmBOUdB0W+jUWv5hYv4XWTi4qnpyAB+ILdHCLThX7
# x3syjzRoRKkbwSf4+RjpZelA+O0M05xtFZE6Eb7tbo8ui5vHMfg3XBiNUxOsepkK
# 9/2g/HvnKuLJAhGX9NnsLNz0XJ4UvffmwKmPfkjCehuL/6OzyOjSdwrMnlM7F9jY
# VQvVIv2q0x4KCoA7mSPqFTO7X3SZNmpYQ8K1fLIaPocwOIU/mqcvuAB/sEYC/aw8
# SIX/4TyQjJsBDI+NpEf66Qp/VyKQKSyE87dUQk5X27zsJoWBGIBcdbBxyv3o2kos
# cK7E3irBATIZzedm4QY4fVOXmcmehS+vTr9FSjXrCCOBO26fB0RsWdsmZoMtJkx6
# ka9HAafKExVYtPG+OMYoo18uLCyJUn8CHiS2vcolmysKcRM4x33A/CwM95bXxo5s
# s738dp60hlHqoYIDIDCCAxwGCSqGSIb3DQEJBjGCAw0wggMJAgEBMHcwYzELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdp
# Q2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQ
# BUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzEL
# BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTI0MDczMDA5Mjk1M1owLwYJKoZI
# hvcNAQkEMSIEIFMJtw+jOWK8RYMV/fv6wFP8JkQrKTxBZfFkijXWPjFgMA0GCSqG
# SIb3DQEBAQUABIICAF9okYDSRiKTMyaqfW3CLHohEZgROTSYWwStmAdRrbtJTRh3
# nF7Uenisrhy/o9VsPueoZh0oEQj1PqCZDHFOsgxrLaoPBghI4mnnMp2DkpS8fnEk
# D2xYjLFfNV0PNk04OdWJfgZACLKIBerEzhRsxn/qyY3UEyuTAQ0vJJ4hCGkReZqD
# O6ci5OMqOXBa8Q3icselRI6xCWrZtJzRcMPWMOYhhoLWlYZFL/0Id8W0FBzm3OOk
# ry/oap+Eyr1uVVTi0OwOAyH12kjURPT8fjHOf2Yez8MytoVP3ltmq3/SotPqtOtH
# adgMJtLVMKkzZMyIMnAmXVoVwBUztMOf2Xj8CUn+r36XrD1/fu3SUfxzcjYpMr67
# 4G1IYwGHTyCjDBzNTqkRPNCq3mJkn4vljYv8bxMoJco4Waje2GYgEIBCAJtG//vv
# Ubztl4eiAU5NY4GUAykZ2wehGyi/wLfCeAIJM2xfcIj1zbzCwjpiHAzQBaHC1bt3
# JBw5p2d7puAq3l1hVBWWtDA0qAwB2Bo9dyNcIVq6p53W+wQHJWdTSVngRTRmuBzk
# a70KQtlcklSyeD5uNyxWuT8V/CF0Pt4E7L8fviVq4Kt7JYKA/3j0qXYrZqJFZZ76
# cjzdMuVRoQfeRNJ7rv2+7DK1LpTzTi1sCFv7Ehr/w1l73QpRibBx8fSxXEgC
# SIG # End signature block
