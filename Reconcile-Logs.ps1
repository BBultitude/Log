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