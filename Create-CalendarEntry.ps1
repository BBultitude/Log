Function Create-CalendarEntry {
    Param(
        [Parameter(mandatory=$true)]
        [ValidatePattern('(0?[1-9]|[1-2][0-9]|3[0-1])\/(0?[1-9]|1[0-2])\/((19|20)?\d{2})')]
        $StartDate,
        [Parameter(mandatory=$true)]
        [ValidatePattern('((0?[1-9]|[1-2][0-2])\:([0-5][0-9])(AM|PM)?)|((0?[1-9]|[1][0-9]|[2][0-4])\:([0-5][0-9]))')]
        $StartTime,
        [Parameter(mandatory=$true)]
        [ValidatePattern('(0?[1-9]|[1-2][0-9]|3[0-1])\/(0?[1-9]|1[0-2])\/((19|20)?\d{2})')]
        $EndDate,
        [Parameter(mandatory=$true)]
        [ValidatePattern('((0?[1-9]|[1-2][0-2])\:([0-5][0-9])(AM|PM)?)|((0?[1-9]|[1][0-9]|[2][0-4])\:([0-5][0-9]))')]
        $EndTime,
        [Parameter(mandatory=$true)]$Subject,
        $Location,
        $Body,
        $Category
    )


    # General Variables
    $outlook = new-object -com Outlook.Application
    $calendar = $outlook.Session.folders.Item(1).Folders.Item("Calendar")
    $sDate = $StartDate | get-date -Format "dd/MM/yyyy"
    $eDate = $EndDate | get-date -Format "dd/MM/yyyy"
    $sTime = $StartTime| get-date -Format "HH:mm"
    $eTime = $EndTime | get-date -Format "HH:mm"



    # Worker
    $appt = $calendar.Items.Add(1) # == olAppointmentItem 
    $appt.Start = "$sDate $sTime"
    $appt.End = "$eDate $eTime"
    $appt.Subject = $Subject
    $appt.Location = $Location
    $appt.Body = $Body
    $appt.Categories = $Category
    $appt.Save()

}