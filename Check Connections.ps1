$input = 'dvsccmpatch.ad.hd.hastdeer.com.au|dvaubneaostest.sdiad.simedarbyindustrial.com'

$logFile = 'C:\temp\logs\temp.log'

function Write-Log
    {
    param($Value,$Path,[ValidateSet("Informational","Warning","Error")]$LogLevel)
    $timeDate = Get-Date -Format MM-dd-yyyy
    $timeTime = Get-Date -Format HH:mm:ss.fff-fff

    switch ($LogLevel)
        {
        "Informational" {"<![LOG[<< I >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"Connection Test`" type=`"1`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        "Warning" {"<![LOG[<< W >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"Connection Test`" type=`"2`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        "Error" {"<![LOG[<< E >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"Connection Test`" type=`"3`">" | Out-File -FilePath $Path -Append -Encoding utf8}
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

foreach ($computer in $computerNames)
    {
    Write-Log -Value "Testing connection to $computer" -Path $logFile -LogLevel Informational
    if (!(Test-Connection -ComputerName $computer -Count 4 -Quiet))
        {
        $completioncode=2
        $completionmessage += "Cannot ping $computer. "
        Write-Log -Value "Cannot ping $computer. " -Path $logFile -LogLevel Error
        }
    else
        {
            Write-Log -Value "Successfully pinged $computer" -Path $logFile -LogLevel Informational
            Write-Log -Value "Attempting to create a Remote PowerShell Session to $computer" -Path $logFile -LogLevel Informational
            try
                {
                $session = New-PSSession -ComputerName $computer -ErrorAction Stop
                Write-Log -Value "Successfully created Remote PowerShell Session to $computer" -Path $logFile -LogLevel Informational
                }
            catch
                {
                $completioncode=2
                $completionmessage += "Remote PS connection to $computer cannot be made"
                Write-Log -Value "Remote PowerShell Connection to $computer cannot be made" -Path $logFile -LogLevel Error
                }
        }
    }

Get-PSSession | Remove-PSSession