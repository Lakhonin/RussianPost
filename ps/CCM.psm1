Function Get-ViewerCCM{
<#
.Synopsis
   Вывод информации о последнем подключении 
.DESCRIPTION
   Выводит информацию от том кто последний подключался к компьютеру по порту 2701  
.NOTES      
   Name: CCM   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/RussianPost/blob/master/ps/CCM.psm1
.EXAMPLE
Get-ViewerCCM -ComputerName "R50-105203-0000" -Path "C$\Windows\CCM\Logs\CmRcService.log"
[05.12.20][00:05:40][Информация] [R50-105203-0000]
[05.12.20][00:05:40][Информация] Последний раз подключался[sccm] MAIN\A.Lakhonin-adm - точное время 23:54:46
[05.12.20][00:05:40][Информация] Дата подключения 12-04-2020, c 10.92.0.92:50560 на 10.100.2.2:2701
#>
param(
[Parameter(Mandatory=$true, Position = 0)][String] $ComputerName,
[Parameter(Mandatory=$true, Position = 1)][String] $Path="C$\Windows\CCM\Logs\CmRcService.log"
)
if(Test-Path "\\$ComputerName\$Path"){
$Select1AVU = Select-String -Pattern "Authorized viewer user" -Context 0,2 -Path  \\$ComputerName\$Path | Select-Object -Last 1
$Select1AVU = ($Select1AVU.ToString() -split "\n") -creplace ".*\[LOG\[\s\s\s\s" -replace "\scomponent.*" -replace "\]LOG]!><", " "
$LineAuto   = ($Select1AVU[0] -replace "Authorized viewer user: " -replace "time=""" -replace "\.\d.*=""", " " -replace"""") -split " "
$Vaddr      = ($Select1AVU[1] -replace "Viewer address: " -replace " time=""", " " -replace "\.\d{3}-\d{3}"" date=""", " " -replace """") -split " "
$HostAddr   = ($Select1AVU[2] -replace "Host address: " -replace " time=""", " " -replace "\.\d{3}-\d{3}"" date=""", " " -replace """") -split " "
Log -text "[$ComputerName]"
Log -text "Последний раз подключался[sccm] $($LineAuto[0]) - точное время $($LineAuto[1])"
Log -text "Дата подключения $($LineAuto[2]), c $($Vaddr[0]) на $($HostAddr[0])"
}else{"Файл лога[sccm] не найден"}
}

Function Start-CCMRemoteControl{
<#
.Synopsis
   Подключение по CCM к удаленному ПК 
.DESCRIPTION
   Запускает CCMRemoteControl и подключается к компьютеру по порту 2701  
.NOTES      
   Name: CCM   
   Author: Aleksandr Lakhonin      
   https://github.com/Lakhonin/RussianPost/blob/master/ps/CCM.psm1
.EXAMPLE
Start-CCMRemoteControl -ComputerName $comp -PathCCMRemoteControl $CCMRemoteControl
#>
param
([Parameter(Mandatory=$true)][String]$ComputerName,
 [Parameter(Mandatory=$true)][String]$PathCCMRemoteControl
)
if(Test-Path -Path $PathCCMRemoteControl){
Start-Process -FilePath $PathCCMRemoteControl -ArgumentList $ComputerName 
}else{Log -text "Файл CmRcViewer.exe не найден" -ErrorLogText}
}

Function Run-CCMClientAction {
        [CmdletBinding()]
                
        # Parameters used in this function
        param
        ( 
            [Parameter(Position=0, Mandatory = $True, HelpMessage="Provide server names", ValueFromPipeline = $true)] 
            [string[]]$ComputerName,
 
           [ValidateSet('MachinePolicy', 
                        'DiscoveryData', 
                        'ComplianceEvaluation', 
                        'AppDeployment',  
                        'HardwareInventory', 
                        'UpdateDeployment', 
                        'UpdateScan', 
                        'SoftwareInventory')] 
            [string[]]$ClientAction
   
        ) 
        $ActionResults = @()
        Try { 
                $ActionResults = Invoke-Command -ComputerName $ComputerName {param($ClientAction)
 
                        Foreach ($Item in $ClientAction) {
                            $Object = @{} | select "Action name",Status
                            Try{
                                $ScheduleIDMappings = @{ 
                                    'MachinePolicy'        = '{00000000-0000-0000-0000-000000000021}'; 
                                    'DiscoveryData'        = '{00000000-0000-0000-0000-000000000003}'; 
                                    'ComplianceEvaluation' = '{00000000-0000-0000-0000-000000000071}'; 
                                    'AppDeployment'        = '{00000000-0000-0000-0000-000000000121}'; 
                                    'HardwareInventory'    = '{00000000-0000-0000-0000-000000000001}'; 
                                    'UpdateDeployment'     = '{00000000-0000-0000-0000-000000000108}'; 
                                    'UpdateScan'           = '{00000000-0000-0000-0000-000000000113}'; 
                                    'SoftwareInventory'    = '{00000000-0000-0000-0000-000000000002}'; 
                                }
                                $ScheduleID = $ScheduleIDMappings[$item]
                                Write-Verbose "Processing $Item - $ScheduleID"
                                [void]([wmiclass] "root\ccm:SMS_Client").TriggerSchedule($ScheduleID);
                                $Status = "Success"
                                Write-Verbose "Operation status - $status"
                            }
                            Catch{
                                $Status = "Failed"
                                Write-Verbose "Operation status - $status"
                            }
                            $Object."Action name" = $item
                            $Object.Status = $Status
                            $Object
                        }
 
            } -ArgumentList $ClientAction -ErrorAction Stop | Select-Object @{n='ServerName';e={$_.pscomputername}},"Action name",Status
        }  
        Catch{
            Write-Error $_.Exception.Message 
        }   
        Return $ActionResults           
 }
