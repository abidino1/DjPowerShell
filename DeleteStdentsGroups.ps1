# Import the Active Directory module
Import-Module ActiveDirectory

# Array of group names
$groupNames = "IT", "HR", "DevOps", "Marketing", "Sales", "Finance", "Management"

# Iterate through the group names and delete groups
foreach ($groupName in $groupNames) {
    $existingGroup = Get-ADGroup -Filter { Name -eq $groupName }

    if ($existingGroup -ne $null) {
        Remove-ADGroup -Identity $groupName -Confirm:$false
        Write-Output "Group deleted: $groupName"
    } else {
        Write-Output "Group $groupName does not exist in Active Directory."
    }
}

# Read the student list from the CSV file
$studentList = Import-Csv -Path 'C:\Code\StudentList.csv'

# Iterate through the student list and delete users
foreach ($student in $studentList) {
    $GivenName = $student.'FirstName'
    $Surname = $student.'LastName'

    # Construct the user's full Active Directory username
    $fullUsername = "$GivenName$Surname"

    $existingUser = Get-ADUser -Filter { SamAccountName -eq $fullUsername }

    if ($existingUser -ne $null) {
        Remove-ADUser -Identity $fullUsername -Confirm:$false
        Write-Output "User deleted: $fullUsername"
    } else {
        Write-Output "User $fullUsername does not exist in Active Directory."
    }
}
value = 1

if value == 1:
    print("value is 1")
elif value == 2:
    print("value is 2")
elif value == 3:
    print("value is 3")
else:
    print("value is not 1, 2, or 3")

if value + 1 != 4:
    print("value + 1 is not 4")
