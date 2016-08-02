$action = 'Add'

$logFile = 'C:\temp\logs\temp.log'

function Write-Log
    {
    param($Value,$Path,[ValidateSet("Informational","Warning","Error")]$LogLevel)
    $timeDate = Get-Date -Format MM-dd-yyyy
    $timeTime = Get-Date -Format HH:mm:ss.fff-fff

    switch ($LogLevel)
        {
        "Informational" {"<![LOG[<< I >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"ConfigMGR Collection - $action`" type=`"1`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        "Warning" {"<![LOG[<< W >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"ConfigMGR Collection - $action`" type=`"2`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        "Error" {"<![LOG[<< E >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"ConfigMGR Collection - $action`" type=`"3`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        }
    }

Write-Log -Value "Collection action is $action" -Path $logFile -LogLevel Informational