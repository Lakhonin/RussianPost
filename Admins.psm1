<#
.Synopsis
   Логинирование
.DESCRIPTION
   Логинирование действий скрипта
.NOTES      
   Name: Admins   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/Admins.psm1
.EXAMPLE
   # Логинирование действий скрипта 
   Log "Пароль был изменен"
   [26.10.20][19:12:19][Информация] Пароль был изменен
#>
Function Log {
param(
[PARAMETER(Mandatory=$true, 
           Position=0)][string]$text,
                       [switch]$OnlyLogText,
                       [switch]$ErrorLogText
)
$InLogTunePath = "$PSScriptRoot\Logs"
$InLogTuneName = "$Env:COMPUTERNAME"+"_"+"$ProgramName.log"
[int]$ErrorCreateFileLog = 0
$СurrentData   = Get-Date -Format "dd.MM.yy][HH:mm:ss"
$InfoLogLable  = "[$СurrentData][Информация]"
$ErrorLogLable = "[$СurrentData][!!Ошибка!!]" 
Function SubLog{
param([switch]$SubonlyLT,
              $InfOrEr,
              $Collor              
                    )
$AddCont = Add-Content -Path "$InLogTunePath\$InLogTuneName" -Force -Value "$InfOrEr $text" -ErrorAction SilentlyContinue
if(!($SubonlyLT)){
    $AddCont
    Write-Host -ForegroundColor $Collor -Object $InfOrEr -NoNewline; Write-Host -ForegroundColor Gray -Object " $text"
    }
else{
    $AddCont
                }
}
if(!(Test-Path -Path "$InLogTunePath\$InLogTuneName")){
       try{
            New-Item -ItemType File -Path $InLogTunePath -Name $InLogTuneName -Force -ErrorAction Stop |Out-Null 
            }
       catch{
             $ErrorCreateFileLog = 1; Write-Host -ForegroundColor Red -Object "Ошибка логирования. Логирование невозможно"}
    }
if($ErrorCreateFileLog -eq 0){
    if(!($ErrorLogText)){
        if(!($OnlyLogText)){ 
                            SubLog -InfOrEr $InfoLogLable -Collor "Yellow" 
                                }
         else{ SubLog -InfOrEr $InfoLogLable -SubonlyLT -Collor "Yellow"}
            }
    else{
        if(!($OnlyLogText)){
            SubLog -InfOrEr $ErrorLogLable -Collor "Red"    
            }
            else{SubLog -InfOrEr $ErrorLogLable -Collor "Red" -SubonlyLT
                 }
        }
    }
}
