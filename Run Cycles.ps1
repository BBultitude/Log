$input = 'Server1|Server2'

$logFile = 'C:\temp\logs\temp.log'

function Reconcile-Logs
    {
    param($sourceLog,$targetLog)
    $content = Get-Content $sourceLog
    foreach ($line in $content)
        {
        $line | Out-File -FilePath $targetLog -Append -Encoding utf8
        }
    Remove-Item $sourceLog -Force
    }

function Write-Log
    {
    param($Value,$Path,[ValidateSet("Informational","Warning","Error")]$LogLevel)
    $timeDate = Get-Date -Format MM-dd-yyyy
    $timeTime = Get-Date -Format HH:mm:ss.fff-fff

    switch ($LogLevel)
        {
        "Informational" {"<![LOG[<< I >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"ConfigMGR Actions`" type=`"1`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        "Warning" {"<![LOG[<< W >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"ConfigMGR Actions`" type=`"2`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        "Error" {"<![LOG[<< E >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"ConfigMGR Actions`" type=`"3`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        }
    }

$splitServers = $input.Split("|")

$computerNames = @()

foreach ($line in $splitServers)
    {
    $computerNames += $line.Split(";")[0]
    }

$completioncode = 0
$completionmessage = ""

# Script to trigger schedules in SCCM if Standard activity fails

foreach ($computer in $computerNames)
    {
        Write-Log -Value "Creating Remote PowerShell Session on $computer" -Path $logFile -LogLevel Informational
        $session = New-PSSession -ComputerName $computer
        Write-Log -Value "Run local ConfigMGR Agent Actions on system: $computer" -Path $logFile -LogLevel Informational
        Write-Log -Value "Temporary log file path will be on \\$computer\C`$\temp\patch.log" -Path $logFile -LogLevel Informational
        $output = Invoke-Command -Session $session -Scriptblock {

        $logFile = "C:\Temp\patch.log"
        New-Item -path $logfile -ItemType File -Force


function Write-Log
    {
    param($Value,$Path,[ValidateSet("Informational","Warning","Error")]$LogLevel)
    $timeDate = Get-Date -Format MM-dd-yyyy
    $timeTime = Get-Date -Format HH:mm:ss.fff-fff
    
    switch ($LogLevel)
        {
        "Informational" {"<![LOG[<< I >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"ConfigMGR Actions - $env:COMPUTERNAME`" type=`"1`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        "Warning" {"<![LOG[<< W >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"ConfigMGR Actions - $env:COMPUTERNAME`" type=`"2`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        "Error" {"<![LOG[<< E >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"ConfigMGR Actions - $env:COMPUTERNAME`" type=`"3`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        }
    }
            

        $mpTrigger = "{00000000-0000-0000-0000-000000000021}"
        $seTrigger = "{00000000-0000-0000-0000-000000000114}"
        $hwTrigger = "{00000000-0000-0000-0000-000000000001}"
        $ssTrigger = "{00000000-0000-0000-0000-000000000113}"

        

        for ($j=1;$j -lt 3;$j++) 
            {   
                Write-Log -Value "Trigger ConfigMGR Agent Action - Machine Policy Retrieval & Evaluation Cycle - Run $j of 2" -Path $logFile -LogLevel Informational
                $output = Invoke-WMIMethod -Namespace root\ccm -Class sms_client -Name TriggerSchedule $mpTrigger
                Write-Log -Value "Waiting 30 seconds then continue to next task" -Path $logFile -LogLevel Informational
                Start-Sleep -Seconds 30
            }
        

        for ($j=1;$j -lt 2;$j++)
            {   
                Write-Log -Value "Trigger ConfigMGR Agent Action - Hardware Inventory Cycle - Run $j of 1" -Path $logFile -LogLevel Informational
                $output = Invoke-WMIMethod -Namespace root\ccm -Class sms_client -Name TriggerSchedule $hwTrigger
                Write-Log -Value "Waiting 60 seconds then continue to next task" -Path $logFile -LogLevel Informational
        
                Start-Sleep -Seconds 60
            }


        for ($j=1;$j -lt 2;$j++)
            {   
                Write-Log -Value "Trigger ConfigMGR Agent Action - Software Updates Scan Cycle - Run $j of 1" -Path $logFile -LogLevel Informational
                $output = Invoke-WMIMethod -Namespace root\ccm -Class sms_client -Name TriggerSchedule $ssTrigger
                Write-Log -Value "Waiting 30 seconds then continue to next task" -Path $logFile -LogLevel Informational
                Start-Sleep -Seconds 30
            }
        

        for ($j=1;$j -lt 2;$j++)
            {   
                Write-Log -Value "Trigger ConfigMGR Agent Action - Software Update Deployment Evaluation Cycle - Run $j of 1" -Path $logFile -LogLevel Informational
                $output = Invoke-WMIMethod -Namespace root\ccm -Class sms_client -Name TriggerSchedule $seTrigger
                Write-Log -Value "Waiting 30 seconds then continue to next task" -Path $logFile -LogLevel Informational
        
                Start-Sleep -Seconds 30
            }
            
            

                Write-Log -Value "All ConfigMGR Agent Actions have been run - Waiting additional 60 seconds before continuing" -Path $logFile -LogLevel Informational
                Start-Sleep -Seconds 60
        }
        
        #Reconcile Logs
        
        Reconcile-Logs -sourceLog "\\$computer\C`$\temp\patch.log" -targetLog $logFile
        Write-Log -Value "Removed temporary log file from system: $computer" -Path $logFile -LogLevel Informational
        }
