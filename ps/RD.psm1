Function Send-RDMessage{
<#
.Synopsis
   Отправка сообщения пользователям терминальной фермы
.DESCRIPTION
   Отправляет сообщение конкретному пользователю, пользователям терминала или всей терминальной фермы (ферм)  
.NOTES      
   Name: RD   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/Admins/blob/master/RD.psm1
.EXAMPLE

#>
param(
[Parameter(Mandatory=$true)][String]$ConnectionBroker,
[Parameter(Mandatory=$true)][String]$MessageBody,
[Parameter(Mandatory=$false)][String]$MessageTitle,
[Parameter(Mandatory=$false)][String]$CollectionName,
[Parameter(Mandatory=$false)][String]$User,
[Parameter(Mandatory=$false)][String]$Server
)
If (( -not $CollectionName) -and (-not $User) -and (-not $Server)){
$UserIds = Get-RDUserSession -ConnectionBroker $((Get-RDConnectionBrokerHighAvailability -ConnectionBroker $ConnectionBroker).ActiveManagementServer)}
elseif(( -not $CollectionName) -and ($User) -and (-not $Server)){
$UserIds = Get-RDUserSession -ConnectionBroker $((Get-RDConnectionBrokerHighAvailability -ConnectionBroker $ConnectionBroker).ActiveManagementServer) | where {$_.username -eq "$User"}}
elseif(($CollectionName) -and (-not $User) -and (-not $Server)){
$UserIds = Get-RDUserSession -ConnectionBroker $((Get-RDConnectionBrokerHighAvailability -ConnectionBroker $ConnectionBroker).ActiveManagementServer) -CollectionName $Collection}
else{
$UserIds = Get-RDUserSession -ConnectionBroker $((Get-RDConnectionBrokerHighAvailability -ConnectionBroker $ConnectionBroker).ActiveManagementServer)| where {$_.hostserver -eq "$Server"}}
foreach ($UserId in $UserIds) {
Send-RDUserMessage -HostServer $(($UserId).HostServer) -UnifiedSessionID $(($UserId).UnifiedSessionID) -MessageTitle $MessageTitle -MessageBody $MessageBody }
return $UserId.Count}