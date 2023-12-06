# Specify your domain name
$domainName = "djamel.com"

# Read the student list from the CSV file
$studentList = Import-Csv -Path 'C:\Code\StudentList.csv'

# Array of group names
$groupNames = "IT", "HR", "DevOps", "Marketing", "Sales", "Finance", "Management"

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
}

# Iterate through the group names and create groups if they don't exist
foreach ($groupName in $groupNames) {
    if (-not (Get-ADGroup -Filter { Name -eq $groupName })) {
        New-ADGroup -Name $groupName -Description "$groupName Group" -GroupScope Global
        Write-Output "Group created: $groupName"
    } else {
        Write-Output "Group $groupName already exists in Active Directory."
    }
}

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
            AccountPassword       = $password
        }

        try {
            New-ADUser @newUserParams
            Write-Output "User created: $userPrincipalName with a randomly generated password. User will be prompted to change the password at next logon."

            # Add the user to a random group
            $randomGroupName = Get-Random -InputObject $groupNames
            Add-ADGroupMember -Identity $randomGroupName -Members $samAccountName
            Write-Output "User $fullUsername added to group $randomGroupName"
        } catch {
            Write-Output "Error creating user: $_"
        }
    } else {
        Write-Output "User $fullUsername already exists in Active Directory."
    }
}
