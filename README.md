# Cloud AD Infrastructure & Identity Security Lab

A hands-on Azure cybersecurity lab demonstrating **Active Directory infrastructure, identity and access management, Windows security auditing, PowerShell logging, centralized Windows Event Forwarding (WEF), detection engineering, and basic incident triage**.

The project simulates a small enterprise Windows environment hosted in Microsoft Azure and focuses on building a practical security monitoring workflow rather than simply deploying virtual machines.

---

## Project Objectives

- Deploy a Windows Server Active Directory environment in Azure
- Configure DNS and domain services
- Create structured Active Directory OUs and security groups
- Implement role-based workstation administration
- Apply Windows security auditing through Group Policy
- Enable PowerShell Script Block Logging, Module Logging, and Transcription
- Configure centralized Windows Event Forwarding
- Develop custom PowerShell security detections
- Correlate failed logons with account lockouts
- Generate structured incident records
- Validate the complete detection workflow

---

## Architecture

```text
                         Microsoft Azure
                                |
                    +-----------------------+
                    |    Azure VNet         |
                    |     10.10.0.0/16      |
                    +-----------+-----------+
                                |
                 +--------------+--------------+
                 |                             |
          10.10.1.0/24                  10.10.2.0/24
           AD Subnet                    Client Subnet
                 |                             |
          +------+-------+              +------+-------+
          |    DC01      |              |   CLIENT01   |
          | Windows      |              | Windows      |
          | Server 2025  |              | Server 2025  |
          |              |              |              |
          | AD DS        |              | Domain       |
          | DNS          |              | Joined       |
          | WEC          |<---- WEF ----| Security     |
          | Detection    |              | Events       |
          +------+-------+              +--------------+
                 |
                 v
          ForwardedEvents
                 |
                 v
        +-----------------------+
        | Detection Engine     |
        |                       |
        | 4625 Failed Logon     |
        | 4740 Account Lockout  |
        | 4625 + 4740           |
        | Correlation           |
        +-----------+-----------+
                    |
                    v
             Incident Log (CSV)
```

## Azure Environment

Component	Configuration
Cloud	Microsoft Azure
Region	Denmark East
Virtual Network	vnet-ad-security-dk
VNet Address Space	10.10.0.0/16
AD Subnet	10.10.1.0/24
Client Subnet	10.10.2.0/24
Domain Controller	DC01
Client Endpoint	CLIENT01
Operating System	Windows Server 2025
Active Directory Domain	ad.cloudlab.local
DNS	DC01
Event Collector	DC01
Event Source	CLIENT01
Event Forwarding	Windows Event Forwarding
Detection Language	PowerShell


## Active Directory & Identity

The lab domain is:

ad.cloudlab.local
Organizational Units

The Active Directory structure separates users, administrators, security personnel, groups, and workstations.

ad.cloudlab.local
│
├── Lab-Users
│   ├── Employees
│   ├── IT
│   ├── IT-Admins
│   └── Security
│
├── Groups
│
├── Lab-Computers
│   └── Workstations
│
└── Service Accounts
Test Users
Alice Employee
Bob ITAdmin
Charlie Security
Security Groups
GG-Employees
GG-IT-Admins
GG-Security-Team
GG-Workstation-Users
RBAC / Administrative Control

The GG-IT-Admins group is granted local Administrator access on CLIENT01 through Group Policy.

This demonstrates centralized privilege management instead of manually configuring administrator access on the workstation.

## Security Controls
Windows Advanced Security Auditing

Advanced Audit Policy is configured through Group Policy to capture security-relevant activity.

Key events include:

Event ID	Activity
4625	Failed logon
4740	Account lockout
4672	Special privileges assigned
4688	Process creation
4689	Process termination

### PowerShell Logging

PowerShell logging is centrally configured through Group Policy.

Enabled controls:

Script Block Logging
Module Logging
PowerShell Transcription

Script Block Logging was validated using:

Event ID 4104

PowerShell activity was verified in:

Microsoft-Windows-PowerShell/Operational

Transcripts were stored under:

C:\ProgramData\PowerShellTranscripts

## Windows Event Forwarding

CLIENT01 forwards security events to DC01 using Windows Event Forwarding.

WEF Flow
CLIENT01
    |
    | Security Events
    | 4625 / 4672 / 4688 / 4689
    |
    v
## Windows Event Forwarding
    |
    v
DC01
    |
    v
ForwardedEvents

Implementation:

Source-initiated WEF
Group Policy configuration
Subscription Manager
HTTP / WinRM
Centralized ForwardedEvents log

Subscription:

CLIENT01-Security-Monitoring

## Detection Engineering

Three custom PowerShell detection scripts were developed.

1. Failed Logon Detection

File:

detection/Detect-FailedLogons.ps1

Detects Event ID 4625 from CLIENT01 through the centralized ForwardedEvents log.

Extracts:

Account
Source machine
Logon type
Authentication status
Timestamp
Event ID
Severity

Severity:

MEDIUM
2. Account Lockout Detection

File:

detection/Detect-AccountLockouts.ps1

Detects Event ID 4740 from the Domain Controller.

Identifies:

Locked account
Lockout timestamp
Event ID
Severity

Severity:

HIGH
3. Credential Attack Correlation

File:

detection/Detect-CredentialAttack.ps1

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

This demonstrates basic correlation-based detection rather than treating every authentication failure as an isolated event.

## Incident Logging

Detected security events are written to a structured CSV incident log.

Example fields:

Timestamp
Severity
Detection
Account
Source
EventID
Details

Example:

Severity: HIGH
Detection: Credential Attack
Account: alice.employee
Source: CLIENT01.ad.cloudlab.local
EventID: 4740

The detection workflow therefore follows:

Security Event
      |
      v
Detection Script
      |
      v
Correlation / Analysis
      |
      v
Severity Assignment
      |
      v
Incident Log

## Attack Simulation

The lab was tested by intentionally generating failed authentication attempts against a controlled test account.

The resulting sequence was:

Event ID 4625
      |
      v
Multiple Failed Logons
      |
      v
Account Lockout
      |
      v
Event ID 4740
      |
      v
Correlation Engine
      |
      v
HIGH - Potential Credential Attack
      |
      v
Central Incident Log

The detection successfully correlated four failed authentication attempts with an account lockout occurring within the configured five-minute window.

## Evidence & Screenshots

The following screenshots document the implementation and validation of the lab.

### Azure Infrastructure

### Active Directory & Identity

### Access Control & Security Policies

### Centralized Monitoring

### Detection & Incident Response

## Validation Results

Final validation confirmed:

Active Directory operational
DNS operational
NTDS operational
Windows Event Collector operational
WinRM operational
CLIENT01 domain joined
Security groups configured
Local administrator access controlled through GPO
PowerShell logging operational
WEF forwarding operational
Event ID 4625 received centrally
Event ID 4672 received centrally
Event ID 4688 received centrally
Event ID 4689 received centrally
Account-lockout detection operational
Credential-attack correlation operational
Central incident logging operational

## Key Security Concepts Demonstrated
Active Directory security
Identity and Access Management (IAM)
Role-Based Access Control (RBAC)
Least-privilege administration
Group Policy
Windows security auditing
PowerShell logging
## Windows Event Forwarding
Centralized security event collection
Detection engineering
Event correlation
Authentication monitoring
Account lockout analysis
Incident logging
Basic SOC-style triage

## Lessons Learned

One practical issue encountered during the project involved filtered queries against the Windows Server 2025 ForwardedEvents log.

Filtered Get-WinEvent queries against ForwardedEvents produced an RPC-related error in this environment, while unfiltered event retrieval worked correctly.

The detection scripts therefore retrieve events from ForwardedEvents and perform filtering client-side.

This became an important implementation lesson: security monitoring scripts should account for platform-specific logging behavior instead of assuming every Event Log query method behaves identically.

## Project Structure
Cloud-AD-Infrastructure-Identity-Security-Lab/
│
├── README.md
├── LICENSE
│
├── architecture/
│   └── ARCHITECTURE.mmd
│
├── detection/
│   ├── Detect-AccountLockouts.ps1
│   ├── Detect-CredentialAttack.ps1
│   └── Detect-FailedLogons.ps1
│
├── documentation/
│   ├── ARCHITECTURE.md
│   └── DETECTION-LOGIC.md
│
└── screenshots/
    ├── Azure infrastructure evidence
    ├── Active Directory evidence
    ├── Security policy evidence
    ├── WEF evidence
    └── Detection and validation evidence

## Documentation

Additional technical documentation is available in:

documentation/ARCHITECTURE.md
documentation/DETECTION-LOGIC.md
architecture/ARCHITECTURE.mmd

Detection scripts are available in the detection/ directory.

## Disclaimer

This project was created as a controlled cybersecurity lab environment for educational and portfolio purposes.

All security testing was performed against intentionally configured lab systems and test accounts.

No production systems or unauthorized accounts were targeted.