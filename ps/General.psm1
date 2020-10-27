Function Log {
<#
.Synopsis
   Логинирование
.DESCRIPTION
   Логинирование действий скрипта
.NOTES      
   Name: General   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/Admins/blob/master/ps/General.psm1
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
   Name: General   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/Admins/blob/master/ps/General.psm1
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
   Name: General   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/Admins/blob/master/ps/General.psm1
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
   Name: General   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/Admins/blob/master/ps/General.psm1
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
Function Get-DesktopMonitorInfo{
<#
.Synopsis
   Вывод информации о подключенном мониторе
.DESCRIPTION
   Показывает детальную инофрмацию о подключенном мониторе удаленного компьютера  
.NOTES      
   Name: General   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/Admins/blob/master/ps/General.psm1
.EXAMPLE
   Get-DesktopMonitorInfo -ComputerName localhost
   [26.10.20][19:57:56][Информация] Имя монитора  Универсальный монитор PnP Универсальный монитор PnP
   [26.10.20][19:57:56][Информация] ИД  монитора  DesktopMonitor1 DesktopMonitor2
   [26.10.20][19:57:56][Информация] Тип монитора  (Стандартные мониторы) (Стандартные мониторы)
#>
param
([Parameter(Mandatory=$true)][String]$ComputerName)
try{
$DesktopMonitorInfo1 = (Get-WmiObject -ComputerName $ComputerName -Class Win32_DesktopMonitor -EA 1).Name
$DesktopMonitorInfo2 = (Get-WmiObject -ComputerName $ComputerName -Class Win32_DesktopMonitor -EA 1).DeviceID
$DesktopMonitorInfo3 = (Get-WmiObject -ComputerName $ComputerName -Class Win32_DesktopMonitor -EA 1).MonitorManufacturer
Log "Имя монитора  $DesktopMonitorInfo1"
Log "ИД  монитора  $DesktopMonitorInfo2"
Log "Тип монитора  $DesktopMonitorInfo3"}
catch{Log "$($Error[0].ToString())" -ErrorLogText}
}
Function Get-VirtualMemoryInfo{
<#
.Synopsis
   Вывод информации о виртуальной памяти
.DESCRIPTION
   Показывает инофрмацию установленной виртуальной памяти удаленного компьютера  
.NOTES      
   Name: General   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/Admins/blob/master/ps/General.psm1
.EXAMPLE
   Get-VirtualMemoryInfo -ComputerName localhost
   [26.10.20][20:01:39][Информация] Виртуальная память по умолчанию Windows (размер не выводит)
#>
param(
[Parameter(Mandatory =$true, Position = 0 )][string[]]$ComputerName
)
try{
$VarInfoVirtMem0 = Get-WmiObject -Class Win32_pagefilesetting -ComputerName $ComputerName -EnableAllPrivileges -ErrorAction Stop
if ($VarInfoVirtMem0){
    if($VarInfoVirtMem0.Count -gt 1){
    Log -text "Виртуальная память"
    Log -text "Обнаружено несколько файлов подкачки - [$($VarInfoVirtMem0.count)]"
            }
    foreach($line in $VarInfoVirtMem0){
    $line1 = $line.name
    $line2 = $line.InitialSize
    $line3 = $line.MaximumSize 
    Log -text "Виртуальная память  = [$line1]"
    Log -text "Начальный размер    = $line2 мб"
    Log -text "Максимальный размер = $line3 мб"
            }
        }else{Log -text "Виртуальная память по умолчанию Windows (размер не выводит)"} 
    }catch{Log -text "$($Error[0].ToString())" -ErrorLogText}
}
Function Get-RamInfo{
<#
.Synopsis
   Вывод информации о оперативной памяти
.DESCRIPTION
   Показывает инофрмацию о оперативной памяти удаленного компьютера  
.NOTES      
   Name: General   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/Admins/blob/master/ps/General.psm1
.EXAMPLE
   Get-RamInfo -ComputerName localhost
   [26.10.20][20:04:41][Информация] Количество слотов под ОЗУ 4
   [26.10.20][20:04:41][Информация] Количесто ОЗУ           64gb
#>
param
([Parameter(Mandatory=$true)][String]$ComputerName)
try{$WmiBankLabel = (Get-WmiObject -ComputerName $ComputerName -Class Win32_PhysicalMemory -EA 1 | Select-Object -Property BankLabel).count
    $SumRam1 = 0 
    Get-WmiObject -ComputerName $ComputerName -Class Win32_PhysicalMemory -EA 1 | ForEach-Object -Process {$SumRam1 = $_.Capacity + $SumRam1} 
    $script:WmiSumRam1 = $SumRam1/1gb
    if($WmiSumRam1 -lt 16){$script:WmiSumRam3 = 4096}else{$script:WmiSumRam3 = 8192}
    Log "Количество слотов под ОЗУ $WmiBankLabel"
    Log "Количесто ОЗУ           $($WmiSumRam1)gb"}
catch{Log "$($Error[0].ToString())" -ErrorLogText}
}
Function Get-LastTimeBoot{
<#
.Synopsis
   Вывод информации о времени с последней перезагрузки
.DESCRIPTION
   Показывает инофрмацию какой временной отрезок прошел с момента последней перезагрузки компьютера  
.NOTES      
   Name: General   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/RussianPost/blob/master/ps/General.psm1
.EXAMPLE
   Get-LastTimeBoot -ComputerName localhost
   [27.10.20][19:03:35][Информация] Время с последней перезагрузки = 5.20:34:47.2146392
#>
param
([Parameter(Mandatory=$true)][String]$ComputerName)
 try{$wmi=Get-WmiObject -Class win32_operatingsystem -ComputerName $ComputerName -EA 1
    $boot=$wmi.ConvertToDateTime($wmi.LastBootUpTime)
    log "Время с последней перезагрузки = $(((Get-Date)-$boot).ToString())"}
catch{Log "LastTime"
      Log "$($Error[0].ToString())"}
}
