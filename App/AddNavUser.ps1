# ============================================================
#  Business Central – Add a New User with NavUserPassword Auth
# ============================================================
# Run this script from the Business Central Administration Shell
# (or any PowerShell session where the BC Admin cmdlets are loaded).
# ============================================================

# --------------- Configuration ---------------
$ServerInstance     = "BC"                        # Your BC server instance name
$NewUserName        = "newuser"                   # Login / user name
$NewUserFullName    = "New User"                  # Display name
$NewUserEmail       = "newuser@contoso.com"       # Authentication e-mail (used as login for NavUserPassword)
$PlainTextPassword  = "P@ssw0rd123!"              # Initial password (change immediately after first login)
$PermissionSetId    = "SUPER"                     # Permission set to assign (e.g. SUPER, D365 BUS FULL ACCESS)
# ----------------------------------------------

# Convert plain-text password to a SecureString
$SecurePassword = ConvertTo-SecureString $PlainTextPassword -AsPlainText -Force

# 1. Create the new user with NavUserPassword authentication
New-NAVServerUser `
    -ServerInstance  $ServerInstance `
    -UserName        $NewUserName `
    -FullName        $NewUserFullName `
    -AuthenticationEmail $NewUserEmail `
    -Password        $SecurePassword `
    -LicenseType     Full           # Options: Full | Limited | DeviceOnly | WindowsGroup | ExternalUser

Write-Host "User '$NewUserName' created successfully." -ForegroundColor Green

# 2. Assign a Permission Set to the new user
New-NAVServerUserPermissionSet `
    -ServerInstance  $ServerInstance `
    -UserName        $NewUserName `
    -PermissionSetId $PermissionSetId

Write-Host "Permission set '$PermissionSetId' assigned to '$NewUserName'." -ForegroundColor Green

# 3. (Optional) Verify the user was created
Get-NAVServerUser -ServerInstance $ServerInstance | Where-Object { $_.UserName -eq $NewUserName } | Format-List
