# Detection: Account Lockout
# Event ID: 4740
# Purpose: Detect and identify locked Active Directory accounts
# Output: Central incident log

$StartTime = (Get-Date).AddHours(-24)

$Lockouts = Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    Id        = 4740
    StartTime = $StartTime
} -ErrorAction SilentlyContinue

$IncidentLog = "C:\SecurityLab\Incidents\incident-log.csv"

Write-Host "=== Identity Security Detection ===" -ForegroundColor Cyan
Write-Host "Detection: Account Lockout"
Write-Host "Event ID : 4740"
Write-Host ""

Write-Host "Account Lockouts detected: $($Lockouts.Count)"
Write-Host ""

if ($Lockouts.Count -gt 0) {

    Write-Host "[HIGH] Account Lockout Detected" -ForegroundColor Red
    Write-Host ""

    $ExistingIncidents = @()

    if (Test-Path $IncidentLog) {
        $ExistingIncidents = @(Import-Csv $IncidentLog)
    }

    foreach ($Event in $Lockouts) {

        $xml = [xml]$Event.ToXml()
        $data = @{}

        foreach ($item in $xml.Event.EventData.Data) {
            $data[$item.Name] = $item.'#text'
        }

        $Account = $data['TargetUserName']
        $Source = $data['CallerComputerName']
        $Timestamp = $Event.TimeCreated.ToString("o")

        $AlreadyLogged = $ExistingIncidents | Where-Object {
            $_.Timestamp -eq $Timestamp -and
            $_.Account -eq $Account -and
            $_.EventID -eq "4740"
        }

        if (-not $AlreadyLogged) {

            [PSCustomObject]@{
                Timestamp  = $Timestamp
                Severity   = "HIGH"
                Detection  = "Account Lockout"
                Account    = $Account
                Source     = $Source
                EventID    = "4740"
                Details    = "Active Directory account locked out"
            } | Export-Csv -Path $IncidentLog -Append -NoTypeInformation

            Write-Host "[LOGGED] Incident written to central log" -ForegroundColor Yellow
        }
        else {
            Write-Host "[INFO] Incident already exists in central log" -ForegroundColor DarkGray
        }

        Write-Host "Severity : HIGH"
        Write-Host "Account  : $Account"
        Write-Host "Source   : $Source"
        Write-Host "Time     : $($Event.TimeCreated)"
        Write-Host "Event ID : $($Event.Id)"
        Write-Host ""
    }
}
else {
    Write-Host "[OK] No account lockouts detected." -ForegroundColor Green
}