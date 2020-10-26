Function Log {
<#
.Synopsis
   Логинирование
.DESCRIPTION
   Логинирование действий скрипта
.NOTES      
   Name: Admins   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/Admins/blob/master/Admins.psm1
.EXAMPLE
   # Логинирование действий скрипта 
   Log "Пароль был изменен"
   [26.10.20][19:12:19][Информация] Пароль был изменен
#>
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
Function Get-CPUInfo{
<#
.Synopsis
   Вывод информации о процессоре
.DESCRIPTION
   Показывает инофрмацию о центральном процессоре компьютера  
.NOTES      
   Name: Admins   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/Admins/blob/master/Admins.psm1
.EXAMPLE
   Get-CPUInfo -ComputerName localhost
   [26.10.20][19:43:02][Информация] Имя процессора Intel(R) Core(TM) i5-7600K CPU @ 3.80GHz
   [26.10.20][19:43:02][!!Ошибка!!] Не поддерживается
#>
param
([Parameter(Mandatory=$true)][String]$ComputerName)
try{
$CPUName = (Get-WmiObject -ComputerName $ComputerName -Class Win32_Processor -EA 1).name
Log "Имя процессора $CPUName"
$CPUt = (Get-WmiObject -ComputerName $ComputerName -Class MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" -EA 1 | Where-Object -Property instancename -EQ "ACPI\ThermalZone\TZ01_0").CurrentTemperature
foreach($currentT in $CPUt){
$CurrentTempCelsius = ($currentT/10)-273.15
Log "Температура процессора $($CurrentTempCelsius.ToString())C"}
}
catch{Log "$($Error[0].ToString())" -ErrorLogText} 
}
Function Get-DiskInfo{
<#
.Synopsis
   Вывод информации о жестких дисках
.DESCRIPTION
   Показывает инофрмацию о накопителях удаленного компьютера  
.NOTES      
   Name: Admins   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/Admins/blob/master/Admins.psm1
.EXAMPLE
   Get-DiskInfo -ComputerName localhost
   [26.10.20][19:45:46][Информация] ---------------------------
   [26.10.20][19:45:46][Информация] Список логических дисков пк:
   [26.10.20][19:45:46][Информация] C: Полный размер 232.27гб Свободно 20.46гб
   [26.10.20][19:45:46][Информация] D: Полный размер 465.75гб Свободно 111.69гб
   [26.10.20][19:45:46][Информация] ---------------------------
   [26.10.20][19:45:46][Информация] Список физических дисков пк:
   [26.10.20][19:45:46][Информация] Диск - Samsung SSD 970 EVO Plus 500GB, Размер - 465.76Гб 
   [26.10.20][19:45:46][Информация] Диск - Samsung SSD 960 EVO 250GB, Размер - 232.88Гб 
   [26.10.20][19:45:46][Информация] ---------------------------
#>
param
([Parameter(Mandatory=$true)][String]$ComputerName)
try{
$LogDops = Get-WmiObject -ComputerName $ComputerName -Class Win32_LogicalDisk -EA 1
Log "---------------------------"
Log "Список логических дисков пк:"
$script:LogNameArrayFree = @()
$script:LogNameArrayALL = @()
Foreach ($dsc1 in $LogDops){
                            $LogName    = $dsc1.Name 
                            $Sizename   = [math]::Round(($dsc1.Size)/1gb,2)
                            $FreeSpacen = [math]::Round(($dsc1.FreeSpace)/1gb,2)
                            Log "$LogName Полный размер $($Sizename)гб Свободно $($FreeSpacen)гб"
                            if($Sizename -gt 5){
                            $script:LogNameArrayFree+=$LogName}
                            $script:LogNameArrayALL+=$LogName
}
$script:fexecuted = 1
Log "---------------------------"
Log "Список физических дисков пк:"
$LogDops2 = Get-WmiObject -ComputerName $ComputerName -Class Win32_DiskDrive -EA 1
Foreach($disk1 in $LogDops2){
                             $DiskF2Model = $disk1.Model
                             $DiskF2Size  = [math]::Round(($disk1.size)/1gb,2) 
                             Log "Диск - $DiskF2Model, Размер - $($DiskF2Size)Гб "
} 
Log "---------------------------"}
Catch {Log "$($Error[0].Tostring())" -ErrorLogText}
}
Function Get-KeyboardInfo{
<#
.Synopsis
   Вывод информации о подключенной клавиатуры
.DESCRIPTION
   Показывает детальную информацию о подключенной клавиатуры на удаленном компьютере  
.NOTES      
   Name: Admins   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/Admins/blob/master/Admins.psm1
.EXAMPLE
   Get-KeyboardInfo -ComputerName localhost
   [26.10.20][19:49:38][Информация] Имя клавиатуры   Расширенная клавиатура (101 или 102 клавиши)
   [26.10.20][19:49:38][Информация] Инфо устройства  Клавиатура HID
   [26.10.20][19:49:38][Информация] ИД               HID\{00001124-0000-1000-8000-00805F9B34FB}_VID&0001004C_PID&026C&COL01\8&5053C45&0&0000
   [26.10.20][19:49:38][Информация] Статус           OK
#>
param
([Parameter(Mandatory=$true)][String]$ComputerName)
try{
$KeyboardInfo1 = (Get-WmiObject -ComputerName $ComputerName -Class Win32_Keyboard -EA 1).Name
$KeyboardInfo2 = (Get-WmiObject -ComputerName $ComputerName -Class Win32_Keyboard -EA 1).Description
$KeyboardInfo3 = (Get-WmiObject -ComputerName $ComputerName -Class Win32_Keyboard -EA 1).DeviceID
$KeyboardInfo4 = (Get-WmiObject -ComputerName $ComputerName -Class Win32_Keyboard -EA 1).Status
Log "Имя клавиатуры   $KeyboardInfo1"
Log "Инфо устройства  $KeyboardInfo2"
Log "ИД               $KeyboardInfo3"
Log "Статус           $KeyboardInfo4"}
catch{Log "$($Error[0].ToString())" -ErrorLogText}
}
