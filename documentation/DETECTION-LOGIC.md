# Detection Logic

## Overview

This lab implements three custom PowerShell detections for monitoring identity-related security events.

The detections consume Windows Security events either directly from the Domain Controller or from the centralized `ForwardedEvents` log populated through Windows Event Forwarding.

---

# 1. Failed Logon Detection

## Detection

`Detect-FailedLogons.ps1`

## Event ID

`4625`

## Data Source

`ForwardedEvents`

## Source Endpoint

`CLIENT01.ad.cloudlab.local`

## Severity

`MEDIUM`

## Objective

Detect failed authentication attempts originating from a monitored endpoint.

Repeated failed authentication attempts may indicate:

- Incorrect credentials
- User error
- Password spraying
- Brute-force activity
- Credential misuse

## Detection Logic

```text
ForwardedEvents
      │
      ▼
Event ID 4625
      │
      ▼
CLIENT01
      │
      ▼
Extract authentication fields
      │
      ├── Account
      ├── Logon Type
      ├── Status
      └── Timestamp
      │
      ▼
Generate MEDIUM severity detection
      │
      ▼
Write incident to central CSV log

Example
Severity : MEDIUM
Account  : alice.employee
Source   : CLIENT01.ad.cloudlab.local
LogonType: 2
Status   : 0xc000006d
Event ID : 4625
2. Account Lockout Detection
Detection

Detect-AccountLockouts.ps1

Event ID

4740

Data Source

Security log on DC01

Severity

HIGH

Objective

Detect Active Directory account lockouts.

Account lockouts can be caused by:

Repeated incorrect passwords
Stale credentials
Misconfigured services
Automated authentication attempts
Password spraying
Brute-force activity
Detection Logic
DC01 Security Log
      │
      ▼
Event ID 4740
      │
      ▼
Extract TargetUserName
      │
      ▼
Identify locked account
      │
      ▼
Generate HIGH severity detection
      │
      ▼
Write incident to central CSV log
Example
Severity : HIGH
Account  : alice.employee
Event ID : 4740
Detection: Account Lockout
3. Credential Attack Correlation
Detection

Detect-CredentialAttack.ps1

Correlation

4625 + 4740

Severity

HIGH

Objective

Identify a potential credential attack by correlating multiple failed authentication attempts with a subsequent account lockout.

This provides a higher-confidence detection than analyzing a single failed logon event.

Detection Threshold

The current detection triggers when:

3 or more failed authentication attempts
        +
Account lockout
        +
Same account
        +
Within 5 minutes
Detection Logic
                 CLIENT01
                    │
                    ▼
              Failed Logons
                 Event 4625
                    │
                    │
                    ▼
              ForwardedEvents
                    │
                    │
                    ├──────────────┐
                    │              │
                    │              │
                    ▼              │
              Failed Attempts     │
                    │              │
                    │              │
                    └──────┐       │
                           │       │
                           ▼       │
                    DC01 Security  │
                       Event 4740  │
                           │       │
                           └───────┘
                               │
                               ▼
                         Correlation
                               │
                               ▼
                    3+ failures in 5 min
                               │
                               ▼
                    HIGH severity alert
                               │
                               ▼
                     Central Incident Log
4. Incident Logging

All detections write structured records to:

C:\SecurityLab\Incidents\incident-log.csv

The following fields are recorded:

Field	Description
Timestamp	Detection timestamp
Severity	MEDIUM or HIGH
Detection	Detection category
Account	Affected account
Source	Originating endpoint
EventID	Windows event identifier
Details	Detection context
5. Detection Examples
Failed Authentication
MEDIUM
Detection: Failed Logon
Account: alice.employee
Source: CLIENT01
Event ID: 4625
Account Lockout
HIGH
Detection: Account Lockout
Account: alice.employee
Event ID: 4740
Correlated Credential Attack
HIGH
Detection: Credential Attack
Account: alice.employee
Failed Logons: 4
Lockout Event: 4740
Correlation Window: 5 minutes
6. Security Interpretation

The detections are intentionally simple and transparent.

They demonstrate how raw Windows security telemetry can be transformed into security-relevant detections.

The detection pipeline is:

Telemetry
    ↓
Collection
    ↓
Parsing
    ↓
Detection Logic
    ↓
Correlation
    ↓
Severity Classification
    ↓
Incident Logging

This represents a simplified SOC detection-engineering workflow.

7. Limitations

These detections are designed for an educational lab and are not intended to replace a production SIEM or EDR platform.

Potential production improvements include:

Time-based alert suppression
Alert deduplication
IP reputation
Geographic analysis
User risk scoring
Baseline-based anomaly detection
Password spraying detection across multiple accounts
Integration with Microsoft Sentinel
Automated response
Alert notification
Case management
Long-term centralized log storage
8. Windows Server 2025 WEF Consideration

During development, filtered Get-WinEvent queries against ForwardedEvents produced an RPC error on the Windows Server 2025 collector.

The implementation therefore retrieves events without a server-side event filter and performs filtering in PowerShell:

Get-WinEvent -LogName ForwardedEvents -MaxEvents 1000 |
    Where-Object { $_.Id -eq 4625 }

This approach was successfully used to process centralized CLIENT01 security events.

9. MITRE ATT&CK Relevance

The detections provide visibility relevant to several identity-focused attack techniques.

Potentially relevant techniques include:

T1110 — Brute Force
T1078 — Valid Accounts
T1059.001 — PowerShell

The lab does not claim to implement full MITRE ATT&CK detection coverage. These mappings provide context for how the telemetry could support enterprise threat detection.

10. Detection Engineering Takeaway

The main objective of this lab is to demonstrate the progression from:

Windows Event
      ↓
Centralized Telemetry
      ↓
Detection Rule
      ↓
Event Correlation
      ↓
Severity
      ↓
Incident Record

This demonstrates practical security monitoring and detection-engineering concepts using native Windows and Azure capabilities.