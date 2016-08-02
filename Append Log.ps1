
$NameCollectionRule = 
$RuleCollectionRule = 
$ComputernameSplitNames =

$logFile = '\`d.T.~Ed/{43D6B2AF-C2BA-44DB-B0A0-DDD8392441BF}.{23076268-5F71-41A4-97AA-00D768939C3D}\`d.T.~Ed/'

function Write-Log
    {
    param($Value,$Path,[ValidateSet("Informational","Warning","Error")]$LogLevel)
    $timeDate = Get-Date -Format MM-dd-yyyy
    $timeTime = Get-Date -Format HH:mm:ss.fff-fff

    switch ($LogLevel)
        {
        "Informational" {"<![LOG[<< I >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"ConfigMGR Collection - Add`" type=`"1`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        "Warning" {"<![LOG[<< W >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"ConfigMGR Collection - Add`" type=`"2`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        "Error" {"<![LOG[<< E >> $Value]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"ConfigMGR Collection - Add`" type=`"3`">" | Out-File -FilePath $Path -Append -Encoding utf8}
        }
    }


Write-Log -Value "$ComputernameSplitNames has been added to ConfigMGR collection $NameCollectionRule as a $RuleCollectionRule" -Path $logFile -LogLevel Informational