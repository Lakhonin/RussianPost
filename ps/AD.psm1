Function Extend-Password{
<#
.Synopsis
   Продленение действие пароля пользователя
.DESCRIPTION
   Выполняет продление действия пароля учетной записи пользователя
.NOTES      
   Name: AD   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/RussianPost/blob/master/ps/AD.psm1
.EXAMPLE
    Extend-Password -User i.ivanov
#>
param(
[Parameter(Mandatory =$true, Position = 0)][string[]]$User
)
$u = Get-ADUser $User -Property *
$u.pwdLastSet = 0
Set-ADUser -Instance $u
$u.pwdLastSet = -1
Set-ADUser -Instance $u
}
Function Remove-Empty-OrganizationalUnit{
<#
.Synopsis
   Удаляет пустые OU в указанном OrganizationalUnit
.DESCRIPTION
   Выполняет проверку и удаление OU если та пустая
.NOTES      
   Name: AD   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/RussianPost/blob/master/ps/AD.psm1
.EXAMPLE
    Remove-Empty-OrganizationalUnit -OU "OU=HOME,DC=home,DC=local"
#>
param(
[Parameter(Mandatory =$true, Position = 0)][string[]]$OU
)
Get-ADOrganizationalUnit -Filter * -SearchBase $OU| Where-Object {-not ( Get-ADObject -Filter * -SearchBase $_.Distinguishedname -SearchScope OneLevel -ResultSetSize 1 )}|
Foreach {
Set-ADObject -Identity:"$_" -ProtectedFromAccidentalDeletion:$false
Remove-ADOrganizationalUnit -Identity $_ -Force
Log "Удаляем $_ "}
}