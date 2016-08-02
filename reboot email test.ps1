$myinput = 'Server1;Service|Server2;Service|Server3;Service'

$logFile = 'C:\temp\logs\temp.log'

$global:EmailTo = "email@email.com.au"
$global:EmailFrom = "email@email.com.au"
$global:EmailSubject = "Server has not come back up after reboot!"
$global:EmailSMTP = "smtp server"




function Write-Log
    {
    param($Value,$Path,[ValidateSet("Informational","Warning","Error")]$LogLevel)
    $timeDate = Get-Date -Format MM-dd-yyyy
    $timeTime = Get-Date -Format HH:mm:ss.fff-fff

    switch ($LogLevel)
        {
        "Informational" {"<![LOG[<< I >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"Restart Server & Services`" type=`"1`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        "Warning" {"<![LOG[<< W >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"Restart Server & Services`" type=`"2`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        "Error" {"<![LOG[<< E >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"Restart Server & Services`" type=`"3`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        }
    }

function StopStart-Service
    {
    param([Array]$Services,$Computer,
    [ValidateSet("Start","Stop")]
    $Operation,$LogFile)

    if ($Operation -eq "Stop")
        {
        foreach ($service in $Services)
            {
            try
                {
                Write-Log -Value "Stopping service $service on $computer" -Path $logFile -LogLevel Informational
                $session = New-PSSession -ComputerName $computer -Name $computer -ErrorAction STOP
                $result = Invoke-Command -Session $session -ScriptBlock {try {Stop-Service $using:service -Force -PassThru -ErrorAction STOP} catch {$output += "Failed to stop service $service"; return $output}}
                }
            catch [System.Management.Automation.Remoting.PSRemotingTransportException]
                {
                Write-Log -Value "Failed to stop service $service on $computer" -Path $logFile -LogLevel Error
                $output += "Failed to connect to $computer and stop service $service"
                }
            $output += "$result"
            Remove-PSSession -Name $computer
            }
        }

    if ($Operation -eq "Start")
        {
        [array]::Reverse($Services)
        foreach ($service in $Services)
            {
            try
                {
                Write-Log -Value "Starting service $service on $computer" -Path $logFile -LogLevel Informational
                $session = New-PSSession -ComputerName $computer -Name $computer -ErrorAction STOP
                $result = Invoke-Command -Session $session -ScriptBlock {param($service)try {Start-Service -Name $service -PassThru -ErrorAction STOP} catch {$output += "Failed to start service $service"; return $output}} -ArgumentList $service
                }
            catch [System.Management.Automation.Remoting.PSRemotingTransportException]
                {
                Write-Log -Value "Failed to start service $service on $computer" -Path $logFile -LogLevel Error
                $output += "Failed to connect to $computer and stop service $service"
                }
            $output += "$result"
            Remove-PSSession -Name $computer
            }
        }
        Return $output
    }
            


function Reboot-Computer
    {
    param($computer,$Logfile)
    $output = ""
    try
        {
            Write-Log -Value "Restarting $computer" -Path $logFile -LogLevel Informational
            if(!(Test-Connection -ComputerName $computer -Count 4 -Quiet))
                {Write-Host 'Server Off'}
            Else
                {Restart-Computer -ComputerName $computer -Wait -Timeout 240 -Force -ErrorAction SilentlyContinue
                ipconfig /flushdns
                If (!(Test-Connection -ComputerName $computer -Count 4 -Quiet)){
                    Do{ $offtime = 0
                        while ($offtime -ne 10) { $offtime++ ; Start-Sleep 60}
                        if(!(Test-Connection -ComputerName $computer -Count 4 -Quiet))
                        {Send-MailMessage -To $global:EmailTo -From $global:EmailFrom -Subject $global:EmailSubject -Body "$computer has been off for 10 minutes after a reboot. Check server for 'Spinny Circle' issue. $(get-date -Format g)" -SmtpServer $global:EmailSMTP -Priority High }
                       } while (!(Test-Connection -ComputerName $computer -Count 4 -Quiet))
                     }
                    }
            Write-Log -Value "Successfully rebooted $computer" -Path $logFile -LogLevel Informational
        }
    catch
        {
            Write-Log -Value "Failed to restart $computer" -Path $logFile -LogLevel Error
            Write-Log -Value "$($error[0].Message)" -Path $logFile -LogLevel Error
            $output += $error[0].Message
        }
        
    return $output
    }


$splitServers = $myinput.Split("|")

$completionmessage = ""
$completionCode = 0

$computerServiceArray = @()

foreach ($line in $splitServers)
    {
    $props = @{
    Computer = $line.Split(";")[0]
    Services = $line.Split(";")[1]
    }
    $obj = New-Object -TypeName PSObject -Property $props
    $computerServiceArray += $obj
    }

#Stop the Services first

foreach ($obj in $computerServiceArray)
    {
    if ($obj.Services -ne $null)
        {
            [Array]$tmpsvcArray = $obj.Services.Split(",")
            $result = StopStart-Service -Services $tmpsvcArray -Computer $obj.Computer -Operation Stop -LogFile $logfile
        }
        else
        {
            Write-Log -Value "No dependant services detected on $($obj.Computer)" -Path $logFile -LogLevel Informational
        }
    }

$output += $result

#Reboot Machines
[array]::Reverse($computerServiceArray)

foreach ($computer in $computerServiceArray)
    {
    $result = Reboot-Computer -computer $computer.Computer -Logfile $logfile
    }

$output += $result

#Start Services
[array]::Reverse($computerServiceArray)

foreach ($obj in $computerServiceArray)
    {
    if ($obj.Services -ne $null)
        {
            [Array]$tmpsvcArray = $obj.Services.Split(",")
            $result = StopStart-Service -Services $tmpsvcArray -Computer $obj.Computer -Operation Start -LogFile $logfile
        }
    else
        {
            Write-Log -Value "No dependant services detected on $($obj.Computer)" -Path $logFile -LogLevel Informational
        }

    }

$output += $result
