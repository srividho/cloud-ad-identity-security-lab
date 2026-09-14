# Detection: Failed Logon
# Event ID: 4625
# Source: Centralized WEF ForwardedEvents
# Purpose: Detect failed authentication attempts from lab endpoints
# Output: Central incident log

$FailedLogons = Get-WinEvent -LogName ForwardedEvents -MaxEvents 1000 |
    Where-Object {
        $_.Id -eq 4625 -and
        $_.MachineName -eq 'CLIENT01.ad.cloudlab.local'
    }

$IncidentLog = "C:\SecurityLab\Incidents\incident-log.csv"

Write-Host "=== Centralized Identity Security Detection ===" -ForegroundColor Cyan
Write-Host "Detection: Failed Logon"
Write-Host "Event ID : 4625"
Write-Host "Source   : CLIENT01"
Write-Host ""

Write-Host "Failed Logons detected: $($FailedLogons.Count)"
Write-Host ""

if ($FailedLogons.Count -gt 0) {

    Write-Host "[MEDIUM] Failed Logon Activity Detected" -ForegroundColor Yellow
    Write-Host ""

    $ExistingIncidents = @()

    if (Test-Path $IncidentLog) {
        $ExistingIncidents = @(Import-Csv $IncidentLog)
    }

    foreach ($Event in $FailedLogons) {

        $xml = [xml]$Event.ToXml()
        $data = @{}

        foreach ($item in $xml.Event.EventData.Data) {
            $data[$item.Name] = $item.'#text'
        }

        $Account = $data['TargetUserName']
        $Source = $Event.MachineName
        $LogonType = $data['LogonType']
        $Status = $data['Status']
        $Timestamp = $Event.TimeCreated.ToString("o")

        $AlreadyLogged = $ExistingIncidents | Where-Object {
            $_.Timestamp -eq $Timestamp -and
            $_.Account -eq $Account -and
            $_.EventID -eq "4625"
        }

        if (-not $AlreadyLogged) {

            [PSCustomObject]@{
                Timestamp = $Timestamp
                Severity  = "MEDIUM"
                Detection = "Failed Logon"
                Account   = $Account
                Source    = $Source
                EventID   = "4625"
                Details   = "Failed authentication attempt; LogonType=$LogonType; Status=$Status"
            } | Export-Csv -Path $IncidentLog -Append -NoTypeInformation

            Write-Host "[LOGGED] Incident written to central log" -ForegroundColor Yellow
        }
        else {
            Write-Host "[INFO] Incident already exists in central log" -ForegroundColor DarkGray
        }

        Write-Host "Severity  : MEDIUM"
        Write-Host "Account   : $Account"
        Write-Host "Source    : $Source"
        Write-Host "LogonType : $LogonType"
        Write-Host "Status    : $Status"
        Write-Host "Time      : $($Event.TimeCreated)"
        Write-Host "Event ID  : $($Event.Id)"
        Write-Host ""
    }
}
else {
    Write-Host "[OK] No failed logons detected." -ForegroundColor Green
}