function Write-Log
    {param([Parameter(Mandatory=$true)][String]$LogText,[Parameter(Mandatory=$true)]$LogPath,[ValidateSet("Informational","Warning","Error","Verbose")]$LogLevel="Informational",[String]$LogComponent)
    $timeDate = Get-Date -Format MM-dd-yyyy
    $timeTime = Get-Date -Format HH:mm:ss.fff-fff
    switch ($LogLevel)
        {
        "Informational" {"<![LOG[$LogText]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"$LogLevel`: $LogComponent`" type=`"1`">" | Out-File -FilePath $LogPath -Append -Encoding utf8}
        "Warning" {"<![LOG[$LogText]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"$LogLevel`: $LogComponent`" type=`"2`">" | Out-File -FilePath $LogPath -Append -Encoding utf8}
        "Error" {"<![LOG[$LogText]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"$LogLevel`: $LogComponent`" type=`"3`">" | Out-File -FilePath $LogPath -Append -Encoding utf8}
        "Verbose" {"<![LOG[$LogText]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"$LogLevel`: $LogComponent`" type=`"4`">" | Out-File -FilePath $LogPath -Append -Encoding utf8}
        }
    <#
    .Synopsis
        Adds a formated log entry to supplied file.

    .DESCRIPTION
        Adds a formated log entry to supplied file.
        Takes the (LogValue) String of text and variables then proceeds to join the Time, Date, (LogComponent) subject of the current line
        to be written to log. Once the Values are joined the Write-Log Function then outputs it into a readable output for log file viewers
        to the file specified using the LogPath variable.

    .EXAMPLE
        Write-Log -LogText "This is a new line for a log file" -LogPath "C:\Logs.log" -LogLevel Informational -LogComponent "This is a component"

    .EXAMPLE
        Write-Log -LogText "This is a new line for a log file" -LogPath "C:\Logs.log" -LogLevel Warning

    .EXAMPLE
        Write-Log -LogText "This is a new line for a log file" -LogPath "C:\Logs.log"

    .EXAMPLE
        Write-Log "This is a new line for a log file" -LogPath "C:\Logs.log"

    .EXAMPLE
        Write-log "This is a new line for a log file" "C:\Logs.log" Informational "This is the Component"


    .INPUTS
        None. You cannot pipe objects to Write-Log.

    .OUTPUTS
        None. Write-Log does not generate on screen output.

    .NOTES
        Output is best viewed using "CMTrace" or "Support Center Log File Viewer".

    #>
    }
