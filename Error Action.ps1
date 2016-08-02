$logFile = 'C:\temp\logs\temp.log'
$errLogName = "c:\temp\logs\Error\$($logfile.Split("\")[3])"

function Write-Log
    {
    param($Value,$Path,[ValidateSet("Informational","Warning","Error")]$LogLevel)
    $timeDate = Get-Date -Format MM-dd-yyyy
    $timeTime = Get-Date -Format HH:mm:ss.fff-fff

    switch ($LogLevel)
        {
        "Informational" {"<![LOG[<< I >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"Error`" type=`"1`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        "Warning" {"<![LOG[<< W >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"Error`" type=`"2`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        "Error" {"<![LOG[<< E >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"Error`"> type=`"3`"" | Out-File -FilePath $Path -Append -Encoding utf8}
        }
    }

try
    {
    $file = Get-Content -Path $logFile -ErrorAction STOP
    }
catch
    {
    $completionMessage =  "Could not read file at $logfile"
    }

$errorDetect = $false

foreach ($line in $file)
    {
    if (!($line -match "<< I >>"))
        {
        $errorDetect = $true
        }
    }

if ($errorDetect -eq $true)
    {
    $completionCode = 2
    try
        {
        $errLog = $file | Out-file -FilePath "$errLogName" -Force -ErrorAction STOP
        }
    catch
        {
        $completionMessage = "Could not create error file"
       
        }
    $completionMessage = "Error log file has been written to " + $errLogName

    }
else
    {
    Write-Log -Value "No errors detected in Parent Runbook: \`d.T.~Ed/{DBDA9728-29FE-4899-881E-9DE4CD8D7242}.{93572677-1000-42AD-9D3F-BBA0E61E143B}\`d.T.~Ed/" -Path $logFile -LogLevel Informational
    $completionCode = 0
    $completionMessage = "No errors detected"
    }