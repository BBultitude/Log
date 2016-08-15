# --------------------------------------------------------
# Note: if you see the following <# #> with text inbetween
# then it is a comment. If you see a hash symbol with text
# directly after it then it is a command that has been
# commented out!
# --------------------------------------------------------

$date = Get-Date -Format ddMMyyyy
$User = $env:username
$folder = "C:\Users\$user\Desktop"
$filename = "WrongOUComputers.csv"
$file = "$folder\$filename"

New-Item -Name WrongOUComputers.csv -Path $folder -Force -ItemType file
Add-Content $file "ComputerName,Site"

Write-Host "$file has been created put the relivant data in the correct column then press Enter"
pause

<# Imports Module and CSV file #>

Import-Module ActiveDirectory 
Import-Csv $file | % { 


<# Sets Variables based on AD Enviroment and Description #>

$Computer = $_.ComputerName
$site = $_.Site
$Desc = "$site"

if ($type -eq "D") 
   { $Container = "Desktops" }
elseif($type -eq "L") 
   { $Container = "Laptops" }
else
   { $Container = "Exceptions" }

$ou = "OU=$Container,OU=Computers,OU=$site,OU=Hastings Deering,DC=ad,DC=hd,DC=hastdeer,DC=com,DC=au"


<# Uses Variables to put the Computer in the correct AD Group,
add a Description and then Disable that computer #>

Get-ADComputer $Computer | move-ADObject -TargetPath $ou
set-ADComputer $Computer -description $Desc
}

<# Renames CSV file to advise it has been processed on
X Date #>

Rename-Item $file "$filename - Processed $Date.csv"