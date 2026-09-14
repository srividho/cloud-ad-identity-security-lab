# Cloud AD Infrastructure & Identity Security Lab

A hands-on Azure-based cybersecurity lab demonstrating Active Directory infrastructure, endpoint security monitoring, Windows Event Forwarding (WEF), PowerShell logging, and custom identity-threat detection.

## Project Overview

This project simulates a small enterprise Windows environment hosted in Microsoft Azure.

The lab focuses on:

- Active Directory identity management
- Secure workstation administration
- Windows security auditing
- PowerShell activity monitoring
- Centralized Windows Event Forwarding
- Authentication-failure detection
- Account-lockout detection
- Credential-attack correlation
- Basic incident logging and triage

The objective was to build a practical security monitoring workflow rather than simply deploy virtual machines.

---

## Architecture

```text
                         Microsoft Azure
                              |
                    +---------------------+
                    |  Virtual Network    |
                    |   10.10.0.0/16      |
                    +----------+----------+
                               |
              +----------------+----------------+
              |                                 |
       10.10.1.0/24                     10.10.2.0/24
         AD Subnet                       Client Subnet
              |                                 |
       +------+-------+                  +------+-------+
       |    DC01      |                  |   CLIENT01   |
       | Windows      |                  | Windows      |
       | Server 2025  |                  | Server 2025  |
       |              |                  |              |
       | AD DS        |                  | Domain       |
       | DNS          |                  | Joined       |
       | WEC          |<----- WEF --------| Security    |
       | Detection    |                  | Events       |
       +------+-------+                  +--------------+
              |
              |
       ForwardedEvents
              |
       +------+-------------------+
       | Detection Engine         |
       |                          |
       | 4625 Failed Logon        |
       | 4740 Account Lockout     |
       | 4625 + 4740 Correlation  |
       +------------+-------------+
                    |
                    v
             Incident Log (CSV)

Environment

Component	Configuration
Cloud	Microsoft Azure
Region	Denmark East
Domain Controller	DC01
Client Endpoint	CLIENT01
Operating System	Windows Server 2025
Active Directory Domain	ad.cloudlab.local
DNS	DC01
Event Collector	DC01
Event Source	CLIENT01
Event Forwarding	Windows Event Forwarding
Network	Azure Virtual Network
Detection Language	PowerShell

Active Directory

The lab domain is:

ad.cloudlab.local

Organizational Units were created to separate users, administrators, security personnel, groups, and workstations.

Users
Alice Employee
Bob ITAdmin
Charlie Security

Security Groups
GG-Employees
GG-IT-Admins
GG-Security-Team
GG-Workstation-Users

Administrative Control

The GG-IT-Admins group is granted local administrator access on CLIENT01 through Group Policy.
This demonstrates centralized privilege management rather than manually configuring administrator access on the workstation.

Security Controls

Advanced Security Auditing
The lab enables Windows Advanced Audit Policy to capture security-relevant activity.

Examples include:
Event ID 4625 — Failed logon
Event ID 4740 — Account lockout
Event ID 4672 — Special privileges assigned
Event ID 4688 — Process creation
Event ID 4689 — Process termination

PowerShell Logging
PowerShell logging is configured through Group Policy.

Enabled controls include:
Script Block Logging
Module Logging
PowerShell Transcription

Script Block Logging was validated using Event ID 4104.

Example activity was generated using PowerShell commands and verified in:

Microsoft-Windows-PowerShell/Operational

Windows Event Forwarding

CLIENT01 forwards security events to DC01 using Windows Event Forwarding.

WEF Architecture

CLIENT01
   |
   | Security Events
   | 4625 / 4672 / 4688 / 4689
   |
   v
Windows Event Forwarding
   |
   v
DC01
   |
   v
ForwardedEvents

The implementation uses:

Source-initiated WEF
Group Policy configuration
Subscription Manager
HTTP / WinRM
Centralized ForwardedEvents log

The WEF subscription is named:

CLIENT01-Security-Monitoring

Detection Engineering:

Three custom PowerShell detection scripts were developed.

1. Failed Logon Detection

File:

Detect-FailedLogons.ps1

Detects Event ID 4625 from CLIENT01 through the centralized ForwardedEvents log.

The detector extracts:

Account
Source machine
Logon type
Authentication status
Timestamp
Event ID

Severity:

MEDIUM

2. Account Lockout Detection

File:

Detect-AccountLockouts.ps1

Detects Event ID 4740 from the Domain Controller.

The detector identifies:

Locked account
Lockout timestamp
Event ID

Severity:

HIGH

3. Credential Attack Correlation

File:

Detect-CredentialAttack.ps1

Correlates repeated failed authentication attempts with an account lockout.

Detection logic:

3+ failed logons
       +
Account lockout
       +
5-minute correlation window
       =
Potential Credential Attack

Severity:

HIGH

This demonstrates basic correlation-based detection rather than treating every individual authentication failure as an isolated event.

Incident Logging:

Detected security events are written to a centralized CSV incident log.

Example fields:

Timestamp
Severity
Detection
Account
Source
EventID
Details

Example detection:

Severity: HIGH
Detection: Credential Attack
Account: alice.employee
Source: CLIENT01.ad.cloudlab.local
EventID: 4740

Attack Simulation:

The lab was tested by intentionally generating failed authentication attempts against a test account.

The resulting sequence was:

Multiple failed logons
        |
        v
Event ID 4625
        |
        v
Account lockout
        |
        v
Event ID 4740
        |
        v
Correlation engine
        |
        v
HIGH - Potential Credential Attack
        |
        v
Central Incident Log

The detection successfully correlated four failed authentication attempts with an account lockout occurring within the configured five-minute window.

Validation Results:

The final validation confirmed:

Active Directory operational
DNS operational
NTDS operational
Windows Event Collector operational
WinRM operational
CLIENT01 domain joined
Security groups configured
WEF forwarding operational
Event ID 4625 received centrally
Event ID 4672 received centrally
Event ID 4688 received centrally
Event ID 4689 received centrally
Account-lockout detection operational
Credential-attack correlation operational
Central incident logging operational

Key Security Concepts Demonstrated:
Active Directory security
Identity and access management
Least-privilege administration
Group Policy
Windows security auditing
PowerShell logging
Windows Event Forwarding
Security event collection
Detection engineering
Event correlation
Authentication monitoring
Account lockout analysis
Incident logging
Basic SOC-style triage

Lessons Learned:

One practical issue encountered during the project was a Windows Server 2025 limitation involving filtered queries against the ForwardedEvents log.

Filtered Get-WinEvent queries against ForwardedEvents produced an RPC-related error in this environment, while unfiltered event retrieval worked correctly.

The detection scripts therefore retrieve the events from ForwardedEvents and perform filtering client-side.

This became an important implementation lesson: security monitoring scripts should account for platform-specific logging behavior instead of assuming every Event Log query method behaves identically.

Project Structure:

Cloud-AD-Infrastructure-Identity-Security-Lab/
│
├── README.md
│
├── architecture/
│
├── detection/
│   ├── Detect-AccountLockouts.ps1
│   ├── Detect-CredentialAttack.ps1
│   └── Detect-FailedLogons.ps1
│
├── documentation/
│
└── screenshots/

Disclaimer

This project was created as a controlled cybersecurity lab environment for educational and portfolio purposes.

All security testing was performed against intentionally configured lab systems and test accounts.