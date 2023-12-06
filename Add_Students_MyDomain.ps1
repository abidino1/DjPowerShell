# Import the Active Directory module
Import-Module ActiveDirectory

# Function to generate a random password
function Get-RandomPassword {
    param (
        [int]$Length = 12
    )

    $ValidCharacters = 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+'
    $Password = -join (Get-Random -InputObject $ValidCharacters -Count $Length)
    return $Password
    
# Iterate through the student list
foreach ($student in $studentList) {

    $GivenName = $student.'FirstName'
    $Surname = $student.'LastName'

    # Construct the user's full Active Directory username
    $fullUsername = "$GivenName$Surname@$domainName"

    # Check if the user already exists
    $existingUser = Get-ADUser -Filter { SamAccountName -eq $fullUsername }

    if ($existingUser -eq $null) {
        # User does not exist, create a new user account

        # Generate a random and secure password
        $password = Get-RandomPassword -Length 12 | ConvertTo-SecureString -AsPlainText -Force

        # Construct the SamAccountName
        $samAccountName = "$GivenName$Surname"

        # Construct the UserPrincipalName
        $userPrincipalName = "$samAccountName@$domainName"

        $newUserParams = @{
            SamAccountName        = $samAccountName
            UserPrincipalName     = $userPrincipalName
            GivenName             = $GivenName
            Surname               = $Surname
            Enabled               = $true
            Name                  = "$GivenName $Surname"
            ChangePasswordAtLogon = $true
            # Use -AccountPassword to set the password
            AccountPassword       = $password
        }

        New-ADUser @newUserParams
        Write-Output "User created: $userPrincipalName with a randomly generated password. User will be prompted to change the password at next logon."
    } else {
        Write-Output "User already exists: $fullUsername"
    }
}
